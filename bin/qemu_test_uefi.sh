#!/bin/bash
DEVICE="$1"

function usage {
    echo "Device not found"
    echo "Example: /dev/sdb"
    exit 1
}

[ -z "$DEVICE" ] && usage
ls $DEVICE &> /dev/null || usage

## UEFI
qemu-system-x86_64 \
    -cpu host \
    -enable-kvm \
    -bios OVMF.fd \
    -boot d \
    -m 1G \
    -drive "file=${DEVICE},format=raw,cache=none"
    #-hdb "${DEVICE}"
