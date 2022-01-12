#!/bin/bash
DEVICE="$1"

mkdir /mnt/{efi,data}
mount -o rw,umask=0000 "${DEVICE}2" /mnt/efi
mount "${DEVICE}3" /mnt/data

# Install GRUB for UEFI and BIOS booting
grub-install --target=x86_64-efi --recheck --removable --uefi-secure-boot --efi-directory=/mnt/efi --boot-directory=/mnt/efi/boot
grub-install --target=i386-pc --recheck --boot-directory=/mnt/data/boot "${DEVICE}"

# Remove problematic files
rm /mnt/efi/EFI/BOOT/BOOTX64.CSV
rm /mnt/efi/EFI/BOOT/fbx64.efi
rm /mnt/efi/EFI/BOOT/grub.cfg

# Take recursive ownership of the data partition
chown -R 1000:1000 /mnt/data

# Create sample configuration files
cat > /mnt/efi/boot/grub/grub.cfg << EOF
search --set=root --file /boot/grubhybrid.cfg
configfile /boot/grubhybrid.cfg
EOF
cp /mnt/efi/boot/grub/grub.cfg /mnt/data/boot/grub/grub.cfg
cp /mnt/data/boot/grub/grub.cfg /mnt/data/boot/grub/grub.cfg.bak
cat > /mnt/data/boot/grubhybrid.cfg << "EOF"
set menu_color_normal=black/cyan
set menu_color_highlight=light-cyan/cyan
menuentry "Reboot" { reboot }
menuentry "Poweroff" { halt }
if [ ${grub_platform} == "efi" ]; then
    menuentry "UEFI setup" { fwsetup  }
fi
EOF
