# Netboot-VirtualMachine-Script

![vm](https://github.com/user-attachments/assets/e56e7c43-e405-4f58-8a51-a9104520037e)

### Netboot-VirtualMachine Script

The Netboot-VirtualMachine Script is an automated provisioning tool designed to streamline the process of setting up a bootable environment using Ventoy and initializing a virtual machine with QEMU. This script performs the following tasks:

1. **Root User Check**:
   - Ensures the script is run with root privileges to perform necessary operations.

2. **Temporary Directory Cleanup**:
   - Deletes all files and directories in `/tmp` to ensure a clean working environment, except for the script itself.

3. **Download and Extract Ventoy**:
   - Downloads the specified version of Ventoy from its official GitHub releases.
   - Extracts the Ventoy package into a temporary directory.

4. **Locate Ventoy2Disk.sh**:
   - Searches for the Ventoy2Disk.sh script within the extracted Ventoy directory to prepare for creating the bootable image.

5. **Create Bootable Image**:
   - Creates a 1.7GB disk image file (`ventoy.img`) using `dd`.
   - Sets up a loop device for the image file.
   - Formats the loopback device with Ventoy's FAT32/MBR setup using the Ventoy2Disk.sh script, ensuring the Ventoy environment is correctly installed on the image.

6. **Mount Ventoy Partition**:
   - Mounts the Ventoy FAT32 partition from the loop device to a temporary directory.

7. **Download ISO Image**:
   - Downloads the specified Tails OS ISO image to the Ventoy partition, making it available for booting.

8. **Unmount and Clean Up**:
   - Unmounts the Ventoy FAT32 partition and detaches the loopback device.
   - Ensures the temporary directory is clean by removing all residual files.

9. **Launch Virtual Machine**:
   - Starts a virtual machine using QEMU, booting from the created Ventoy disk image.
   - Allocates 8GB of RAM and uses KVM acceleration and CPU optimization for improved performance.

10. **Post-VM Cleanup**:
    - After the QEMU virtual machine is closed, the script cleans up the temporary directory by deleting all files and directories.

This script automates the process of creating a bootable Ventoy environment, downloading necessary ISO images, and launching a virtual machine, making it a valuable tool for testing and deployment scenarios.
