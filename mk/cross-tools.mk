# Author(s): Dylan Turner <dylantdmt@gmail.com>
# Description:
# - Build cross-compilation tools:
#   + binutils
#   + gcc
#   + kernel-headers
#   + glibc
#   + libstdcpp

# Binutils

$(LFS)/sources/$(LFS_VERS)/binutils-$(BINUTILS_VERS).tar.xz: | $(LFS)/sources/$(LFS_VERS)/

$(LFS)/sources/binutils-$(BINUTILS_VERS)/: | $(LFS)/sources/$(LFS_VERS)/binutils-$(BINUTILS_VERS).tar.xz
	tar xfv $(LFS)/sources/$(LFS_VERS)/binutils-$(BINUTILS_VERS).tar.xz -C $(LFS)/sources

$(LFS)/sources/binutils-$(BINUTILS_VERS)/build/Makefile: | $(LFS)/sources/binutils-$(BINUTILS_VERS)/
	mkdir -p $(LFS)/sources/binutils-$(BINUTILS_VERS)/build
	cd $(LFS)/sources/binutils-$(BINUTILS_VERS)/build; ../configure --prefix=$(LFS)/tools \
		--with-sysroot=$(LFS) \
		--target=$(LFS_TGT) \
		--disable-nls \
		--enable-gprofng=no \
		--disable-werror

$(LFS)/sources/binutils-$(BINUTILS_VERS)/build/binutils/ar: | $(LFS)/sources/binutils-$(BINUTILS_VERS)/build/Makefile
	make -C $(LFS)/sources/binutils-$(BINUTILS_VERS)/build -j$(shell nproc)

$(LFS)/tools/bin/$(LFS_TGT)-ar: | $(LFS)/sources/binutils-$(BINUTILS_VERS)/build/binutils/ar
	make -C $(LFS)/sources/binutils-$(BINUTILS_VERS)/build install

# Gcc

$(LFS)/sources/$(LFS_VERS)/mpfr-$(MPFR_VERS).tar.xz: | $(LFS)/sources/$(LFS_VERS)/

$(LFS)/sources/mpfr-$(MPFR_VERS)/: | $(LFS)/sources/$(LFS_VERS)/mpfr-$(MPFR_VERS).tar.xz
	tar xfv $(LFS)/sources/$(LFS_VERS)/mpfr-$(MPFR_VERS).tar.xz -C $(LFS)/sources

$(LFS)/sources/$(LFS_VERS)/gmp-$(GMP_VERS).tar.xz: | $(LFS)/sources/$(LFS_VERS)/

$(LFS)/sources/gmp-$(GMP_VERS)/: | $(LFS)/sources/$(LFS_VERS)/gmp-$(GMP_VERS).tar.xz
	tar xfv $(LFS)/sources/$(LFS_VERS)/gmp-$(GMP_VERS).tar.xz -C $(LFS)/sources

$(LFS)/sources/$(LFS_VERS)/mpc-$(MPC_VERS).tar.gz: | $(LFS)/sources/$(LFS_VERS)/

$(LFS)/sources/mpc-$(MPC_VERS)/: | $(LFS)/sources/$(LFS_VERS)/mpc-$(MPC_VERS).tar.gz
	tar xfvz $(LFS)/sources/$(LFS_VERS)/mpc-$(MPC_VERS).tar.gz -C $(LFS)/sources

$(LFS)/sources/$(LFS_VERS)/gcc-$(GCC_VERS).tar.xz: | $(LFS)/tools/bin/$(LFS_TGT)-ar

$(LFS)/sources/gcc-$(GCC_VERS)/: | $(LFS)/sources/$(LFS_VERS)/gcc-$(GCC_VERS).tar.xz
	tar xfv $(LFS)/sources/$(LFS_VERS)/gcc-$(GCC_VERS).tar.xz -C $(LFS)/sources

$(LFS)/sources/gcc-$(GCC_VERS)/mpfr: | $(LFS)/sources/mpfr-$(MPFR_VERS)/ $(LFS)/sources/gcc-$(GCC_VERS)/
	mv $(LFS)/sources/mpfr-$(MPFR_VERS) $@

$(LFS)/sources/gcc-$(GCC_VERS)/gmp: | $(LFS)/sources/gmp-$(GMP_VERS)/ $(LFS)/sources/gcc-$(GCC_VERS)/
	mv $(LFS)/sources/gmp-$(GMP_VERS) $@

