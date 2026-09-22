# Build guide - creating the CFL Forensics ISO with `build.sh`

This is the step-by-step guide to producing the bootable image from source.
It covers what the script does, what you need, how to run it, what to expect
at each stage, how to resume or rebuild, and how to fix the problems that
actually come up.

## 1. What `build.sh` does

`build.sh` builds the whole image from scratch - no `live-build`, no
pre-made base. It runs eleven stages in order and leaves a stamp after each,
so a build that stops can be resumed from where it was:

| # | Stage | What happens |
|---|---|---|
| 1 | `bootstrap` | `debootstrap` a minimal Ubuntu 24.04 root filesystem into `work/chroot` |
| 2 | `apt` | write the Ubuntu archive sources, pin out `snapd`, upgrade |
| 3 | `base` | `ubuntu-minimal`/`standard`, the kernel, casper (live boot), GRUB + shim (Secure Boot), firmware |
| 4 | `desktop` | GNOME on Xorg, shell extensions, workstation apps, **Firefox** (three sources, verified) |
| 5 | `packages` | every forensic tool list in `config/package-lists/` |
| 6 | `overlay` | copy `config/includes.chroot/` in; generate casper/GDM/locale/GRUB configs; the Calamares installer config |
| 7 | `hooks` | run `config/hooks/*.hook` in the chroot: theme + Apps menu, Ghidra, pipx tools, upstream builds, menu wiring, tool health check |
| 8 | `finalize` | casper hardening, DKMS modules, locales, cleanup, build the live initramfs |
| 9 | `squashfs` | compress the root filesystem to `casper/filesystem.squashfs` |
| 10 | `bootloader` | BIOS El Torito image, Secure-Boot EFI image, GRUB menu and theme |
| 11 | `iso` | `.disk` metadata, checksums, and the hybrid BIOS/UEFI ISO via `xorriso` |

`sudo ./build.sh --list-stages` prints this order.

## 2. What you need

| Requirement | Detail |
|---|---|
| **Host OS** | Ubuntu 22.04/24.04, Debian 12+, or Parrot OS (amd64). Other distros work if `debootstrap`, `xorriso` and `squashfs-tools` are available. |
| **Privileges** | root (`sudo`). The build mounts filesystems and runs a chroot. In Docker/LXC the container must be privileged. |
| **Disk** | ~30 GB free under the project directory (`work/` holds the chroot; `cache/` the downloaded `.deb`s). |
| **RAM** | 4 GB minimum; 8 GB comfortable (squashfs compression is memory-hungry). |
| **Network** | Broadband. The build downloads ~3–4 GB of packages plus tools from Mozilla, GitHub, PyPI and extensions.gnome.org. |
| **Time** | 45–120 minutes on a fast machine and connection; longer on the first run. |

## 3. Step by step

### 3.1 Install the host tools

```bash
sudo apt-get update
sudo apt-get install -y debootstrap xorriso squashfs-tools rsync \
                        grub-pc-bin grub-efi-amd64-bin mtools dosfstools
```

### 3.2 The Ubuntu archive keyring (Debian / Parrot hosts only)

Building an Ubuntu image requires Ubuntu's archive signing key. On Ubuntu it
is already present. **Debian and Parrot do not package it**, so fetch it:

```bash
sudo ./scripts/fetch-ubuntu-keyring.sh
```

(This downloads the official `ubuntu-keyring` package from the Ubuntu pool,
checks it is a real GPG keyring, and installs
`/usr/share/keyrings/ubuntu-archive-keyring.gpg`. `build.sh` will also offer
to do this itself if it finds the keyring missing.)

### 3.3 Get the source

```bash
git clone https://github.com/jnaghdi/CFL-Digital-Forensics-Ubuntu-24.04-Bootable-Toolkit-ISO-maker.git
cd CFL-Digital-Forensics-Ubuntu-24.04-Bootable-Toolkit-ISO-maker
```

or unpack the release archive and `cd` into it. Make the scripts executable if
your archive tool dropped the bits: `chmod +x build.sh scripts/*.sh config/hooks/*.hook`.

