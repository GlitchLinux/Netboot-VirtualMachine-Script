#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Delete all files and directories in /tmp except for the script itself
rm -rf /tmp/*

# Define Ventoy URL and file paths
ventoy_version="1.0.96"
ventoy_url="https://github.com/ventoy/Ventoy/releases/download/v${ventoy_version}/ventoy-${ventoy_version}-linux.tar.gz"
ventoy_tar="/tmp/ventoy-${ventoy_version}-linux.tar.gz"
ventoy_dir="/tmp/ventoy-${ventoy_version}"
iso_filename="Tails_6.5_amd64.iso"
iso_url="https://iso-history.tails.boum.org/tails-amd64-6.5/tails-amd64-6.5.iso"
iso_path="/tmp/ventoy/$iso_filename"

# Download Ventoy and extract it to /tmp
wget "$ventoy_url" -O "$ventoy_tar"
mkdir -p "$ventoy_dir"
tar -xzvf "$ventoy_tar" -C "$ventoy_dir"

# Find Ventoy2Disk.sh inside the extracted directory and its subdirectories
ventoy_script=$(find "$ventoy_dir" -type f -name Ventoy2Disk.sh -print -quit)

# Check if Ventoy2Disk.sh is found
if [ -z "$ventoy_script" ]; then
    echo "Error: Ventoy2Disk.sh not found in the extracted files."
    exit 1
fi

# Create a 1.7GB .img file
img_path="/tmp/ventoy.img"
dd if=/dev/zero of="$img_path" bs=1M count=1700

# Set up loop device
loop_device=$(losetup -f)
losetup "$loop_device" "$img_path"

# Format the loopback device with Ventoy FAT32/Master Boot Record (MBR)
echo -e "y\ny" | "$ventoy_script" -I -s "$loop_device"
if [ $? -ne 0 ]; then
    echo "Error: Ventoy formatting failed."
    losetup -d "$loop_device"
    exit 1
fi

# Mount the Ventoy FAT32 partition to /tmp/ventoy
mkdir -p /tmp/ventoy
mount "${loop_device}p1" /tmp/ventoy

# Download Parrot OS Home Edition ISO to Ventoy FAT32 partition
wget "$iso_url" -O "$iso_path"

# ISO file exists on the FAT32 partition, proceed with unmounting and starting the VM

# Unmount the Ventoy FAT32 partition and detach the loopback device
umount /tmp/ventoy
losetup -d "$loop_device"

# Start a VM with QEMU using the .img file with 8GB of RAM, KVM acceleration, and CPU optimization
qemu-system-x86_64 -enable-kvm -cpu host -m 8000 -drive format=raw,file="$img_path"

# After the QEMU VM is closed, delete residual files from /tmp
rm -rf /tmp/*
