LiNTFS (Linux x NTFS) V1.0

TODO: build ntfsprogs for initramfs. This will need shared libc, so I will
most likely make busybox shared aswell.

In order to run this on real hardware you'd want to modify the kernel config
so it detects your disk.

The build scripts replaces busybox/.config and linux/.config with
res/linux.cfg and res/busybox.cfg (or res/busybox.initramfs.cfg for
initramfs' busybox) respectively.

Build: `make`
Test : `make test`
Clean: `make clean`

No license - do what you want.

_________
zielony12
