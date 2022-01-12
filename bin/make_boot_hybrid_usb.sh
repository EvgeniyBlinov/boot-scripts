#!/bin/bash
FS_TYPE="${FS_TYPE:-fat}"
DEVICE="$1"
LABEL="${2:-usb}"


case "${FS_TYPE}" in
    ext4)
        SGDISK_TYPE=3:8300
        ;;
    fat)
        SGDISK_TYPE=2:ef00
        ;;
esac

# Create a GUID Partition Table (GPT)
/sbin/sgdisk "${DEVICE}" --zap-all
/sbin/sgdisk -n 1::+1M  -c 1:"BIOS boot partition" -t 1:ef02 "${DEVICE}"
/sbin/sgdisk -n 2::+50M -c 2:"EFI System"          -t 2:ef00 "${DEVICE}"
/sbin/sgdisk -n 3::-0   -c 3:"${LABEL}"            -t "${SGDISK_TYPE}" "${DEVICE}"

# Create a hybrid MBR partition table
/sbin/sgdisk --hybrid=1:2:3 "${DEVICE}"

## if DEVICE is file
if test -f "${DEVICE}"; then
    # Associate a loop device with the image file
    loop_device="$(sudo losetup --partscan --show --find boottitikku.img)p"
else
    loop_device="${DEVICE}"
fi

# Format
mkfs.fat -F32 "${loop_device}2"
if [ "${FS_TYPE}" == "ext4" ]; then
    mkfs.ext4 "${loop_device}3"
elif [ "${FS_TYPE}" == "fat" ]; then
    mkfs.fat -F32 "${loop_device}3"
fi
