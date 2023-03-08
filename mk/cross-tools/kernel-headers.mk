# Author(s): Dylan Turner <dylantdmt@gmail.com>
# Description: Build the Linux API headers used for Glibc when building the system

$(LFS)/sources/$(LFS_VERS)/linux-$(KERNEL_VERS).tar.xz: | $(LFS)/tools/lib/gcc/$(LFS_TGT)/$(GCC_VERS)/install-tools/include/limits.h

$(LFS)/sources/linux-$(KERNEL_VERS)/: | $(LFS)/sources/$(LFS_VERS)/linux-$(KERNEL_VERS).tar.xz
	tar xfv $(LFS)/sources/$(LFS_VERS)/linux-$(KERNEL_VERS).tar.xz -C $(LFS)/sources

$(LFS)/sources/linux-$(KERNEL_VERS)/usr/include/asm/errno.h: | $(LFS)/sources/linux-$(KERNEL_VERS)/
	make -C $(LFS)/sources/linux-$(KERNEL_VERS) mrproper
	make -C $(LFS)/sources/linux-$(KERNEL_VERS) headers -j$(shell nproc)

$(LFS)/usr/include/asm/errno.h: | $(LFS)/sources/linux-$(KERNEL_VERS)/usr/include/asm/errno.h
	find $(LFS)/sources/linux-$(KERNEL_VERS)/usr/include -type f ! -name '*.h' -delete
	cp -rv $(LFS)/sources/linux-$(KERNEL_VERS)/usr/include $(LFS)/usr/