### 3.4 (Optional) adjust the configuration

Everything tunable is in `cfl-build.conf`, and any setting can be overridden
from the environment for one build. The ones people change:

| Setting | Default | Notes |
|---|---|---|
| `CFL_VERSION` | `2.0` | image version and ISO filename |
| `KERNEL_PKG` | `linux-generic-hwe-24.04` | HWE kernel (best new-hardware support). Use `linux-generic` (the 6.8 GA series) if the LiME memory module must be pre-built - see §6. |
| `LIVE_USER` / `LIVE_HOSTNAME` | `cfl` / `cfl-forensics` | live session identity |
| `LIVE_LOCALE` / `LIVE_KEYMAP` / `LIVE_TIMEZONE` | `en_GB.UTF-8` / `gb` / `Etc/UTC` | UTC is the forensic convention |
| `INSTALL_MIN_GIB` | `128` | space the installer reserves for CFL Forensics |
| `SQUASH_COMP` | `zstd` | `xz` makes a smaller ISO but a slower boot |
| `MIRROR` | archive.ubuntu.com | set a local mirror to speed up rebuilds |

Example: `sudo CFL_VERSION=2.1 KERNEL_PKG=linux-generic ./build.sh`

### 3.5 Pre-flight checks (seconds, no root)

```bash
./scripts/test-release.sh      # ~110 static checks: syntax, shellcheck, undefined
                               # functions, GRUB menu, Calamares YAML, launchers,
                               # package-list hygiene, menu folders - must end FAIL=0
./scripts/verify-packages.sh   # every package name resolves in the Ubuntu archive
```

Run these after any edit to the lists, hooks or configs - they catch most
problems before you spend an hour building.

### 3.6 Build

```bash
sudo ./build.sh
```

Output goes to the terminal and to `work/build.log`. Each stage prints a
`==> [stage]` banner. Warnings (`WARN:`) are non-fatal and worth reading
afterwards; only `ERROR:` stops the build.

### 3.7 What you get

```
iso/cfl-forensics-2.0-noble-amd64.iso                 the image
iso/SHA256SUMS, iso/MD5SUMS                            checksums
iso/cfl-forensics-2.0-noble-amd64.manifest             every package + version in the image
iso/cfl-forensics-2.0-noble-amd64.tool-health.txt      per-tool build-time health check
iso/cfl-forensics-2.0-noble-amd64.packages-skipped.txt anything that could not be installed (if any)
```

Inside the image, `/usr/share/cfl-forensics/` also holds `TOOL-HEALTH.txt`,
`DKMS-STATUS.txt` (kernel modules) and `ARCMENU-STATUS.txt` (the Apps menu
extension).

## 4. Resuming, rebuilding, debugging

| Command | Effect |
|---|---|
| `sudo ./build.sh` | continue - finished stages are skipped |
| `sudo ./build.sh --from packages` | re-run from a stage onward (after editing a package list) |
| `sudo ./build.sh --from overlay` | after editing `config/includes.chroot/`, dconf or the Calamares config |
| `sudo ./build.sh --from hooks` | after editing a hook |
| `sudo ./build.sh --from bootloader` | after editing the GRUB menu/theme |
| `sudo ./build.sh --clean` | wipe `work/` and start again (keeps the download cache) |
| `sudo ./build.sh --shell` | open a root shell inside the chroot to inspect it |
| `sudo ./build.sh --strict` | abort on any failing hook or uninstallable package (default: warn and continue) |
| `sudo ./build.sh --skip-hooks` | skip the hooks - quick turnaround while testing packaging |

Which stage to restart from: the change decides it (see the table in §1).
Anything from `overlay` onward is fast; `packages` re-installs the tool lists;
`base` reinstalls the boot chain.

## 5. Testing the ISO

