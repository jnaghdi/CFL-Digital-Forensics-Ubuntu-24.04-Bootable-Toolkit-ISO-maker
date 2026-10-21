# Changelog

All notable changes to CFL Forensics are recorded here.

## [2.0.1] - 2026-10-21

### Fixed
- Installer failed at the end of "install alongside Windows" with "Could not
  run command ... missing variables KVER, SRC, ...". Calamares expands variables
  in shellprocess commands itself; the pre-bootloader and finish logic now live
  in `/usr/local/sbin/cfl-install-prebootloader` and `cfl-install-finish` and
  the configs call them by path with no variables. `packages.conf` now uses
  `try_remove` and only real package names. The static suite checks both.

## [2.0] - 2026-09

**Ground-up rebuild on Ubuntu 24.04 LTS** (previously Debian 13 / live-build).

### Added
- From-scratch `debootstrap` build pipeline (`build.sh`): eleven resumable stages,
  no `live-build` dependency; builds on Ubuntu, Debian and Parrot hosts.
- Ubuntu **casper** live system with a hardened boot: `13swap` removed from the
  initramfs (no swap activation on internal disks); `noload`/`norecovery`/`nologreplay`
  when probing partitions for the boot medium; `nopersistent` so casper never
  creates a persistence partition on the boot USB.
- **Secure Boot** on the ISO and the installed system (Microsoft-signed shim,
  Canonical-signed GRUB, signed HWE kernel); hybrid BIOS/UEFI image via xorriso.
- **Calamares 3.3.5** installer configured from scratch: install alongside
  Windows/Linux pre-selected, ≥ 128 GiB reserved, removable-media EFI fallback,
  live-only files stripped from the installed system.
- Live session as an unprivileged `cfl` user (casper model) with `cfl-live.service`,
  `cfl-run` / `cfl-run-gui` launchers, write-blocking on at boot, automount off.
- **Apps** menu (ArcMenu with the CFL logo) plus GNOME app-grid folders for all
  14 categories, so the menu exists even without the extension.
- Firefox as a real `.deb` (Mozilla APT repo → Mozilla Team PPA → official tarball),
  verified; Thunderbird when Mozilla publishes it. No snaps.
- Parrot OS / CSI Linux parity: 32 archive packages and 8 PyPI tools added
  (Autopsy web UI, radare2, pev, ssdeep, zuluCrypt, Tor Browser launcher, smbmap,
  scrcpy, yt-dlp, holehe, maigret, socialscan, h8mail, toutatis, Hindsight, MVT,
  Andriller) with 30 new menu launchers.
- DKMS handling that can never break a package install (`no-autoinstall-errors`),
  with a build-time module report (`DKMS-STATUS.txt`).
- Static test suite `scripts/test-release.sh` (108 checks) including detection of
  snap-stub packages, GRUB package conflicts, undefined shell functions and
  terminal-launcher regressions; `scripts/fetch-ubuntu-keyring.sh` for non-Ubuntu hosts.

### Changed
- Terminal tool launchers show the tool's usage (probed with stdin closed and a
  timeout, so nothing can hang) and then leave a live shell in the window;
  terminal `exit-action` is `close`, never `hold`/`restart`.
- Boot is quiet with no graphical logo splash.
- 17 Debian-only package names resolved to Ubuntu equivalents
  (`linux-firmware`, `ubuntu-dock`, HWE headers, …); ArcMenu, recon-ng, waymore,
  assetfinder, exiflooter and plaso now come from upstream/PyPI.

### Removed
- `live-build`, `live-boot`/`live-config`, root autologin, the Plymouth logo theme,
  `forensics-extra` and `libphdi-utils` (not in the Ubuntu archive).

## [1.0]
- Original Debian 13 "trixie" live-build release.
