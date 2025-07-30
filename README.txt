LiNTFS (Linux x NTFS) V1.0

TODO: build ntfsprogs for initramfs. This will need shared libc, so I will
most likely make busybox shared aswell. (for checking and cleaning the fs)

In order to run this on real hardware you'd want to modify the kernel config
so it detects your disk.

The build scripts replaces busybox/.config and linux/.config with
res/linux.cfg and res/busybox.cfg (or res/busybox.initramfs.cfg for
initramfs' busybox) respectively.

Build: `make`
Test : `make test`
Clean: `make clean`

ntfs-3g is just for ntfsprogs (NTFS_3G=0|1 make flag).
ntfs3 kernel driver is used for NTFS support so initramfs is not required,
however can be enabled (INITRAMFS=0|1 make flag).


No license - do whatever you want.

_________
zielony12
