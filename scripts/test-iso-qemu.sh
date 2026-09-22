#!/bin/bash
# Boot a freshly built CFL Forensics ISO in QEMU for a smoke test.
#   ./test-iso-qemu.sh path/to.iso            # BIOS (SeaBIOS)
#   ./test-iso-qemu.sh --uefi path/to.iso     # UEFI via OVMF (Secure Boot chain)
#   ./test-iso-qemu.sh --uefi --secureboot path/to.iso   # UEFI + enrolled SB keys
set -euo pipefail
UEFI=0; SECUREBOOT=0
while [ $# -gt 0 ]; do
    case "$1" in
        --uefi)        UEFI=1 ;;
        --secureboot)  UEFI=1; SECUREBOOT=1 ;;
        *)             ISO="$1" ;;
    esac
    shift
done
: "${ISO:?usage: $0 [--uefi] [--secureboot] path/to/cfl-forensics.iso}"
[ -f "$ISO" ] || { echo "error: $ISO not found" >&2; exit 1; }
MEM="${MEM:-4096}"
KVM=""
if [ -w /dev/kvm ]; then KVM="-enable-kvm -cpu host"; else echo "note: /dev/kvm unavailable - software emulation (slow)"; fi

# A blank scratch disk so you can exercise the "Install alongside" flow.
DISK="${DISK:-/tmp/cfl-test-disk.img}"
DISK_GIB="${DISK_GIB:-160}"          # must exceed INSTALL_MIN_GIB for the installer
if [ ! -f "$DISK" ]; then
    echo "creating a ${DISK_GIB} GiB scratch disk at $DISK (sparse)"
    qemu-img create -f qcow2 "$DISK" "${DISK_GIB}G" >/dev/null
fi

set -- $KVM -m "$MEM" -smp "$(nproc)" -machine q35 \
    -drive file="$DISK",if=virtio,format=qcow2 \
    -drive file="$ISO",if=none,id=cd,media=cdrom,readonly=on \
    -device ide-cd,drive=cd,bootindex=1 \
    -vga virtio -display gtk -usb -device usb-tablet -net nic -net user

if [ "$UEFI" = 1 ]; then
    CODE=""; VARS=""
    for c in /usr/share/OVMF/OVMF_CODE_4M.secboot.fd /usr/share/OVMF/OVMF_CODE.secboot.fd /usr/share/OVMF/OVMF_CODE_4M.fd /usr/share/OVMF/OVMF_CODE.fd; do
        [ -f "$c" ] && { CODE="$c"; break; }
    done
    [ "$SECUREBOOT" = 1 ] && for v in /usr/share/OVMF/OVMF_VARS_4M.ms.fd /usr/share/OVMF/OVMF_VARS.ms.fd; do [ -f "$v" ] && { VARS="$v"; break; }; done
    [ -z "$VARS" ] && for v in /usr/share/OVMF/OVMF_VARS_4M.fd /usr/share/OVMF/OVMF_VARS.fd; do [ -f "$v" ] && { VARS="$v"; break; }; done
    [ -n "$CODE" ] || { echo "error: OVMF firmware not found - apt-get install ovmf" >&2; exit 1; }
    cp "$VARS" /tmp/cfl-ovmf-vars.fd
    set -- "$@" \
        -drive if=pflash,format=raw,unit=0,readonly=on,file="$CODE" \
        -drive if=pflash,format=raw,unit=1,file=/tmp/cfl-ovmf-vars.fd
    echo "UEFI boot via $CODE${SECUREBOOT:+ (Secure Boot vars: $VARS)}"
fi

echo "launching QEMU - close the window to end the test"
exec qemu-system-x86_64 "$@"
