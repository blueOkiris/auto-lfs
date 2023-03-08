# Author(s): Dylan Turner <dylantdmt@gmail.com>
# Description: Build gcc for the lfs cross-compilation

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

