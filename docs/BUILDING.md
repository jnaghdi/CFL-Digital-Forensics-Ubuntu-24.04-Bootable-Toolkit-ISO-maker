# Building CFL Forensics from source

A bootable **digital-forensics & e-discovery workstation** from Computer
Forensics Lab Ltd ([cflab.uk](https://cflab.uk/) · [e-discovery.uk](https://e-discovery.uk/)),
built on **Ubuntu 24.04 LTS ("noble")**. It runs entirely from a USB stick or
DVD without touching the machine's internal disks, and can be **installed
alongside Windows or Linux (dual-boot)** from the boot menu.

This is a ground-up rebuild of the earlier Debian-based CFL Forensics on an
Ubuntu 24.04 base, with a from-scratch `debootstrap` build pipeline (no
`live-build`), the Ubuntu **casper** live system, and the **Calamares 3.3**
installer. See [`docs/UBUNTU-PORT-NOTES.md`](docs/UBUNTU-PORT-NOTES.md) for the
detail of what changed and why.

---

## Highlights

- **Ubuntu 24.04 LTS** base with the HWE kernel for current hardware.
- **Live + Install** on one image: forensic live session, or install
  alongside an existing OS (dual-boot), all offline.
- **BIOS + UEFI + Secure Boot** - Microsoft-signed shim → Canonical-signed
  GRUB → signed kernel, so Secure Boot can stay on.
- **Forensic defaults**: software write-blocking on at boot, no automatic
  mounting of attached media, the clock kept on UTC, swap never auto-activated.
- **GNOME + WhiteSur** macOS-style desktop with an ArcMenu "CFL MENU" and a
  Parrot-style green-on-black terminal.
- **~500 packaged tools** plus Ghidra, JADX, Volatility 3, Amass, the xLEAPP
  family, recon-ng, and more, organised into a **Forensic Tools** menu.
- **No snaps** - every application is a `.deb`, a `pipx` venv, or an upstream
  build; Firefox comes from Mozilla's own APT repository.

---

## Building the ISO

The build runs on any modern **Ubuntu or Debian** host (amd64), as root, with
about **30 GB** of free disk space and a broadband connection.

```bash
# 1. install the build dependencies
sudo apt-get update
sudo apt-get install -y debootstrap xorriso squashfs-tools rsync \
                        grub-pc-bin grub-efi-amd64-bin mtools dosfstools

# 2. the Ubuntu archive signing keyring
#    - on Ubuntu it is already present (from ubuntu-minimal), or:
sudo apt-get install -y ubuntu-keyring
#    - on Debian / Parrot / any non-Ubuntu host the package is NOT in the
#      repos, so fetch it from the Ubuntu pool with the bundled helper:
sudo ./scripts/fetch-ubuntu-keyring.sh

# 3. (optional) sanity-check every package name against the live archive first
./scripts/verify-packages.sh

# 4. build   (build.sh will also offer to fetch the keyring automatically if
#             it is still missing and you are root)
sudo ./build.sh
```

> **Building on Debian or Parrot?** That is fully supported - the only extra
> step is the Ubuntu keyring in step 2 (`sudo ./scripts/fetch-ubuntu-keyring.sh`),
> because Debian/Parrot do not package `ubuntu-keyring`. Everything else is the
> same.

The finished image and checksums land in `iso/`:

```
iso/cfl-forensics-@CFL_VERSION@-@UBUNTU_SUITE@-amd64.iso
iso/SHA256SUMS
```

The build is **stage-based and resumable** - if it stops (e.g. a network
blip), just run `sudo ./build.sh` again and it continues from the last
completed stage. Useful options:

| Command | Effect |
|---|---|
| `sudo ./build.sh` | build (skipping already-finished stages) |
| `sudo ./build.sh --clean` | wipe `work/` and build from scratch (keeps the download cache) |
| `sudo ./build.sh --from packages` | re-run from a named stage onward |
| `sudo ./build.sh --shell` | drop into a root shell inside the chroot |
| `sudo ./build.sh --strict` | abort on any failing hook or uninstallable package |
| `sudo ./build.sh --list-stages` | print the stage order |

All settings live in [`cfl-build.conf`](cfl-build.conf) and can be overridden
from the environment, e.g. `sudo CFL_VERSION=2.1 KERNEL_PKG=linux-generic ./build.sh`.

---

## Testing before you deploy

```bash
# static checks only - no root, no network, no build (runs in seconds)
./scripts/test-release.sh

# boot the built ISO in a VM
./scripts/test-iso-qemu.sh iso/cfl-forensics-*.iso              # BIOS
./scripts/test-iso-qemu.sh --uefi iso/cfl-forensics-*.iso       # UEFI (OVMF)
./scripts/test-iso-qemu.sh --uefi --secureboot iso/cfl-*.iso    # UEFI + Secure Boot
```

`test-iso-qemu.sh` also creates a blank 160 GiB scratch disk so you can walk
through the "Install alongside" flow in the VM.

## Writing to a USB stick

```bash
sudo ./scripts/write-usb.sh iso/cfl-forensics-*.iso /dev/sdX     # DESTRUCTIVE
```

The stick is a hybrid image: it boots on both BIOS and UEFI machines.

---

## Layout

```
build.sh                     the whole build pipeline (debootstrap → ISO)
cfl-build.conf               every tunable (version, mirror, kernel, user, ...)
config/
  package-lists/*.list       packages to install, grouped by purpose
  hooks/*.hook               post-install steps run in the chroot (theme,
                             Ghidra, pipx tools, menus, health checks, ...)
  includes.chroot/           files overlaid into the root filesystem
                             (launchers, dconf defaults, live-session units, ...)
  includes.iso/              files placed at the root of the ISO (README)
  calamares/                 the Calamares installer configuration + branding
  bootloaders/grub/          the ISO boot menu, theme and loopback config
  preseed/                   build-time debconf answers
scripts/                     verify-packages, test-release, test-iso-qemu, write-usb
docs/                        installing, customising, tool catalogue, port notes
```

---

## Documentation

- [`docs/INSTALLING.md`](docs/INSTALLING.md) - booting, and installing
  alongside Windows/Linux (dual-boot, disk-space, Secure Boot).
- [`docs/UBUNTU-PORT-NOTES.md`](docs/UBUNTU-PORT-NOTES.md) - how the Ubuntu
  build differs from the Debian original, and the design decisions behind it.
- [`docs/CUSTOMISING.md`](docs/CUSTOMISING.md) - adding tools, changing the
  theme, adjusting the installer.
- [`docs/POST-INSTALL.md`](docs/POST-INSTALL.md) - first steps after installing.
- [`docs/TOOL-CATALOGUE.md`](docs/TOOL-CATALOGUE.md) - the full tool inventory.
- [`docs/PARROT-CSI-PARITY.md`](docs/PARROT-CSI-PARITY.md) - the Parrot OS / CSI Linux tool-parity check for this build.

---

*Computer Forensics Lab Ltd - @CFL_URL@*
