# Author(s): Dylan Turner <dylantdmt@gmail.com>
# Description: Build binutils-2.38 after building filesystem

$(LFS)/sources/$(LFS_VERS)/binutils-$(BINUTILS_VERS).tar.xz: | $(LFS)/sources/$(LFS_VERS)

$(LFS)/sources/binutils-$(BINUTILS_VERS)/: | $(LFS)/sources/$(LFS_VERS)/binutils-$(BINUTILS_VERS).tar.xz
	tar xfv $(LFS)/sources/$(LFS_VERS)/binutils-$(BINUTILS_VERS).tar.xz -C $(LFS)/sources

$(LFS)/sources/binutils-$(BINUTILS_VERS)/build/ar: | $(LFS)/sources/binutils-$(BINUTILS_VERS)/
	mkdir -p $(LFS)/sources/binutils-$(BINUTILS_VERS)/build
	cd $(LFS)/sources/binutils-$(BINUTILS_VERS)/build; ../configure --prefix=$(LFS)/tools \
		--with-sysroot=$(LFS) \
		--target=$(LFS_TGT) \
		--disable-nls \
		--enable-gprofng=no \
		--disable-werror
	make -C $(LFS)/sources/binutils-$(BINUTILS_VERS)/build -j$(shell nproc)

$(LFS)/tools/bin/$(LFS_TGT)-ar: | $(LFS)/sources/binutils-$(BINUTILS_VERS)/build/ar
	make -C $(LFS)/sources/binutils-$(BINUTILS_VERS)/build install

