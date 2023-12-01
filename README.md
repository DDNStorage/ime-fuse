This is the standalone fuse module, which derives from linux fuse.

Order of maintainance is to update the corresponding branch in the
linux repo

https://github.com/DDNStorage/linux

and then to copy back files using copy-from-linux-branch.sh.
Makefile.fuse _might_ need to be updated before.
