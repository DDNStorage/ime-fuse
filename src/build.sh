#!/bin/bash

set -e

mapped_dir="" # the directory with module code, per kernel version

theusage()
{
    echo
    echo "`basename $0`"
    echo "    --kernelver <version>"
    echo "            Build for this kernel version."
    echo "            Optional, if ommitted the result of "uname -r" is used."
    echo "    --help  Print the help and exit"
    echo

    exit 1
}

find_mapping()
{
    local mapped=""

    if [ -z "${kernelver}" ]; then
        kernelver=$(uname -r)
    fi

    # split something linux 6.2.0-25-generic into an array, delimiter is "-"
    local kernel_ver_array=

    # adds a \n for the last array element
    #readarray -td'-' kernel_ver_array <<<$kernelver

    # this does not add \n
    readarray -td'.' kernel_ver_array < <(printf '%s' "$kernelver")
    declare -p kernel_ver_array

    # array size / number of elements
    len=${#kernel_ver_array[@]}
    echo "elements: $len"
    echo "array: $kernel_ver_array"

    # Trying kernel_ver_array, with split down, for 6.2.0-25-generic
    # it will try 6.2.0-25-generic, then 6.2.0-25, then 6.2.0
    while [ $len -ne 0 ]; do
        cnt=0
        version=""
        while [ $cnt -ne $len ]; do
            if [ -n "$version" ]; then
                version+="."
            fi
            version+=${kernel_ver_array[$cnt]}
            cnt=$((cnt + 1))
        done

        echo "kernel mapping version: $version"
        len=$((len - 1))

        set +e
        mapped=$(cat kernel-mapping.txt | grep $version)
        set -e
        if [ -z "$mapped" ];then
            # not found
            continue;
        fi
        mapped_dir=$(echo $mapped | awk '{print $2}')


        if [ ! -d "${mapped_dir}" ]; then
            echo "Mapping entry ${mapped} found, but module dir ${mapped_dir} is missing"
            exit 1
        else
            echo "Found mapped directory: '${mapped_dir}' for version: '$version'"
            break
        fi
    done

    if [ -z "$mapped" ]; then
        echo "Did not find fuse module for kernel version $kernelver"
        exit 1
    fi
}

while true
do
    case "$1" in
        --kernelver)
            kernelver=$2
            shift 2
            break
            ;;
        -h|--help)
            theusage
            break
            ;;
        *)
            break
            ;;
    esac
done


command=$1

find_mapping

pushd ${mapped_dir}
make -j $(($(nproc) / 2)) KERNELDIR=/lib/modules/${kernelver}/build $command
[ $? -eq 0 ] || exit 1
popd


# either copy over .ko files or remove them
if [ "$command" = clean ]; then
    rm -f *.ko
else
    # copy the .ko files into the directory where dkms expects them
    cp ${mapped_dir}/*.ko .
fi
