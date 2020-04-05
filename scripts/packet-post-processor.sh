#!/bin/bash

set -euxo pipefail

cd output
rawfile=fedora.raw

startsector=$(fdisk -l "$rawfile" | sed -n "/$rawfile/"' s|.*\*\s*\([0-9]\+\).*|\1|p')
sectorsize=$(fdisk -l "$rawfile" | sed -n '/^Units:/ s|.*= \([0-9]\+\).*|\1|p')
offset=$((startsector * sectorsize))

echo "Mounting raw image"
LOOPDEV=$(udisksctl loop-setup --no-user-interaction -o $offset -r -f $rawfile | cut -d' ' -f5 | tr -d .)
FEDROOT=/run/media/$USER/fedroot

echo -n "Creating rootfs archive "
pkexec tar -czf `pwd`/rootfs.tar.gz -C $FEDROOT . --totals --checkpoint=.1000

KERNEL=$(ls -al $FEDROOT/boot/vmlinuz-* | awk {'print $9'} | sort -V | grep -v rescue | head -1)
INITRD=$(ls -al $FEDROOT/boot/initramfs* | awk {'print $9'} | sort -V | grep -v rescue | head -1)
KERNELVER=$(echo $KERNEL | cut -d'-' -f2-)
tmp=$(mktemp -d -t initrd4me-XXXXXXX)
mkdir $tmp/boot

echo "Kernel file: $KERNEL"
echo "Initrd file: $INITRD"
echo "Kernel version: $KERNELVER"

echo -n "Creating kernel archive "
pkexec cp $KERNEL $tmp/boot/vmlinuz
pkexec tar -czf `pwd`/kernel.tar.gz -C $tmp/boot ./vmlinuz --totals --checkpoint=.1000

echo -n "Creaing initrd archive "
pkexec cp $INITRD $tmp/boot/initrd
pkexec tar -czf `pwd`/initrd.tar.gz -C $tmp/boot ./initrd --totals --checkpoint=.1000

echo -n "Creating modules archive "
pkexec tar -czf `pwd`/modules.tar.gz $FEDROOT/lib/modules/$KERNELVER --totals --checkpoint=.1000

echo "Unmounting raw image"
udisksctl unmount --block-device $LOOPDEV
#udisksctl loop-delete --block-device $LOOPDEV --no-user-interaction

echo "Cleanup"
rm -rf $tmp
