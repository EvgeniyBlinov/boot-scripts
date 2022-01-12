#!/bin/bash
DEVICE="$1"

function usage {
    echo "Device not found"
    echo "Example: /dev/sdb"
    exit 1
}

[ -z "$DEVICE" ] && usage
ls $DEVICE &> /dev/null || usage

qemu-system-x86_64 \
    -cpu host \
    -enable-kvm \
    -boot d \
    -m 1G \
    -hdb "${DEVICE}"
