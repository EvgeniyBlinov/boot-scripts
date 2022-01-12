#!/bin/bash
DEVICE="$1"

if test -b "${DEVICE}"; then
    target_size="$(lsblk -b --output SIZE -n -d ${DEVICE})"
else
    target_size=512M
fi

qemu-img create -f raw boot.img "$target_size"