```bash
sudo apt-get install -y qemu-system-x86 ovmf                 # once
./scripts/test-iso-qemu.sh iso/cfl-forensics-*.iso            # BIOS
./scripts/test-iso-qemu.sh --uefi iso/cfl-forensics-*.iso     # UEFI
./scripts/test-iso-qemu.sh --uefi --secureboot iso/cfl-*.iso  # UEFI + Secure Boot
```

The script creates a blank 160 GB scratch disk so you can walk through
*Install alongside* in the VM. Then write a real stick:

```bash
sudo ./scripts/write-usb.sh iso/cfl-forensics-*.iso /dev/sdX   # DESTRUCTIVE
```

and boot at least one physical machine - ideally one with Secure Boot on.

## 6. Troubleshooting - the problems that actually occur

**`Ubuntu archive keyring not found`** (Debian/Parrot hosts)
Run `sudo ./scripts/fetch-ubuntu-keyring.sh` (§3.2). `apt-get install ubuntu-keyring` does *not* work on Debian/Parrot - the package isn't in their repos.

**`debootstrap has no 'noble' script - linking it`**
A notice, not an error: older `debootstrap` lacks a `noble` entry, so the build links it to the generic Ubuntu script. Continue.

**`firefox : PreDepends: snapd but it is not installable`**
Someone added `firefox`/`thunderbird`/`chromium-browser` to a package list. In the Ubuntu archive those are stubs that install the snap, and this image pins `snapd` out. Remove them from the list - Firefox is installed by the `desktop` stage from Mozilla directly. `test-release.sh` flags this.

**`Error! Bad return status for module build … lime-forensics-dkms`**
The LiME kernel module could not compile against the kernel. This is **not fatal**: the module ships as source, the build continues, and the outcome is in `DKMS-STATUS.txt`. It happens when the rolling HWE kernel is newer than the archive's LiME. If pre-built LiME matters, build with the GA kernel: `sudo KERNEL_PKG=linux-generic ./build.sh --from bootstrap`.

**`shim-signed did not install`** at the `bootloader` stage
A GRUB package conflict: `grub-pc` (the meta) conflicts with `grub-efi-amd64`, which makes apt drop the signed GRUB and shim. The boot list must contain `grub-pc-bin` + `grub-efi-amd64` (+ `-bin`, `-signed`, `shim-signed`), never `grub-pc`. `test-release.sh` flags this. Fix the list, then `--from base`.

**`command not found` for a `xxx_yyy` helper mid-build**
A function is called but not defined in `build.sh`. `./scripts/check-undefined-functions.sh build.sh` finds it; `test-release.sh` runs this check.

**A hook failed** (`WARN: hook … failed - build continues`)
Hooks fetch from GitHub/PyPI/extensions.gnome.org and are best-effort. Read `work/hooks/<name>.log`; usually a transient network failure. Re-run just that stage: `sudo ./build.sh --from hooks` (stamps for hooks that succeeded are kept). Use `--strict` if you want a failing hook to stop the build.

**`NO BROWSER could be installed`**
All three Firefox sources failed - the host almost certainly has no route to Mozilla/Launchpad. Check the network and `--from desktop`.

**`less than 25 GiB free`** / build dies during `squashfs`
Free space or move the project to a bigger disk; `sudo ./build.sh --clean` and rebuild.

**Build inside Docker fails at `bootstrap`/`mount`**
The container must run `--privileged` (the build mounts `/proc`, `/sys`, `/dev` into the chroot).

**Interrupted build** (Ctrl-C, power loss)
Just run `sudo ./build.sh` again. The chroot mounts are cleaned on exit; finished stages are skipped.

## 7. Verifying and publishing

Every release should be verifiable end to end:

```bash
cd iso && sha256sum -c SHA256SUMS                 # the image
./scripts/make-hashset.sh                          # hash set of the build source (hashes/)
```

`hashes/` contains SHA-256/SHA-1/MD5 sets for every source file and a
hashdeep-format file, so anyone can confirm the build system they received is
the one that produced the image. See `CONTRIBUTING.md` (*Releasing*) for the
tag-and-release procedure, and `docs/GITHUB-UPLOAD-CHECKLIST.md` for what to
publish where.
