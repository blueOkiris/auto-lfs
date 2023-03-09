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

# Ncurses

$(LFS)/sources/ncurses-$(NCURSES_VERS)/: | $(LFS)/usr/bin/m4
	tar xfvz $(LFS)/sources/$(LFS_VERS)/ncurses-$(NCURSES_VERS).tar.gz -C $(LFS)/sources/

$(LFS)/sources/ncurses-$(NCURSES_VERS)/build/progs/tic: | $(LFS)/sources/ncurses-$(NCURSES_VERS)/
	mkdir -p $(LFS)/sources/ncurses-$(NCURSES_VERS)/build/
	cd $(LFS)/sources/ncurses-$(NCURSES_VERS)/build; \
	../configure
	make -C $(LFS)/sources/ncurses-$(NCURSES_VERS)/build/include -j$(shell nproc)
	make -C $(LFS)/sources/ncurses-$(NCURSES_VERS)/build/progs tic -j$(shell nproc)

$(LFS)/sources/ncurses-$(NCURSES_VERS)/Makefile: | $(LFS)/sources/ncurses-$(NCURSES_VERS)/build/progs/tic
	cd $(LFS)/sources/ncurses-$(NCURSES_VERS); \
	./configure --prefix=/usr \
		--host=$(LFS_TGT) \
		--build=$(shell $(LFS)/sources/ncurses-$(NCURSES_VERS)/config.guess) \
		--mandir=/usr/share/man \
		--with-manpage-format=normal \
		--with-shared \
		--without-normal \
		--with-cxx-shared \
		--without-debug \
		--without-ada \
		--disable-scripting \
		--enable-widec

$(LFS)/sources/ncurses-$(NCURSES_VERS)/lib/libncursesw.so.6.4: | $(LFS)/sources/ncurses-$(NCURSES_VERS)/Makefile
	make -C $(LFS)/sources/ncurses-$(NCURSES_VERS)/ -j$(shell nproc)

$(LFS)/usr/lib/libncursesw.so.6.4: | $(LFS)/sources/ncurses-$(NCURSES_VERS)/lib/libncursesw.so.6.4
	make -C $(LFS)/sources/ncurses-$(NCURSES_VERS) \
		DESTDIR=$(LFS) TIC_PATH=$(LFS)/sources/ncurses-$(NCURSES_VERS)/build/progs/tic \
		install
	echo "INPUT(-lncursew)" > $(LFS)/usr/lib/libncurses.so

# Bash

$(LFS)/sources/bash-$(BASH_VERS)/: | $(LFS)/usr/lib/libncursesw.so.6.4
	tar xfv $(LFS)/sources/$(LFS_VERS)/bash-$(BASH_VERS).tar.gz -C $(LFS)/sources/

$(LFS)/sources/bash-$(BASH_VERS)/Makefile: | $(LFS)/sources/bash-$(BASH_VERS)/
	cd $(LFS)/sources/bash-$(BASH_VERS)/; \
	./configure --prefix=/usr \
		--build=$(shell $(LFS)/sources/bash-$(BASH_VERS)/support/config.guess) \
		--host=$(LFS_TGT) \
		--without-bash-malloc

$(LFS)/sources/bash-$(BASH_VERS)/bash: | $(LFS)/sources/bash-$(BASH_VERS)
	make -C $(LFS)/sources/bash-$(BASH_VERS) -j$(shell nproc)

$(LFS)/usr/bin/bash: | $(LFS)/sources/bash-$(BASH_VERS)/bash
	make -C $(LFS)/sources/bash-$(BASH_VERS) DESTDIR=$(LFS) install

$(LFS)/bin/sh: | $(LFS)/usr/bin/bash
	ln -s $(LFS)/usr/bin/bash $(LFS)/bin/sh

