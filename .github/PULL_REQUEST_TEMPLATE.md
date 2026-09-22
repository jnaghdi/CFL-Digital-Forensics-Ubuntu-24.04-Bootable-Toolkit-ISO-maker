## What this changes

## Why

## Type
- [ ] Package list / tool addition
- [ ] Launcher / menu
- [ ] Build pipeline (`build.sh`, hooks)
- [ ] Installer (Calamares) or boot (GRUB / casper)
- [ ] Docs only

## Checks
- [ ] `./scripts/test-release.sh` passes locally
- [ ] `./scripts/verify-packages.sh` passes (if package lists changed)
- [ ] Real build + boot test done (required for pipeline / installer / boot changes):
      host: ______  boot: BIOS / UEFI / UEFI+Secure Boot
- [ ] No evidence-safety default weakened (write-blocking, automount, swap, journal replay, UTC)
- [ ] No snap, proprietary or unlicensed software introduced
