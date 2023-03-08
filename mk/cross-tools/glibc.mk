# Author(s): Dylan Turner <dylantdmt@gmail.com>
# Description: Build glibc for LFS

$(LFS)/sources/$(LFS_VERS)/glibc-$(GLIBC_VERS).tar.xz: | $(LFS)/usr/include/asm/errno.h

$(LFS)/sources/glibc-$(GLIBC_VERS)/: | $(LFS)/sources/$(LFS_VERS)/glibc-$(GLIBC_VERS).tar.xz
	tar xfv $(LFS)/sources/$(LFS_VERS)/glibc-$(GLIBC_VERS).tar.xz -C $(LFS)/sources/

$(LFS)/sources/glibc-$(GLIBC_VERS)/build/libc.so: | $(LFS)/sources/glibc-$(GLIBC_VERS)/
	ln -sf $(LFS)/lib/ld-linux-x86-64.so.2 $(LFS)/lib64
	ln -sf $(LFS)/lib/ld-linux-x86-64.so.2 $(LFS)/lib64/ld-lsb-x86-64.so.3
	cd $(LFS)/sources/glibc-$(GLIBC_VERS); \
	patch -Np1 -i $(LFS)/sources/$(LFS_VERS)/glibc-$(GLIBC_VERS)-fhs-1.patch \
		| echo "Patch failed. Probably already completed. Continuing for now..."
	mkdir -p $(LFS)/sources/glibc-$(GLIBC_VERS)/build
	echo "rootsbindir=/usr/sbin" > $(LFS)/sources/glibc-$(GLIBC_VERS)/configparams
	cd $(LFS)/sources/glibc-$(GLIBC_VERS)/build; \
	../configure \
		--prefix=/usr \
		--host=$(LFS_TGT) \
		--build=$(shell $(LFS)/sources/glibc-$(GLIBC_VERS)/scripts/config.guess) \
		--enable-kernel=3.2 \
		--without-selinux \
		--with-headers=$(LFS)/usr/include \
		libc_cv_slibdir=/usr/lib
	make -C $(LFS)/sources/glibc-$(GLIBC_VERS)/build -j$(shell nproc)

$(LFS)/usr/bin/ldd: | $(LFS)/sources/glibc-$(GLIBC_VERS)/build/libc.so
	make -C $(LFS)/sources/glibc-$(GLIBC_VERS)/build DESTDIR=$(LFS) install
	sed '/RTLDLIST=/s@/usr@@g' -i $(LFS)/usr/bin/ldd
	$(LFS)/tools/libexec/gcc/$(LFS_TGT)/$(GCC_VERS)/install-tools/mkheaders

