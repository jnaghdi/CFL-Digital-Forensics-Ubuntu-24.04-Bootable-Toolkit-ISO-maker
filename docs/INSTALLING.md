# Installing CFL Forensics

The ISO boots into a menu (with the Computer Forensics Lab artwork) on
both BIOS and UEFI machines:

- **Live system** - the full DFIR workstation, nothing touches your disk.
- **Install CFL Forensics** - boots the same live system and launches the
  graphical installer (Calamares) automatically. You can also start it any
  time from the live desktop icon or the applications grid.

The installer is offline: everything it needs is on the ISO.

## Installing alongside Windows or Linux

On the partitioning page choose **Install alongside**. It is offered
whenever an existing operating system is detected, and it is the
pre-selected choice. Calamares shrinks the partition you select and
installs CFL Forensics in the freed space - **nothing on the existing
system is overwritten**.

Your options at that step:

| Choice | Result |
|---|---|
| **Install alongside** | Shrinks the chosen partition; CFL Forensics is added next to the existing OS. Your files are untouched. |
| **Replace a partition** | Only the selected partition is replaced (the rest of the disk, including other OSes, is kept). |
| **Erase disk** | Wipes the whole disk - single-boot CFL Forensics. |
| **Manual partitioning** | Full control for experienced users. |

### How much space CFL Forensics takes

The installer is configured to reserve **128 GiB** for CFL Forensics:

- With **Install alongside**, Calamares shows a slider splitting the
  partition you shrink. Its upstream default is 50 % of that partition,
  and the minimum you can give CFL Forensics is **128 GiB** - the slider
  simply stops there. Drag it down to exactly 128 GiB, or leave it
  higher if you have room. The existing OS always keeps at least its
  used data plus 10 % headroom.
- If a partition cannot spare 128 GiB while keeping the existing
  system's data intact, the alongside option is not offered for it.
- **Replace a partition** and **Erase disk** likewise require a target
  of at least ~128 GiB.

## Dual boot

GRUB is installed with a drop-in
(`/etc/default/grub.d/99-cfl-os-prober.cfg`) that guarantees:

- `GRUB_TIMEOUT=10` + `GRUB_TIMEOUT_STYLE=menu` - the menu is always
  shown for ten seconds, never hidden;
- `GRUB_DISABLE_OS_PROBER=false` - os-prober adds the detected existing
  system (Windows Boot Manager or the Linux distribution found) next to
  **CFL Forensics**.

If another OS is added later, re-run `sudo update-grub` - os-prober will
pick it up.

### Troubleshooting

- **The machine boots straight into CFL Forensics without a menu** - 
  run `sudo update-grub` once; the hardened drop-in above makes the
  menu appear on every boot with all detected systems.
- **The machine boots straight into the old OS (e.g. Windows)** - the
  firmware is still favouring the old bootloader. Open the firmware
  boot menu (usually F12/F10/ESC) once and choose the *CFL Forensics*
  (shown as *CFL Forensics*, registered in firmware as *ubuntu*) entry, then move it to the top of the boot order in the
  firmware settings. The GRUB menu then presents both systems.

## Notes

- **UEFI + Secure Boot**: the ISO and the installed system boot through
  the signed shim (`shim-signed` + `grub-efi-amd64-signed`), so Secure
  Boot can remain enabled. The installed system registers its EFI boot
  entry under the name **ubuntu** (this is required for the
  Canonical-signed GRUB to load under Secure Boot); the human-readable
  boot-menu title is still **CFL Forensics** via `GRUB_DISTRIBUTOR`.
- The installed system is the live system minus its live-only machinery
  (`casper`, `calamares`, `memtest86+`) - all
  forensic tools, the macOS theme and the menu layout carry over.
- A minimum of **128 GiB** disk space and **2 GB** RAM is required for
  installation (the live session has no such requirement).
- Root remains locked; the user you create is a `sudo` member (same
  posture as the live session).
- After installing, see [POST-INSTALL.md](POST-INSTALL.md) for LiME,
  `forensics-mode` and `evidence-mount`.
