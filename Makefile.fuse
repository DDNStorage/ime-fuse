# SPDX-License-Identifier: GPL-2.0-only
#
# Makefile for the FUSE filesystem.
#

obj-m += fuse.o
fuse-y := dev.o dir.o file.o inode.o control.o xattr.o acl.o readdir.o
fuse-$(CONFIG_FUSE_DAX) += dax.o

KERNELDIR ?= /lib/modules/$(shell uname -r)/build

all:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) clean

.PHONY: clean
