# Customising CFL Forensics

All settings live in [`cfl-build.conf`](../cfl-build.conf); anything there can
also be set from the environment for a one-off build.

## Change the Ubuntu release or kernel

```bash
sudo UBUNTU_SUITE=oracular ./build.sh          # a different Ubuntu series
sudo KERNEL_PKG=linux-generic ./build.sh       # GA kernel instead of HWE
```

Package names move between Ubuntu series. Run
`UBUNTU_SUITE=oracular ./scripts/verify-packages.sh` first and adjust any names
it flags before building.

## Version, live user, locale, install size

Edit `cfl-build.conf` (or export the variable):

- `CFL_VERSION` - image version and ISO filename.
- `LIVE_USER`, `LIVE_USER_FULLNAME`, `LIVE_HOSTNAME` - the live session identity.
- `LIVE_LOCALE`, `LIVE_KEYMAP`, `LIVE_TIMEZONE` - defaults (UTC is the forensic
  convention; change `LIVE_TIMEZONE` only if you have reason to).
- `INSTALL_MIN_GIB` - the disk space the installer reserves for CFL Forensics
  (the `requiredStorage` floor is derived from this automatically).
- `SQUASH_COMP` - `zstd` (fast boot, default) or `xz` (smallest image).
- `WAYLAND` - `0` for GNOME on Xorg (default; best for root GUI tools), `1` for
  Wayland.

## Theme variants

Edit `config/hooks/0100-whitesur-theme.hook`:

- accent colours: change `./install.sh -t all` (e.g. `-t blue -t purple`;
  choices: default|blue|purple|pink|red|orange|yellow|green|grey).
- panel transparency/height: add `--shell -p 45 -h smaller` to the installer call.
- Monterey-style titlebar: add `-m`.

For a **light desktop by default**, edit
`config/includes.chroot/etc/dconf/db/local.d/01-cfl-forensics`: set
`gtk-theme='WhiteSur-Light'`, user-theme `name='WhiteSur-Light'`,
`color-scheme='default'`, `icon-theme='WhiteSur'`.

Dock size/behaviour lives in the `[org/gnome/shell/extensions/dash-to-dock]`
section of the same file (`dash-max-icon-size`, `autohide`, `click-action`, …).
ArcMenu "CFL MENU" styling is in the `[org/gnome/shell/extensions/arcmenu]`
section.

## Add or remove tools

- **Ubuntu packages** - append to the matching file in `config/package-lists/`
  (one package per token; `#` starts a comment). Verify with
  `./scripts/verify-packages.sh`. A list whose first line is `#!no-recommends`
  is installed with `--no-install-recommends`.
- **Upstream (non-archive) tools** - extend `config/hooks/0400-upstream-tools.hook`;
  keep installs under `/opt/tools` and log to
  `/var/log/cfl-forensics/third-party-tools.log`. Script-style Python tools
  (git clone + venv + wrapper) belong in `config/hooks/0450-script-tools.hook`
- reuse its `gitpy` helper. `pipx` tools go in `config/hooks/0300-pipx-tools.hook`.

## Menu entries (Forensic Tools)

- **Launcher files**: `config/includes.chroot/usr/share/applications/cfl-*.desktop`
  (one per tool). CLI tools open through `cfl-run`, which shows the tool's usage (probed with stdin closed and a timeout, so nothing can hang) and then leaves a live shell in the same window for the real command; the terminal profile's `exit-action` is `close`, never `hold` (that produces the "child process exited… Relaunch" bar); root GUI
  tools run through `cfl-run-gui` (pkexec, X preserved).
- **Menu structure**:
  `config/includes.chroot/etc/xdg/menus/applications-merged/cfl-forensics.menu`
  and `config/includes.chroot/usr/share/desktop-directories/cfl-*.directory`. A
  tool lands in a submenu when its `.desktop` file carries the matching
  `X-CFL-*` category.
- The `0600-forensics-menu.hook` also moves packaged GUI apps into the tree, and
  `0700-verify-tools.hook` deletes launchers whose binary is missing at build
  time - add your tool to a package list or hook and drop in one `.desktop`
  file, nothing else needed.

## The installer (Calamares)

Configuration is under `config/calamares/`:

- `settings.conf` - the module sequence (which pages are shown, which jobs run).
- `modules/*.conf` - individual module settings (partitioning defaults, package
  removal, users, bootloader, …).
- `branding/cfl/` - the installer's logo, welcome image, slideshow and colours.

Changing `INSTALL_MIN_GIB` in `cfl-build.conf` is the supported way to adjust
the reserved install size; the `welcome.conf` `requiredStorage` value is
substituted from it at build time.

## Shrink the ISO

The biggest items are `gimp`, `libreoffice-*`, `vlc`, the JRE/JDK (needed by
Ghidra), Firefox, and the wordlist packages pulled in by `forensics-all`.
Removing entries from `config/package-lists/0100-desktop.list` (or a category
list) and rebuilding can save ~1 GB. Switching `SQUASH_COMP=xz` in
`cfl-build.conf` shrinks the squashfs further at the cost of a slower boot.

## Boot menu

The ISO menu, theme and kernel command line are in
`config/bootloaders/grub/grub.cfg`; the loop-mount entry (Ventoy etc.) is in
`loopback.cfg`. After editing, `./scripts/test-release.sh` runs
`grub-script-check` over both.
