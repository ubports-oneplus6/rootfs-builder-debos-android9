#!/bin/sh

## A really crappy script to extract the rootfs ext4 partition
## from a whole disk partition
set -e

image="$1"

echo "Extracting rootfs..."
dd if=$1 skip=17408 of=root-$1 iflag=skip_bytes,count_bytes
mv root-$1 $1
echo "Rootfs image is $1.img"
echo "Shrinking rootfs"
e2fsck -fy $1
resize2fs -p $1