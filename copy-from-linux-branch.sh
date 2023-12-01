#!/bin/bash

set -e

basedir=$(realpath $(dirname $0))
echo "basedir=${basedir}"

run_cmd()
{
    echo "Running: $@"
    eval $@
}

parse_linux_version()
{
    local dir=$1
    local str=$2
    local line=$(grep -e  "^${str} = " ${dir}/Makefile)
    local res=$(echo $line | sed -e "s/^${str} = //")

    echo $res
}

prog=$(basename $0)
dirname=$(readlink -f $0)
dirname=$(dirname  $dirname)

if [[ -z "$1" || "$1" == "-h"  ]]; then
    echo "This is going to copy fuse files from <linux> to ${dirname}"
    echo
    echo "Usage: ${prog} <path/to/linux>"
    echo
    exit 1
fi

linux="$1"
version=$(parse_linux_version $linux VERSION)
patchlevel=$(parse_linux_version $linux PATCHLEVEL)
sublevel=$(parse_linux_version $linux SUBLEVEL)
extraversion=$(parse_linux_version $linux EXTRAVERSION)
full_version="${version}.${patchlevel}.${sublevel}"
if [ -n "${extraversion}" ]; then
    full_version+=".${extraversion}"
fi
echo "full_version='${full_version}'"

echo "version: $full_version"
echo "Press <enter> to confirm or new version string"
read manual_version

if [ -n "${manual_version}" ]; then
    full_version=${manual_version}
fi

mkdir -p  src/${full_version}
pushd src/${full_version}
run_cmd cp -a "${linux}/fs/fuse/*.{c,h}" .
rm -f *.mod.c
run_cmd cp -a ${basedir}/Makefile.fuse Makefile

run_cmd cp -a "${linux}/include/uapi/linux/fuse.h" fuse.h

# copying fuse.h to redfs.h requires removing  include/uapi/linux
sed -i -e 's#<linux\/fuse\.h>#"fuse.h"#g' *.h
sed -i -e 's#<linux\/fuse\.h>#"fuse.h"#g' *.c

popd

