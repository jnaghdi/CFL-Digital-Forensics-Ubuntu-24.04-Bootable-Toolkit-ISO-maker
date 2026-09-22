---
name: Bug report
about: Something in the built image or the build does not work
title: ''
labels: bug
assignees: ''
---

**Image / commit**
Output of `cat /etc/cfl-forensics-release` (or the git commit if it is a build problem).

**How you booted**
- [ ] Live from USB   - [ ] Live from DVD   - [ ] Installed (dual-boot)
- Firmware: BIOS / UEFI - Secure Boot on / off
- Hardware (make/model) or VM (QEMU/VirtualBox/VMware):

**What happened**
A clear description, with the exact command or menu entry used.

**What you expected**

**Relevant files** (attach or paste)
- `/usr/share/cfl-forensics/TOOL-HEALTH.txt`
- `/usr/share/cfl-forensics/DKMS-STATUS.txt` / `ARCMENU-STATUS.txt` (if relevant)
- for build problems: `work/build.log` and the output of `./scripts/test-release.sh`

**Evidence-safety impact**
Did this cause, or could it cause, a write to an attached or internal disk? If yes,
please report privately instead - see SECURITY.md.
