LiNTFS (Linux x NTFS) V1.0

TODO: ntfs-3g both for initramfs and rootfs so it can handle reading and
writing.

In order to run this on real hardware you'd want to modify the kernel config
so it detects your disk. Place it in res/ right before recompiling tha shit
cause the Makefile script replaces linux/.config with it. The same applies to
busybox.

Build: `make`
Test : `make test`
Clean: `make clean`

No license - do what you want.

_________
zielony12
