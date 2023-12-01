#!/bin/bash -xe
# script name: RPM_BUILD.sh
# testing: create script to build rpm

NAME="ime-nvme"

IM_RPM_PATH="/home/jenkins/rpms/$NAME/IM_${BUILD_ID}/"
IM_LATEST_PATH="/home/jenkins/rpms/$NAME/latest"

echo $NAME-$VERSION RPMs will be saved to $IM_RPM_PATH

BUILD_PATH="buildroot"

./make-rpm.sh -r $BUILD_ID

#Locate the new RPM
RPM=$(find -name "$NAME*noarch*.rpm")
MD5=$(find -name "md5sum.dat")

#Verify the RPM is OK
rpm -qlp $RPM
rpm -K --nosignature $RPM

mkdir -p $IM_RPM_PATH
cp -f $RPM $IM_RPM_PATH
cp -f $MD5 $IM_RPM_PATH

# Create symbolic lyncs of this build into latest
echo Build complete. Creating symbolic lyncs for $IM_LATEST_PATH

rm -f $IM_LATEST_PATH
ln -sf $IM_RPM_PATH $IM_LATEST_PATH

