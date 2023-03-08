# Author(s): Dylan Turner <dylantdmt@gmail.com>
# Description: Entry point for build system. Includes all sub-makefiles into one

include mk/settings.mk

# Helper targets

.PHONY: all
all: $(LFS)/usr/lib64/libstdc++.a

.PHONY: clean
clean:
	rm -rf $(LFS)/efi/boot/* | echo ""
	sudo umount $(LFS)/efi/boot | echo ""
	rm -rf $(LFS)/efi | echo ""
	rm -rf $(LFS)/home/* | echo ""
	sudo umount $(LFS)/home | echo ""
	rm -rf $(LFS)/home
	rm -rf $(LFS)/*
	sudo umount $(LFS) | echo ""
	rm -rf $(LFS)

# Note that this is a chained/linear build. Each uses the target of the previous as the sources
include mk/fs.mk
include mk/cross-tools/binutils.mk
include mk/cross-tools/gcc.mk
include mk/cross-tools/kernel-headers.mk
include mk/cross-tools/glibc.mk
include mk/cross-tools/libstdcpp.mk

