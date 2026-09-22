# Ubuntu 24.04 port - what changed and why

CFL Forensics @CFL_VERSION@ is a ground-up rebuild of the earlier Debian-based
CFL Forensics on an **Ubuntu 24.04 LTS ("noble")** base. This note records the
substantive differences and the reasoning, so the build stays maintainable.

## 1. Base distribution & build method

| | Debian original | Ubuntu build (this project) |
|---|---|---|
| Base | Debian 13 "trixie" | Ubuntu 24.04 LTS "noble" |
| Build tool | `live-build` (`lb config`/`lb build`) | **from-scratch `debootstrap`** driven by `build.sh` |
| Live system | `live-boot` / `live-config` | **`casper`** (Ubuntu's live system) |
| Installer | Calamares (Debian settings) | Calamares 3.3.5 (our own settings) |
| Kernel | `linux-image-amd64` | `linux-generic-hwe-24.04` (HWE) |

**Why drop `live-build`?** `live-build` is a Debian tool; targeting Ubuntu's
archive, `casper`, and Ubuntu's signed-GRUB layout through it means fighting its
assumptions. A direct `debootstrap` + `chroot` + `mksquashfs` + `xorriso`
pipeline is explicit, resumable, and matches how Ubuntu itself builds images.
`build.sh` implements it as eleven stamped stages (`bootstrap`, `apt`, `base`,
`desktop`, `packages`, `overlay`, `hooks`, `finalize`, `squashfs`, `bootloader`,
`iso`); a re-run continues from the last completed stage.

## 2. Packages that changed name or source

Only 17 package names from the Debian tool lists do not exist in the Ubuntu
archive. Each was resolved:

| Debian package | Ubuntu resolution |
|---|---|
| `firmware-linux-free`, `firmware-misc-nonfree`, `firmware-iwlwifi`, `firmware-atheros`, `firmware-brcm80211`, `firmware-realtek`, `firmware-amd-graphics` | all replaced by the single **`linux-firmware`** package |
| `firefox-esr` | **Firefox `.deb` from `packages.mozilla.org`** (Ubuntu's own `firefox` is a snap; see §4) |
| `linux-headers-amd64` | `linux-headers-generic-hwe-24.04` |
| `gnome-shell-extension-dashtodock` | `gnome-shell-extension-ubuntu-dock` (ships the same `org.gnome.shell.extensions.dash-to-dock` schema; UUID `ubuntu-dock@ubuntu.com`) |
| `gnome-shell-extension-arc-menu` | not packaged in Ubuntu → installed from **extensions.gnome.org / GitLab** by the theme hook |
| `recon-ng`, `waymore` | installed via **`pipx`** (the hook) |
| `assetfinder`, `exiflooter` | installed from **upstream GitHub releases** (the hook) |
| `forensics-extra`, `libphdi-utils` | do not exist anywhere → **dropped** (their tools are covered elsewhere; `forensics-all` remains) |

`plaso` is present in the Ubuntu archive but very old (2020), so it too is
installed via `pipx` for a current release. Every remaining package name in
`config/package-lists/*.list` is verified against the live archive by
`scripts/verify-packages.sh`.

## 3. GNOME Shell extension UUIDs

Ubuntu's extension packages use different UUIDs from Debian's, so the dconf
defaults (`/etc/dconf/db/local.d/01-cfl-forensics`) and the pruning hook were
updated:

| Role | Debian UUID | Ubuntu UUID |
|---|---|---|
| Dock | `dash-to-dock@micxgx.gmail.com` | `ubuntu-dock@ubuntu.com` |
| App indicators | `appindicatorsupport@rgcjonas.gmail.com` | `ubuntu-appindicators@ubuntu.com` |
| Desktop icons | `ding@rastersoft.com` | `ding@rastersoft.com` (same) |
| User theme | `user-theme@…gcampax.github.com` | same |
| ArcMenu | `arcmenu@arcmenu.com` | same (installed from upstream) |

The dock's dconf *schema path* is unchanged (`ubuntu-dock` ships the
dash-to-dock schema id), so the styling block did not need rewriting.

## 3a. The CFL tools menu - two mechanisms, and the terminal launchers

**Menu.** Vanilla GNOME has no traditional application-menu tree, so the CFL
tool categories are surfaced two ways:

- **GNOME app-grid folders** (always present, no extension needed): dconf
  defines one `org.gnome.desktop.app-folders` folder per CFL category, and each
  collects the launchers carrying the matching `X-CFL-*` category. Open the app
  grid and the 14 folders (Acquisition and Imaging, Memory Forensics, …) are
  there.
- **ArcMenu** (the "CFL MENU" button, when installed) renders the full
  *Forensic Tools* tree from the XDG `.menu` file. ArcMenu is not in the Ubuntu
  archive, so the theme hook fetches the build for the running GNOME Shell
  version from extensions.gnome.org (using the `extension-info` API to pick the
  right `version_tag`), falling back to the newest GitLab tag whose
  `metadata.json` declares support for that shell. The outcome is recorded in
  `/usr/share/cfl-forensics/ARCMENU-STATUS.txt`. If it is absent, the app-grid
  folders still give a categorised menu.

**Terminal launchers.** Every CLI tool opens through `cfl-run`, which shows the
tool's usage and then leaves an interactive shell in the same window for the
real command. Two details make this hang-proof: the usage probe runs with
**stdin closed and a timeout** (tools like `strings`/`md5sum` otherwise wait on
stdin forever), and the window is kept open by the *shell*, not by the terminal
profile - `exit-action` is `close`. It must never be `hold` (that produces the
"child process exited … Relaunch" bar) or `restart` (re-runs the tool in a
loop).

**Boot splash.** There is none: `splash` is absent from every kernel command
line, so the boot is quiet with no graphical logo screen.

## 4. No snaps

Forensic workstations should not silently auto-refresh packaged applications,
and snaps cannot run from a read-only squashfs without a writable `snapd` state
anyway. `snapd` is pinned to priority `-10` (build-time and on the installed
system), the vanilla `gnome-session`/`gnome-shell`/`gdm3` stack is installed
explicitly instead of `gnome-core` (which pulls snapd), and **Firefox comes
from Mozilla's APT repository** as a real `.deb`.

## 5. Live session: `casper`, not root autologin

The Debian build logged the live session in as **root**. Ubuntu's `casper`
creates an unprivileged live user via `user-setup`, so that model does not carry
over. Instead:

- The live user is **`cfl`** (uid 1000), created by casper (`casper.conf` sets
  `FLAVOUR` so the configured username/hostname are honoured).
- **`cfl-live.service`** (guarded by `ConditionKernelCommandLine=boot=casper`,
  so it never runs on an installed system) grants the live user passwordless
  sudo and writes a runtime polkit rule to `/run` allowing `pkexec` GUI tools
  without a prompt.
- CLI tools launch through **`cfl-run`** (auto-elevates and keeps the terminal
  open); root GUI tools launch through **`cfl-run-gui`** (`pkexec` with the X
  environment preserved). Guymager uses `cfl-run-gui guymager`.
- These live-only permissions are stripped from any installed system by the
  Calamares finish script.

## 6. Forensic hardening of casper

Two casper behaviours are unsafe for evidence handling and are corrected in the
`finalize` stage:

- **`casper-bottom/13swap`** activates *every* swap partition it finds on
  internal disks at boot - a write to potential evidence. It is diverted out of
  the initramfs.
- casper's medium search mounts candidate internal partitions read-only but
  **without `noload`/`norecovery`**, so a dirty ext4/xfs/btrfs journal could be
  replayed (a write). The `casper` script is patched to route those mounts
  through a `cfl_ro_mount` helper that adds `noload`/`norecovery`/`nologreplay`.

In addition, automatic mounting of attached media is disabled in dconf
(`automount=false`, `autorun-never=true`), and software write-blocking is
enabled at boot by default (`forensics-mode on`, opt out with the
`cfl-forensic-mode=off` kernel argument).

## 7. Boot & Secure Boot

- The ISO is a hybrid BIOS/UEFI image assembled with `xorriso` (Ubuntu 22.04+
  recipe): a BIOS El Torito core image whose embedded config finds the medium by
  `/.disk/info`, plus an **appended EFI system partition** carrying the signed
  boot chain.
- **Secure Boot**: `EFI/boot/bootx64.efi` is the Microsoft-signed **shim**,
  which loads the Canonical-signed **`gcdx64.efi.signed`** GRUB, which loads the
  signed kernel. This works because the signed GRUB's built-in prefix is
  `/EFI/ubuntu` on the installed system - hence the installer registers its EFI
  entry under the name **`ubuntu`** (`efiBootloaderId: ubuntu` in
  `bootloader.conf`). The human-readable menu title is set separately via
  `GRUB_DISTRIBUTOR="CFL Forensics"`.
- The installer's finish script copies the signed shim chain to
  `EFI/BOOT/BOOTX64.EFI` **only when the firmware has no other bootloader
  there**, so an existing Windows/other bootloader for dual-boot is never
  overwritten.

## 8. Calamares 3.3.5 configuration

Ubuntu's Calamares package ships no `/etc/calamares` - the whole configuration
is ours, written to the 3.3 schema:

- `unpackfs` reads `/cdrom/casper/filesystem.squashfs` (casper's mount point),
  not Debian live's `/run/live/medium`.
- `mount.conf` uses the 3.3 `mountOptions` list form and binds
  `/run/systemd/resolve` (matching Ubuntu's own reference config).
- Install alongside is pre-selected (`initialPartitioningChoice: alongside`),
  and the `welcome` module's `requiredStorage` sets the floor so CFL Forensics
  can never be given less than the configured **@INSTALL_MIN_GIB@ GiB**.
- Two `shellprocess` instances run just before and after the bootloader stage - 
  one ensures the target has a kernel + initrd present (the live kernel lives on
  the ISO under `/casper`, not inside the squashfs), the other handles the EFI
  fallback and removes the live-only files.

## 7a. GRUB packages and the Secure-Boot chain

Getting both a BIOS El Torito image and a Secure-Boot UEFI chain from one build
needs a specific, conflict-free GRUB package set:

- **`grub-pc-bin`** - the BIOS (i386-pc) GRUB modules used to build the El Torito
  core image. This is the *modules* package, not the `grub-pc` meta.
- **`grub-efi-amd64`** + **`grub-efi-amd64-bin`** - the UEFI GRUB, and the meta
  that satisfies `grub-efi-amd64-signed`'s `grub-efi-amd64 | grub-pc` dependency.
- **`grub-efi-amd64-signed`** + **`shim-signed`** (+ its deps `sbsigntool`,
  `grub2-common`, `mokutil`) - the Canonical-signed GRUB and Microsoft-signed
  shim for Secure Boot.

The trap: the **`grub-pc` meta Conflicts with `grub-efi-amd64`**. If both are
listed, apt resolves the conflict by dropping `grub-efi-amd64-signed` - and with
it `shim-signed` - so the bootloader stage then fails with "shim-signed is
missing from the chroot". `grub-pc-bin` (modules) does **not** conflict with
`grub-efi-amd64`, so the two coexist and give BIOS + UEFI from one image. The
static check `scripts/test-release.sh` enforces this (a listed `grub-pc` meta is
flagged), and the build's grub postinsts are kept inert in the chroot by
diverting `grub-install`/`update-grub` to stubs (restored at finalize).

## 8a. DKMS kernel modules (LiME) and the HWE kernel

`lime-forensics-dkms` compiles a kernel module (LiME, for live memory
acquisition) at install time. Two things make this robust in the build:

- The image ships `/etc/dkms/no-autoinstall-errors`, so a DKMS module that
  fails to compile against some kernel is **never fatal** - neither during the
  image build nor later on the installed system. During the package stages
  `/etc/dkms/no-autoinstall` is also set, so modules install source-only and
  nothing is built mid-transaction (a failed build there would otherwise poison
  the whole apt batch). The `finalize` stage then does one explicit build pass
  against the target kernel and records the result in
  `/usr/share/cfl-forensics/DKMS-STATUS.txt`.
- **Kernel choice matters for LiME.** The default HWE kernel
  (`linux-generic-hwe-24.04`) rolls forward and can be newer than the LiME
  version in the Ubuntu archive (1.9.1), in which case LiME will not compile and
  is shipped as source only. If pre-built LiME is important, build with the GA
  kernel, which the archive's LiME is guaranteed to match:

  ```bash
  sudo KERNEL_PKG=linux-generic ./build.sh
  ```

  The trade-off is that the GA kernel (24.04's 6.8 series) has less support for
  very new hardware than the HWE kernel. For a live distro that must boot on
  arbitrary machines, HWE is the default; switch to GA when in-image LiME
  outweighs newest-hardware boot support. (Memory can still be acquired without
  LiME - e.g. AVML, or `/proc/kcore`-based methods - if LiME is unavailable.)

## 9. What can only be tested on a real host

`scripts/test-release.sh` validates everything that can be checked statically
(script syntax, shellcheck, GRUB menu syntax, all Calamares YAML, desktop
entries, package-list hygiene, referenced files, Calamares sequence integrity),
and the `xorriso`/EFI assembly recipe has been dry-run. The **full build**
(`debootstrap` of a real root filesystem, package installation, squashfs, final
ISO) must run on an Ubuntu, Debian or Parrot host with root and ~30 GB free. On a
non-Ubuntu host, install the Ubuntu archive keyring first with
`sudo ./scripts/fetch-ubuntu-keyring.sh` (Debian/Parrot do not package
`ubuntu-keyring`); `build.sh` also offers to fetch it automatically. Boot-test
the result with `scripts/test-iso-qemu.sh`.

---

*Computer Forensics Lab Ltd - @CFL_URL@*
