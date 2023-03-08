# Author(s): Dylan Turner <dylantdmt@gmail.com>
# Description: Build the standard C++ library so we can build the whole system

$(LFS)/sources/gcc-$(GCC_VERS)/cppbuild/Makefile: | $(LFS)/usr/bin/ldd
	mkdir -p $(LFS)/sources/gcc-$(GCC_VERS)/cppbuild
	cd $(LFS)/sources/gcc-$(GCC_VERS)/cppbuild; \
	../libstdc++-v3/configure \
		--host=$(LFS_TGT) \
		--build=$(shell $(LFS)/sources/gcc-$(GCC_VERS)/config.guess) \
		--prefix=/usr \
		--disable-multilib \
		--disable-nls \
		--disable-libstdcxx-pch \
		--with-gxx-include-dir=/tools/$(LFS_TGT)/include/c++/$(GCC_VERS)

$(LFS)/sources/gcc-$(GCC_VERS)/cppbuild/libtool: | $(LFS)/sources/gcc-$(GCC_VERS)/cppbuild/Makefile
	make -C $(LFS)/sources/gcc-$(GCC_VERS)/cppbuild

$(LFS)/usr/lib64/libstdc++.a: | $(LFS)/sources/gcc-$(GCC_VERS)/cppbuild/libtool
	make -C $(LFS)/sources/gcc-$(GCC_VERS)/cppbuild DESTDIR=$(LFS) install
	rm $(LFS)/usr/lib64/*.la

