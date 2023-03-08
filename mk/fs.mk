# Author(s): Dylan Turner <dylantdmt@gmail.com>
# Description: Build targets to initialize the LFS filesystem

# Create folder structure and mount partitions. Chain behavior together to keep failing useful

$(LFS):
	mkdir -p $(LFS)

$(LFS)/efi/boot/: | $(LFS)
	sudo mount $(ROOT_PART) $(LFS)
	sudo chown -R $(USER):$(USER) $(LFS)
	mkdir -p $@

$(LFS)/home/: | $(LFS)/efi/boot/
	sudo mount $(EFI_PART) $(LFS)/efi/boot/ -o umask=000
	mkdir -p $@

$(LFS)/sources/: | $(LFS)/home/
	sudo mount $(HOME_PART) $(LFS)/home/
	sudo chown -R $(USER):$(USER) $(LFS)/home/
	mkdir -p $@
	chmod a+wt $@

$(LFS)/sources/$(LFS_PKG_SRC): | $(LFS)/sources/
	wget $(LFS_PKG_SRC_URL) -O $@

$(LFS)/etc/: | $(LFS)/sources/$(LFS_PKG_SRC)
	mkdir -p $@

$(LFS)/var/: | $(LFS)/etc/
	mkdir -p $@

$(LFS)/usr/bin/: | $(LFS)/var/
	mkdir -p $@

$(LFS)/bin/: | $(LFS)/usr/bin/
	ln -s $(LFS)/usr/bin $(LFS)/bin

$(LFS)/usr/lib/: | $(LFS)/bin/
	mkdir -p $@

$(LFS)/lib/: | $(LFS)/usr/lib/
	ln -s $(LFS)/usr/lib $(LFS)/lib

$(LFS)/usr/sbin/: | $(LFS)/lib/
	mkdir -p $@

$(LFS)/sbin/: | $(LFS)/usr/sbin/
	ln -s $(LFS)/usr/sbin $(LFS)/sbin

$(LFS)/lib64/: | $(LFS)/sbin/
	mkdir -p $@

$(LFS)/tools/: | $(LFS)/lib64/
	mkdir -p $@

$(LFS)/sources/$(LFS_VERS): | $(LFS)/tools/
	tar xfv $(LFS)/sources/$(LFS_PKG_SRC) -C $(LFS)/sources

