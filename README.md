# Automatic Linux From Scratch

THIS PROJECT IS NOT DONE. USE AT YOUR OWN RISK

## Description

Everything you need to build a Linux From Scratch foundation, hopefully built in a maintainable way.

Why? I want to build a from-scratch distro to experiment with for fun. This will serve as the basis.

Note that this means I have made some key design choices that you __will not be able to change:__
1. Using systemd over sysvinit
2. Pure x64 not x86 or multilib
3. Additionally builds X environment
4. UEFI boot (with systemd boot)

Feel free to fork this to change that.

I strongly suggest you read through the regular [LFS](https://www.linuxfromscratch.org/lfs/view/systemd/index.html) before contributing or even just using. It's important to understand why the system is the way it is when dealing with minimal systems like this.

## Building

Dependencies:
- Linux system to build cross-compiler
- Lfs build deps:
  + Bash >= 3.2
  + Binutils >= 2.13.1
  + Bison >= 2.7
  + Coreutils >= 7.0
  + Diffutils >= 2.8.1
  + Findutils >= 4.2.31
  + Gawk >= 4.0.1
  + Gcc >= 5.1
  + Grep >= 2.5.1a
  + Gzip >= 1.3.12
  + Linux Kernel >= 3.2
  + M4 >= 1.4.10
  + Make >= 4.0
  + Patch >= 2.5.4
  + Perl >= 5.8.8
  + Python >= 3.4
  + Sed >= 4.1.5
  + Tar >= 1.22
  + Texinfo >= 4.7
  + Xz >= 5.0.0
- wget

1. Clone this repo somewhere where the full path has no spaces
2. Check to make sure your build dependencies are correct with `./scripts/version-check.sh`
3. Create a partition (~30GB+) for LFS to build on. Either on your host system or external like a USB drive/SD card
  + Root partition ~20GB
  + Home partition ~30GB
  + Swap the size of RAM amount
  + EFI partition of minimally 1MB, but you probably want something bigger like 2GB for future-proofing
  + [Reference](https://www.linuxfromscratch.org/lfs/view/systemd/chapter02/creatingfilesystem.html) for creating partitions
4. `sudo swapon <swap partition>`
5. Run `make ROOT_PART=<your partition name> HOME_PART=<name> EFI_PART=<name>`
  + My personal use: `make ROOT_PART=/dev/mmcblk0p3 HOME_PART=/dev/mmcblk0p4 EFI_PART=/dev/mmcblk0p1`