$(LFS)/sources/gcc-$(GCC_VERS)/mpc: | $(LFS)/sources/mpc-$(MPC_VERS)/ $(LFS)/sources/gcc-$(GCC_VERS)/
	mv $(LFS)/sources/mpc-$(MPC_VERS) $@

$(LFS)/sources/gcc-$(GCC_VERS)/build: | $(LFS)/sources/gcc-$(GCC_VERS)/
	mkdir -p $@

$(LFS)/sources/gcc-$(GCC_VERS)/build/Makefile: | $(LFS)/sources/gcc-$(GCC_VERS)/build $(LFS)/sources/gcc-$(GCC_VERS)/mpfr $(LFS)/sources/gcc-$(GCC_VERS)/gmp $(LFS)/sources/gcc-$(GCC_VERS)/mpc
	sed -e '/m64=/s/lib64/lib/' \
        -i.orig $(LFS)/sources/gcc-$(GCC_VERS)/gcc/config/i386/t-linux64
	cd $(LFS)/sources/gcc-$(GCC_VERS)/build; \
	../configure \
		--target=$(LFS_TGT) \
		--prefix=$(LFS)/tools \
		--with-glibc-version=$(GLIBC_VERS) \
		--with-sysroot=$(LFS) \
		--with-newlib \
		--without-headers \
		--enable-default-pie \
		--enable-default-ssp \
		--disable-nls \
		--disable-shared \
		--disable-multilib \
		--disable-threads \
		--disable-libatomic \
		--disable-libgomp \
		--disable-libquadmath \
		--disable-libssp \
		--disable-libvtv \
		--disable-libstdcxx \
		--enable-languages=c,c++

$(LFS)/sources/gcc-$(GCC_VERS)/build/gcc/gcc-cross: | $(LFS)/sources/gcc-$(GCC_VERS)/build/Makefile
	make -C $(LFS)/sources/gcc-$(GCC_VERS)/build -j$(shell nproc)

$(LFS)/tools/bin/$(LFS_TGT)-gcc: | $(LFS)/sources/gcc-$(GCC_VERS)/build/gcc/gcc-cross
	make -C $(LFS)/sources/gcc-$(GCC_VERS)/build install

$(LFS)/tools/lib/gcc/$(LFS_TGT)/$(GCC_VERS)/install-tools/include/limits.h: $(LFS)/tools/bin/$(LFS_TGT)-gcc
	cd $(LFS)/sources/gcc-$(GCC_VERS); \
	cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
		$(shell dirname $(shell $(LFS)/tools/bin/$(LFS_TGT)-gcc -print-libgcc-file-name))/install-tools/include/limits.h

# Kernel Headers

$(LFS)/sources/$(LFS_VERS)/linux-$(KERNEL_VERS).tar.xz: | $(LFS)/tools/lib/gcc/$(LFS_TGT)/$(GCC_VERS)/install-tools/include/limits.h

$(LFS)/sources/linux-$(KERNEL_VERS)/: | $(LFS)/sources/$(LFS_VERS)/linux-$(KERNEL_VERS).tar.xz
	tar xfv $(LFS)/sources/$(LFS_VERS)/linux-$(KERNEL_VERS).tar.xz -C $(LFS)/sources

$(LFS)/sources/linux-$(KERNEL_VERS)/usr/include/asm/errno.h: | $(LFS)/sources/linux-$(KERNEL_VERS)/
	make -C $(LFS)/sources/linux-$(KERNEL_VERS) mrproper
	make -C $(LFS)/sources/linux-$(KERNEL_VERS) headers -j$(shell nproc)

$(LFS)/usr/include/asm/errno.h: | $(LFS)/sources/linux-$(KERNEL_VERS)/usr/include/asm/errno.h
	find $(LFS)/sources/linux-$(KERNEL_VERS)/usr/include -type f ! -name '*.h' -delete
	cp -rv $(LFS)/sources/linux-$(KERNEL_VERS)/usr/include $(LFS)/usr/

# Glibc

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

# Libstdc++

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
	make -C $(LFS)/sources/gcc-$(GCC_VERS)/cppbuild -j$(shell nproc)

$(LFS)/usr/lib64/libstdc++.a: | $(LFS)/sources/gcc-$(GCC_VERS)/cppbuild/libtool
	make -C $(LFS)/sources/gcc-$(GCC_VERS)/cppbuild DESTDIR=$(LFS) install
	rm $(LFS)/usr/lib64/*.la

