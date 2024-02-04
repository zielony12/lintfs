CORES := $(shell nproc)
BASE := $(shell pwd)
SHELL := /bin/bash

.SILENT: download_toolchain
.PHONY: all rebuild clean clean_linux clean_busybox
all: get_linux compile_linux download_toolchain get_musl compile_musl get_busybox compile_busybox get_ntfs3g compile_ntfs3g make_initramfs make_dist
rebuild: compile_linux compile_musl compile_busybox compile_ntfs3g make_initramfs make_dist
cleanbuild: clean compile_linux compile_musl compile_busybox compile_ntfs3g make_initramfs make_dist

get_linux:
ifneq ($(wildcard linux),)
	cd linux && git pull
else
	git clone https://github.com/torvalds/linux.git linux
endif

compile_linux:
	cp res/linux.cfg linux/.config
	$(MAKE) ARCH=x86 -C linux -j $(CORES) bzImage

download_toolchain:
ifeq ($(wildcard i686-linux-musl-cross),)
	curl -O http://musl.cc/i686-linux-musl-cross.tgz
	tar -xzf i686-linux-musl-cross.tgz
endif

get_musl:
ifneq ($(wildcard musl),)
	cd musl && git pull
else
	git clone git://git.musl-libc.org/musl musl
endif

compile_musl:
	cd musl; \
	CC=../i686-linux-musl-cross/bin/i686-linux-musl-gcc ./configure --prefix=../busybox/_install/usr/
	$(MAKE) CROSS_COMPILE=../i686-linux-musl-cross/bin/i686-linux-musl- -C musl -j $(CORES)
	$(MAKE) -C musl install

get_busybox:
ifneq ($(wildcard busybox),)
	cd busybox && git pull
else
	git clone https://github.com/mirror/busybox.git busybox
endif

get_ntfs3g:
ifneq ($(wildcard ntfs-3g),)
	cd ntfs-3g && git pull
else
	git clone https://github.com/tuxera/ntfs-3g.git ntfs-3g
endif

compile_busybox:
	cp res/busybox.cfg busybox/.config
	$(MAKE) arch=x86 -C busybox -j $(CORES)
	$(MAKE) arch=x86 -C busybox install
	cp res/busybox.initramfs.cfg busybox/.config
	$(MAKE) arch=x86 -C busybox -j $(CORES)
	$(MAKE) arch=x86 -C busybox install

compile_ntfs3g:
	cd ntfs-3g; \
	./autogen.sh; \
	CC=/home/karol/Documents/linux_ntfs/i686-linux-musl-cross/bin/i686-linux-musl-gcc ./configure --host=i686-linux-musl --prefix=/home/karol/Documents/linux_ntfs/busybox/_install/usr/ --exec-prefix=/home/karol/Documents/busybox/_install/usr/
	$(MAKE) -C ntfs-3g -j $(CORES)
	#$(MAKE) -C ntfs-3g install
	cp ntfs-3g/libntfs-3g/.libs/* busybox/_install/usr/lib/
	cp ntfs-3g/ntfsprogs/.libs/* busybox/_install/usr/sbin/
	#cp ntfs-3g/libntfs-3g/.libs/* busybox/_initramfs/usr/lib/
	#cp ntfs-3g/ntfsprogs/.libs/* busybox/_initramfs/usr/sbin/

make_initramfs:
	cp -r busybox/_initramfs initramfs
	mkdir -p initramfs/{etc,dev,tmp,sys,proc,new_root}
	cp res/fstab initramfs/etc/fstab
	cp res/init.initramfs initramfs/init
	chmod +x initramfs/init
	cd initramfs; find . | cpio --owner +0:+0 -H newc -o | gzip > ../initramfs.cpio.gz

make_dist:
	dd if=/dev/zero of=dist.img bs=1k count=512k
	parted -s dist.img mklabel msdos mkpart primary ext4 0 512
	parted -s dist.img set 1 boot on
	doas losetup -P /dev/loop69 dist.img
	doas mkntfs /dev/loop69p1
	doas mount /dev/loop69p1 /mnt
	doas chown karol:karol /mnt
	mkdir -p /mnt/{etc,boot/syslinux,dev,tmp,sys,proc,lib}
	cp -r busybox/_install/* /mnt/
	cp /mnt/usr/lib/libc.so /mnt/lib/ld-musl-i386.so.1
	cp res/inittab /mnt/etc/inittab
	mkdir /mnt/etc/init.d
	cp res/init.d/* /mnt/etc/init.d/
	chmod +x /mnt/etc/init.d/* 
	cp linux/arch/x86/boot/bzImage /mnt/boot/
	cp initramfs.cpio.gz /mnt/boot/
	cp res/syslinux.cfg /mnt/boot/syslinux/
	doas chown -R root:root /mnt
	doas extlinux -i /mnt
	sync
	doas umount /mnt
	doas losetup -d /dev/loop69

clean: clean_linux clean_musl clean_busybox clean_dist

clean_linux:
	$(MAKE) -C linux clean

clean_musl:
	$(MAKE) -C musl clean

clean_busybox:
	$(MAKE) -C busybox clean

clean_dist:
	rm dist.img

reset: clean_dist
	rM -R linux busybox i686-linux-musl-cross i686-linux-musl-cross.tgz

test:
	qemu-system-x86_64 -drive file=dist.img,if=virtio -m 1G
