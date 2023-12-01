#!/bin/bash
set -e

RPMNAME=fuse-dkms
MODNAME=fuse
BUILD_VERSION=1.0
WHAT="fuse kernel module with feature backports"
DESCRIPTION="fuse kernel module with feature backports"
CHROOT=''

BUILD_PATH=$(pwd)/buildroot

run_cmd()
{
    echo "Running: $@"
    eval $@
}


BUILD_RELEASE=0000
if [ -n "${BUILD_ID}" ]; then
    BUILD_RELEASE=${BUILD_ID}
fi

DATE="`date '+%Y%m%d'`"
GITID=""

if [ -z "$GITID" ]; then
    GITID="`git rev-parse --short HEAD`"
    if [ -z "$GITID" ]; then
        echo "Failed to get the git commit-id, aborting."
        echo
        print_help
    fi
fi
SUBRELEASE="${DATE}.${GITID}"

print_help()
{
    prog=`basename $0`
    echo
    echo "Usage: $prog [options]"
    echo "   -b  build path (rpm root)"
    echo "   -c  chroot to start building rpms on"
    echo "   -h  This help text"
    echo "   -r  build release."
    exit 1
}

while getopts "b:c:hr:" opt; do
    case $opt in
    b)
        BUILD_PATH="$OPTARG"
        ;;
    c)
        CHROOT="schroot -c $OPTARG --"
        ;;
    h)
        print_help "$@"
        ;;
    r)
        BUILD_RELEASE="$OPTARG"
        ;;
    *)
        echo "Invalid option: -$OPTARG" >&2
        print_help "$@"
        ;;
    esac
done

#module purge

run_cmd rm -rf ${BUILD_PATH} || exit 1
run_cmd mkdir -p ${BUILD_PATH}/{BUILD,RPMS,SRPMS,SPECS,SOURCES} || exit 1
run_cmd 'sed -e "s/%description$/&\n$DESCRIPTION/" ${RPMNAME}.spec.in >${RPMNAME}.spec' || exit 1

${CHROOT} rpmbuild -bb ${RPMNAME}.spec \
    --define "%RPMNAME ${RPMNAME}" \
    --define "%MODNAME ${MODNAME}" \
    --define "%WHAT ${WHAT}" \
    --define "%RELEASE ${BUILD_RELEASE}" \
    --define "%PACKAGE_VERSION ${BUILD_VERSION}" \
    --define "%SUBRELEASE ${SUBRELEASE}" \
    --define "_topdir ${BUILD_PATH}" \
    || exit 1

rm -f *.rpm && mv ${BUILD_PATH}/RPMS/noarch/* . || exit 1
rm -r ${BUILD_PATH} || exit 1

rm -f *.dat && md5sum *.rpm >md5sum.dat || exit

echo "finished building"
ls *.rpm

