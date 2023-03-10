# Author(s): Dylan Turner <dylantdmt@gmail.com>
# Description: Build settings

LFS :=				$(PWD)/lfs

LFS_VERS :=			11.3
BINUTILS_VERS :=	2.40
MPFR_VERS :=		4.2.0
GMP_VERS :=			6.2.1
MPC_VERS :=			1.3.1
GCC_VERS :=			12.2.0
GLIBC_VERS :=		2.37
KERNEL_VERS :=		6.1.11
M4_VERS :=			1.4.19
NCURSES_VERS :=		6.4
BASH_VERS :=		5.2.15

LFS_PKG_SRC :=		lfs-packages-$(LFS_VERS).tar
LFS_PKG_SRC_URL :=	https://ftp.osuosl.org/pub/lfs/lfs-packages/$(LFS_PKG_SRC)
LFS_TGT :=			x86_64-lfs-linux-gnu

