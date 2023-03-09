# Author(s): Dylan Turner <dylantdmt@gmail.com>
# Description:
# - Build temporary tools used to build the rest of the system
#   + M4
#   + Ncurses
#   + Bash
#   + Coreutils
#   + Diffutils
#   + File
#   + Findutils
#   + Gawk
#   + Grep
#   + Gzip
#   + Make
#   + Patch
#   + Sed
#   + Tar
#   + Xz
#   + Binutils - Pass 2
#   + Gcc - Pass 2

# M4

$(LFS)/sources/m4-$(M4_VERS)/: | $(LFS)/usr/lib64/libstdc++.a
	tar xfv $(LFS)/sources/$(LFS_VERS)/m4-$(M4_VERS).tar.xz -C $(LFS)/sources/

$(LFS)/sources/m4-$(M4_VERS)/Makefile: | $(LFS)/sources/m4-$(M4_VERS)/
	mkdir -p $(LFS)/sources/m4-$(M4_VERS)/build
	cd $(LFS)/sources/m4-$(M4_VERS); ./configure --prefix=/usr \
		--host=$(LFS_TGT) \
		--build=$(shell $(LFS)/sources/m4-$(M4_VERS)/build-aux/config.guess)

$(LFS)/sources/m4-$(M4_VERS)/src/m4 : | $(LFS)/sources/m4-$(M4_VERS)/Makefile
	make -C $(LFS)/sources/m4-$(M4_VERS) -j$(shell nproc)

$(LFS)/usr/bin/m4: | $(LFS)/sources/m4-$(M4_VERS)/src/m4
	make -C $(LFS)/sources/m4-$(M4_VERS) DESTDIR=$(LFS) install

