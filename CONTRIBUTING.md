# Contributing to CFL Forensics

Thank you for helping improve a tool that examiners rely on. Because this
image is used for evidence handling, changes are held to a high bar for
correctness - but the process is simple.

## Before you start

- **Bug in the built image?** Open an issue with the *Bug report* template. Include
  the image version (`cat /etc/cfl-forensics-release`), how you booted (live/installed,
  BIOS/UEFI, Secure Boot on/off) and the relevant file from `/usr/share/cfl-forensics/`
  (`TOOL-HEALTH.txt`, `DKMS-STATUS.txt`, `ARCMENU-STATUS.txt`).
- **Want a tool added?** Use the *Tool request* template. Say which category it belongs
  in and whether it is packaged in Ubuntu, on PyPI, or only on GitHub.
- **Build problem?** Attach `work/build.log` and the output of `./scripts/test-release.sh`.

## Making a change

1. Fork and branch from `main`.
2. Make the change in the right place:
   - **Ubuntu package** → the matching file in `config/package-lists/`. Run
     `./scripts/verify-packages.sh` to confirm the name exists in the archive.
     Never list a snap-stub (`firefox`, `thunderbird`, `chromium-browser`) - see
     `docs/UBUNTU-PORT-NOTES.md` §4.
   - **PyPI tool** → `config/hooks/0300-pipx-tools.hook`.
   - **GitHub / upstream tool** → `config/hooks/0400-upstream-tools.hook` or
     `0450-script-tools.hook` (use the `gitpy` helper).
   - **Menu entry** → one `config/includes.chroot/usr/share/applications/cfl-<tool>.desktop`
     in the existing format, carrying the right `X-CFL-*` category. CLI tools launch
     through `cfl-run`; root GUI tools through `cfl-run-gui`.
   - **Build pipeline** → `build.sh`; **installer** → `config/calamares/`;
     **boot menu** → `config/bootloaders/grub/`.
3. Run the static suite - it is what CI runs and takes seconds:
   ```bash
   ./scripts/test-release.sh
   ```
   It covers shell syntax, shellcheck, calls to undefined functions, GRUB menu
   syntax, all Calamares YAML, desktop entries, package-list hygiene (snap stubs,
   GRUB conflicts), terminal-launcher safety and the CFL menu folders.
4. For anything that touches the build pipeline, the live session, the installer or
   boot, **do a real build and boot test** (`sudo ./build.sh`, then
   `./scripts/test-iso-qemu.sh --uefi`). Say in the PR what you tested and on what host.
5. Open a pull request using the template. Keep it to one logical change.

## Ground rules that keep the image trustworthy

- **Never weaken an evidence-safety default** (write-blocking, no automount, no
  swap activation, no journal replay, UTC) without discussion in an issue first.
- **No snaps.** Snaps auto-refresh and cannot run from a read-only squashfs.
- **No proprietary or unlicensed software** in the image (Maltego, VeraCrypt binaries,
  unlicensed case-management tools, …). Free alternatives are listed in
  `docs/PARROT-CSI-PARITY.md`.
- **Reproducibility over convenience.** Prefer archive packages to upstream builds,
  and pin or verify anything fetched at build time.
- **Don't break Secure Boot.** The EFI chain is shim → signed GRUB → signed kernel;
  the installer must keep `efiBootloaderId: ubuntu`.

## Style

Shell scripts: `bash`, `set -euo pipefail`, shellcheck-clean at `-S warning`
(hooks at `-S error`). Prefer editing an existing package list or hook to adding
a new file. Comments should explain *why*, especially anywhere the reason is a
forensic or boot-chain subtlety.

## Releasing (maintainers)

1. Bump `CFL_VERSION` in `cfl-build.conf`; update `CHANGELOG.md`.
2. Clean build on an Ubuntu 24.04 host: `sudo ./build.sh --clean`.
3. Boot-test BIOS, UEFI and UEFI + Secure Boot in QEMU, and one real machine.
4. Tag `vX.Y`, create a GitHub Release, attach `SHA256SUMS`, the `.manifest`,
   `.tool-health.txt` and `.packages-skipped.txt`. Host the ISO on the CFL download
   server (it exceeds GitHub's per-file release limit) and link it from the release.
