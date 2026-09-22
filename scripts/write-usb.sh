#!/bin/bash
# Write the hybrid ISO to a USB stick (DESTRUCTIVE - erases the target device).
set -euo pipefail
ISO="${1:?usage: sudo $0 image.iso /dev/sdX}"
DEV="${2:?usage: sudo $0 image.iso /dev/sdX}"
[ -f "$ISO" ] || { echo "error: $ISO not found" >&2; exit 1; }
[ -b "$DEV" ] || { echo "error: $DEV is not a block device" >&2; exit 1; }
case "$DEV" in *[0-9]) echo "error: give the whole disk (/dev/sdb), not a partition ($DEV)" >&2; exit 1;; esac
if [ "$(id -u)" -ne 0 ]; then echo "error: run with sudo" >&2; exit 1; fi

echo "About to write:"
echo "    $ISO"
echo "to the WHOLE device:"
lsblk -o NAME,SIZE,MODEL,TRAN "$DEV" || true
echo
echo "ALL DATA ON $DEV WILL BE PERMANENTLY DESTROYED."
read -r -p "Type ERASE to continue: " a
[ "$a" = "ERASE" ] || { echo "aborted"; exit 1; }

umount "${DEV}"?* 2>/dev/null || true
dd if="$ISO" of="$DEV" bs=16M oflag=direct conv=fsync status=progress
sync
echo "Done. The stick boots on BIOS and UEFI (Secure Boot enabled)."
echo "Tip: verify with  sha256sum -c SHA256SUMS  next to the ISO."
