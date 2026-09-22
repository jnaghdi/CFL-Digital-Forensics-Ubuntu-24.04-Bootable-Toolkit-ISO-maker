<p align="center">
  <img src="config/includes.chroot/usr/share/backgrounds/cfl-forensics/cfl-logo.png" width="120" alt="CFL Forensics">
</p>

<h1 align="center">CFL Forensics</h1>

<p align="center">
  <b>A digital forensics &amp; e-discovery workstation on Ubuntu 24.04 LTS - live from USB, or installed alongside Windows.</b>
</p>

<p align="center">
  <a href="#"><img alt="Build" src="https://img.shields.io/badge/build-static%20checks%20passing-brightgreen"></a>
  <a href="LICENSE"><img alt="Licence" src="https://img.shields.io/badge/licence-MIT-blue"></a>
  <img alt="Base" src="https://img.shields.io/badge/base-Ubuntu%2024.04%20LTS-E95420?logo=ubuntu&logoColor=white">
  <img alt="Boot" src="https://img.shields.io/badge/boot-BIOS%20%7C%20UEFI%20%7C%20Secure%20Boot-informational">
</p>

---

CFL Forensics is developed by [Computer Forensics Lab Ltd](https://cflab.uk/), a London digital-forensics and e-discovery practice. It is the environment we use in our own casework, released so any examiner can use, audit and rebuild it.

> **Download:** release images and checksums are published on the [Releases](../../releases) page. Verify with `sha256sum -c SHA256SUMS` before writing to USB.

## Why it's different

Every forensic distro ships tools. CFL Forensics is designed around **not altering the evidence**:

| Default | What it means |
|---|---|
| **Write-blocking on at boot** | newly attached drives are treated as read-only by the desktop |
| **No automatic mounting** | nothing is mounted until you decide |
| **No hidden writes** | swap is never activated on internal disks; journals are never replayed while the live medium is being located |
| **Clock on UTC** | timestamps follow forensic convention |
| **No snaps** | every tool is a native `.deb`, `pipx` venv or upstream build |

One image is both a **live system** and an **installer** (install alongside Windows/Linux, ≥ 128 GiB reserved). It boots on **BIOS and UEFI with Secure Boot enabled** via the Microsoft-signed shim → Canonical-signed GRUB → signed kernel chain.

## What's inside

**500+ tools**, organised into a 14-category **Apps** menu - Acquisition & Imaging · Disk & File Systems · Memory · Network · Malware & RE · Passwords · Steganography · Timeline & Artefacts · Documents & E-Discovery · Mobile · OSINT · Incident Response · Secure Wiping · SDR.

Highlights: Guymager, dc3dd, ewfacquire · The Sleuth Kit, Autopsy, TestDisk/PhotoRec, bulk_extractor · Volatility 3, LiME · plaso, RegRipper, Hindsight · pff/pst tools, oletools, ExifTool · iLEAPP/ALEAPP, MVT, Andriller · Wireshark, tcpdump · Ghidra, radare2, JADX, YARA · recon-ng, SpiderFoot, Sherlock, Maigret, Holehe · John, hashcat · GNU Radio, gqrx · nwipe.

The complete generated inventory (590+ items) is in [`docs/TOOL-LIST.md`](docs/TOOL-LIST.md), the annotated catalogue in [`docs/TOOL-CATALOGUE.md`](docs/TOOL-CATALOGUE.md); the Parrot OS / CSI Linux parity check is in [`docs/PARROT-CSI-PARITY.md`](docs/PARROT-CSI-PARITY.md).

## Quick start

**Use a release image** - write it to USB and boot:

```bash
sha256sum -c SHA256SUMS
sudo ./scripts/write-usb.sh cfl-forensics-2.0-noble-amd64.iso /dev/sdX   # destructive
```

**Build it yourself** (Ubuntu, Debian or Parrot host, root, ~30 GB free):

```bash
git clone https://github.com/jnaghdi/CFL-Digital-Forensics-Ubuntu-24.04-Bootable-Toolkit-ISO-maker.git
cd CFL-Digital-Forensics-Ubuntu-24.04-Bootable-Toolkit-ISO-maker
sudo apt-get install -y debootstrap xorriso squashfs-tools rsync grub-pc-bin grub-efi-amd64-bin mtools dosfstools
sudo ./scripts/fetch-ubuntu-keyring.sh   # non-Ubuntu hosts only
./scripts/test-release.sh                 # static checks (seconds, no root)
sudo ./build.sh                           # → iso/cfl-forensics-2.0-noble-amd64.iso
./scripts/test-iso-qemu.sh --uefi iso/*.iso
```

The build is stage-based and resumable; `sudo ./build.sh --from <stage>` re-runs from any point. See [`docs/BUILDING.md`](docs/BUILDING.md) for options and [`docs/CUSTOMISING.md`](docs/CUSTOMISING.md) to add tools or change the theme.

## Repository layout

```
build.sh                  the build pipeline (debootstrap → squashfs → hybrid ISO)
cfl-build.conf            every tunable (version, kernel, live user, install size, ...)
config/package-lists/     packages to install, grouped by purpose
config/hooks/             post-install steps run in the chroot (theme, Ghidra, pipx tools, menus, ...)
config/includes.chroot/   files overlaid into the image (launchers, dconf, live-session units, ...)
config/calamares/         installer configuration + branding
config/bootloaders/grub/  ISO boot menu, theme, loopback entry
scripts/                  test-release, verify-packages, test-iso-qemu, write-usb, fetch-ubuntu-keyring
docs/                     installing, building, customising, tool catalogue, design notes
```

## Documentation

- [Installing & dual-boot](docs/INSTALLING.md) · **[Build guide](docs/BUILD-GUIDE.md)** · [Building (reference)](docs/BUILDING.md) · [Customising](docs/CUSTOMISING.md) · [After installing](docs/POST-INSTALL.md)
- [Design notes for the Ubuntu port](docs/UBUNTU-PORT-NOTES.md) - the decisions behind casper hardening, Secure Boot, DKMS, the menu and the terminal launchers
- **[Complete tool list](docs/TOOL-LIST.md)** (generated from the build) · [Tool catalogue](docs/TOOL-CATALOGUE.md) · [Parrot/CSI parity](docs/PARROT-CSI-PARITY.md) · [Kali/Parrot comparison](docs/KALI-PARROT-COMPARISON.md) · [CSI comparison](docs/CSI-COMPARISON.md)

## Contributing

Bug reports, tool requests and pull requests are welcome - see [CONTRIBUTING.md](CONTRIBUTING.md). Run `./scripts/test-release.sh` before opening a PR; it is the same check CI runs.

## Licence

The build system and configuration are released under the [MIT Licence](LICENSE). The image contains software under many licences - each package's own terms apply. Ubuntu and the Ubuntu logo are trademarks of Canonical Ltd; this project is not affiliated with or endorsed by Canonical.

---

<p align="center"><sub>Computer Forensics Lab Ltd · <a href="https://cflab.uk/">cflab.uk</a> · <a href="https://computerforensicslab.co.uk/">computerforensicslab.co.uk</a> · <a href="https://e-discovery.uk/">e-discovery.uk</a></sub></p>
