#!/usr/bin/env bash
# =============================================================================
#  CFL Forensics - Ubuntu 24.04 LTS (noble) live + installer ISO builder
#  Computer Forensics Lab Ltd - cflab.uk / e-discovery.uk
#
#  One command:      sudo ./build.sh
#  Resume a build:   sudo ./build.sh --from hooks
#  Debug the chroot: sudo ./build.sh --shell
#
#  The image is assembled from scratch with debootstrap (no live-build):
#
#    bootstrap  debootstrap a minimal noble root filesystem
#    apt        Ubuntu archive sources, pins, build-time apt settings
#    base       ubuntu-minimal/standard, kernel, casper, GRUB/shim, firmware
#    desktop    vanilla GNOME on Xorg, shell extensions, Firefox (.deb)
#    packages   every forensic tool list in config/package-lists/
#    overlay    config/includes.chroot + generated system configuration
#    hooks      config/hooks/*.hook (theme, Ghidra, pipx tools, menus, ...)
#    finalize   Plymouth theme, casper hardening, initramfs, cleanup
#    squashfs   casper/filesystem.squashfs + manifests
#    bootloader BIOS El Torito image, Secure-Boot EFI image, GRUB menu/theme
#    iso        .disk metadata, checksums, hybrid BIOS/UEFI ISO (xorriso)
#
#  Every stage leaves a stamp in $WORK_DIR/stamps; a stage that already ran is
#  skipped, so an interrupted build continues where it stopped.
#
#  All tunables live in cfl-build.conf (or the environment).
# =============================================================================
set -euo pipefail

PROJECT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$PROJECT_DIR"

# shellcheck source=cfl-build.conf
. ./cfl-build.conf

STAGES=(bootstrap apt base desktop packages overlay hooks finalize squashfs bootloader iso)

# ----------------------------------------------------------------------------
# options
# ----------------------------------------------------------------------------
FROM_STAGE=""
DO_CLEAN=0
DO_SHELL=0
SKIP_HOOKS=0

usage() {
    cat <<EOF
usage: sudo ./build.sh [options]

  --clean            wipe $WORK_DIR (keeps $CACHE_DIR) and build from scratch
  --from STAGE       re-run from STAGE onwards (stages: ${STAGES[*]})
  --shell            open an interactive root shell inside the chroot and exit
  --strict           abort on any failing hook or uninstallable package
  --skip-hooks       skip config/hooks (quick rebuilds while testing packaging)
  --list-stages      print the stage order and exit
  -h, --help         this text

Environment/config: see cfl-build.conf (e.g. CFL_VERSION, MIRROR, KERNEL_PKG).
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --clean)        DO_CLEAN=1 ;;
        --from)         FROM_STAGE="${2:-}"; shift ;;
        --from=*)       FROM_STAGE="${1#--from=}" ;;
        --shell)        DO_SHELL=1 ;;
        --strict)       HOOK_STRICT=1; PACKAGE_STRICT=1 ;;
        --skip-hooks)   SKIP_HOOKS=1 ;;
        --list-stages)  printf '%s\n' "${STAGES[@]}"; exit 0 ;;
        -h|--help)      usage; exit 0 ;;
        *)              echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

# ----------------------------------------------------------------------------
# paths & logging
# ----------------------------------------------------------------------------
abs() { case "$1" in /*) printf '%s' "$1" ;; *) printf '%s/%s' "$PROJECT_DIR" "$1" ;; esac; }
WORK_DIR=$(abs "$WORK_DIR")
OUT_DIR=$(abs "$OUT_DIR")
CACHE_DIR=$(abs "$CACHE_DIR")
CHROOT="$WORK_DIR/chroot"
ISO_TREE="$WORK_DIR/iso-tree"
STAMPS="$WORK_DIR/stamps"
BUILD_LOG="$WORK_DIR/build.log"
BUILD_DATE=$(date -u +%Y%m%d)
# The source commit is stamped into the image (/etc/cfl-forensics-release and
# /.disk/info) so a booted system can always say which source built it.
SRC_COMMIT=$(git -C "$PROJECT_DIR" rev-parse --short=12 HEAD 2>/dev/null || echo "unversioned")
if [ "$SRC_COMMIT" != "unversioned" ] && ! git -C "$PROJECT_DIR" diff --quiet 2>/dev/null; then
    SRC_COMMIT="$SRC_COMMIT+modified"
fi
INSTALL_REQ_GIB=$((INSTALL_MIN_GIB - 2))   # Calamares adds ~2 GiB to requiredStorage
KERNEL_HEADERS_PKG="${KERNEL_PKG/linux-generic/linux-headers-generic}"

log()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33mWARN: %s\033[0m\n' "$*" >&2; }
die()  { printf '\033[1;31mERROR: %s\033[0m\n' "$*" >&2; exit 1; }

# ----------------------------------------------------------------------------
# chroot plumbing
# ----------------------------------------------------------------------------
CHROOT_MOUNTED=0

mount_chroot() {
    [ "$CHROOT_MOUNTED" = 1 ] && return 0
    mkdir -p "$CHROOT"/{dev/pts,proc,sys,run,var/cache/apt/archives} "$CACHE_DIR"
    mountpoint -q "$CHROOT/dev"     || mount --bind /dev "$CHROOT/dev"
    mountpoint -q "$CHROOT/dev/pts" || mount -t devpts devpts -o gid=5,mode=620,ptmxmode=666 "$CHROOT/dev/pts"
    mountpoint -q "$CHROOT/proc"    || mount -t proc proc "$CHROOT/proc"
    mountpoint -q "$CHROOT/sys"     || mount -t sysfs sysfs "$CHROOT/sys"
    mountpoint -q "$CHROOT/run"     || mount -t tmpfs tmpfs "$CHROOT/run"
    mountpoint -q "$CHROOT/var/cache/apt/archives" || mount --bind "$CACHE_DIR" "$CHROOT/var/cache/apt/archives"
    # name resolution inside the chroot; the finalize stage puts the
    # systemd-resolved symlink back and later stages need no network
    if ! stamped finalize; then
        rm -f "$CHROOT/etc/resolv.conf"
        cp -L /etc/resolv.conf "$CHROOT/etc/resolv.conf"
    fi
    CHROOT_MOUNTED=1
}

umount_chroot() {
    [ -d "$CHROOT" ] || return 0
    for m in var/cache/apt/archives run sys proc dev/pts dev; do
        if mountpoint -q "$CHROOT/$m" 2>/dev/null; then
            umount -l "$CHROOT/$m" 2>/dev/null || umount -R -l "$CHROOT/$m" 2>/dev/null || true
        fi
    done
    # anything a hook may have left mounted below the chroot
    awk -v c="$CHROOT/" 'index($2, c) == 1 { print $2 }' /proc/mounts | sort -r | while read -r m; do
        umount -l "$m" 2>/dev/null || true
    done
    CHROOT_MOUNTED=0
}

cleanup() {
    local rc=$?
    umount_chroot
    if [ "$rc" -ne 0 ]; then
        printf '\n\033[1;31mBuild failed (exit %s). Log: %s\033[0m\n' "$rc" "$BUILD_LOG" >&2
        printf 'Fix the problem and resume with:  sudo ./build.sh   (finished stages are skipped)\n' >&2
    fi
}
trap cleanup EXIT

# run a command inside the chroot with a clean, non-interactive environment
run_chroot() {
    mount_chroot
    chroot "$CHROOT" /usr/bin/env -i \
        HOME=/root TERM="${TERM:-xterm}" LANG=C.UTF-8 LC_ALL=C.UTF-8 \
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
        CFL_NAME="$CFL_NAME" CFL_VERSION="$CFL_VERSION" CFL_CODENAME="$CFL_CODENAME" \
        CFL_URL="$CFL_URL" UBUNTU_SUITE="$UBUNTU_SUITE" UBUNTU_VERSION="$UBUNTU_VERSION" \
        LIVE_USER="$LIVE_USER" LIVE_HOSTNAME="$LIVE_HOSTNAME" LIVE_LOCALE="$LIVE_LOCALE" \
        LIVE_KEYMAP="$LIVE_KEYMAP" LIVE_TIMEZONE="$LIVE_TIMEZONE" WAYLAND="$WAYLAND" \
        MOZILLA_APT="$MOZILLA_APT" PARALLEL="$PARALLEL" BUILD_DATE="$BUILD_DATE" \
        "$@"
}

apt_chroot() {  # apt_chroot install|remove|... [args]
    run_chroot apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold "$@"
}

# Replace a binary inside the chroot by a do-nothing stub for the duration of
# the build (kernel/grub postinst scripts must not touch the host or fail).
divert_stub() {
    local f="$1"
    [ -e "$CHROOT$f.cfl-divert" ] && return 0   # already diverted
    run_chroot dpkg-divert --local --rename --quiet --add --divert "$f.cfl-divert" "$f"
    printf '#!/bin/sh\n# CFL build-time stub - replaced by dpkg-divert, restored in the finalize stage\nexit 0\n' > "$CHROOT$f"
    chmod 0755 "$CHROOT$f"
}

undivert_stub() {
    local f="$1"
    rm -f "$CHROOT$f"
    run_chroot dpkg-divert --local --rename --quiet --remove "$f" || true
}

# substitute @TOKEN@ placeholders in a file
subst() {
    sed -i \
        -e "s|@CFL_NAME@|$CFL_NAME|g" \
        -e "s|@CFL_VERSION@|$CFL_VERSION|g" \
        -e "s|@CFL_CODENAME@|$CFL_CODENAME|g" \
        -e "s|@CFL_URL@|$CFL_URL|g" \
        -e "s|@CFL_PUBLISHER@|$CFL_PUBLISHER|g" \
        -e "s|@UBUNTU_SUITE@|$UBUNTU_SUITE|g" \
        -e "s|@UBUNTU_VERSION@|$UBUNTU_VERSION|g" \
        -e "s|@ARCH@|$ARCH|g" \
        -e "s|@LIVE_USER@|$LIVE_USER|g" \
        -e "s|@LIVE_USER_FULLNAME@|$LIVE_USER_FULLNAME|g" \
        -e "s|@LIVE_HOSTNAME@|$LIVE_HOSTNAME|g" \
        -e "s|@LIVE_LOCALE@|$LIVE_LOCALE|g" \
        -e "s|@LIVE_KEYMAP@|$LIVE_KEYMAP|g" \
        -e "s|@LIVE_TIMEZONE@|$LIVE_TIMEZONE|g" \
        -e "s|@INSTALL_MIN_GIB@|$INSTALL_MIN_GIB|g" \
        -e "s|@INSTALL_REQ_GIB@|$INSTALL_REQ_GIB|g" \
        -e "s|@INSTALL_TZ_REGION@|$INSTALL_TZ_REGION|g" \
        -e "s|@INSTALL_TZ_ZONE@|$INSTALL_TZ_ZONE|g" \
        -e "s|@ISO_VOLID@|$ISO_VOLID|g" \
        -e "s|@BUILD_DATE@|$BUILD_DATE|g" \
        "$@"
}

# package names from a list file (comments and blank lines stripped)
read_list() { sed -e 's/#.*//' "$1" | tr -s ' \t\n' '\n' | grep -v '^$' || true; }

# candidate packages available in the chroot's apt index (one apt call)
available_packages() {
    run_chroot apt-cache policy "$@" 2>/dev/null \
      | awk '/^[^ ]/ { name=$1; sub(":$", "", name) }
             /^  Candidate:/ { if ($2 != "(none)") print name }'
}

# install a package list; unavailable/uninstallable packages are logged and
# skipped unless PACKAGE_STRICT=1
install_list() {   # install_list <name> <recommends:0|1> pkg...
    local name="$1" recommends="$2"; shift 2
    local -a want=("$@") have=() missing=()
    local opt=""
    [ "$recommends" = 0 ] && opt="--no-install-recommends"
    [ ${#want[@]} -eq 0 ] && return 0

    mapfile -t have < <(available_packages "${want[@]}")
    local p
    for p in "${want[@]}"; do
        if ! printf '%s\n' "${have[@]}" | grep -qx "$p"; then
            missing+=("$p")
        fi
    done
    # Guard: drop any candidate that would drag in snapd (the Ubuntu snap-stub
    # packages such as firefox/thunderbird). snapd is pinned out, so apt would
    # otherwise abort the whole batch with "held broken packages". Real .debs
    # for these come from vendor repos (see stage_desktop); anything else is
    # skipped with a clear note rather than breaking the build.
    if [ ${#have[@]} -gt 0 ]; then
        local kept=() h
        for h in "${have[@]}"; do
            if run_chroot apt-cache depends "$h" 2>/dev/null | grep -qE '(Pre)?Depends:[[:space:]]*snapd'; then
                warn "[$name] $h pulls in snapd (snap-stub) - skipped (snaps are disabled on this image)"
                echo "$name snap-stub $h" >> "$WORK_DIR/packages-skipped.txt"
            else
                kept+=("$h")
            fi
        done
        have=("${kept[@]}")
    fi
    if [ ${#missing[@]} -gt 0 ]; then
        warn "[$name] not in the $UBUNTU_SUITE archive, skipped: ${missing[*]}"
        printf '%s\n' "${missing[@]}" | sed "s/^/$name unavailable /" >> "$WORK_DIR/packages-skipped.txt"
        [ "$PACKAGE_STRICT" = 1 ] && die "PACKAGE_STRICT=1 and packages are missing"
    fi
    [ ${#have[@]} -eq 0 ] && return 0

    info "[$name] installing ${#have[@]} packages"
    # shellcheck disable=SC2086
    if apt_chroot install $opt "${have[@]}"; then
        return 0
    fi
    warn "[$name] batch install failed - retrying package by package"
    for p in "${have[@]}"; do
        # shellcheck disable=SC2086
        if ! apt_chroot install $opt "$p" >/dev/null 2>&1; then
            warn "[$name] could not install $p"
            echo "$name failed $p" >> "$WORK_DIR/packages-skipped.txt"
            [ "$PACKAGE_STRICT" = 1 ] && die "PACKAGE_STRICT=1 and $p failed to install"
        fi
    done
}

# install every config/package-lists/<glob>.list
install_lists() {   # install_lists <glob>
    local f base recommends
    for f in config/package-lists/$1; do
        [ -e "$f" ] || continue
        base=$(basename "$f" .list)
        recommends=1
        grep -q '^#!no-recommends' "$f" && recommends=0
        # shellcheck disable=SC2046
        install_list "$base" "$recommends" $(read_list "$f")
    done
}

stamp()      { touch "$STAMPS/$1"; }
stamped()    { [ -e "$STAMPS/$1" ]; }
kernel_ver() { ls "$CHROOT"/boot/vmlinuz-* 2>/dev/null | sed 's|.*/vmlinuz-||' | sort -V | tail -1; }

# ----------------------------------------------------------------------------
# host checks
# ----------------------------------------------------------------------------
[ "$(id -u)" -eq 0 ] || die "this script needs root: sudo ./build.sh"

# archive extraction can drop executable bits
chmod +x scripts/*.sh config/hooks/*.hook config/includes.chroot/usr/local/bin/* \
         config/includes.chroot/usr/local/sbin/* 2>/dev/null || true

if [ "$DO_CLEAN" = 1 ]; then
    log "Cleaning $WORK_DIR"
    umount_chroot
    rm -rf "$WORK_DIR"
fi
mkdir -p "$WORK_DIR" "$STAMPS" "$OUT_DIR" "$CACHE_DIR"
exec > >(tee -a "$BUILD_LOG") 2>&1

if [ -n "$FROM_STAGE" ]; then
    found=0
    for s in "${STAGES[@]}"; do
        [ "$s" = "$FROM_STAGE" ] && found=1
        [ "$found" = 1 ] && rm -f "$STAMPS/$s"
    done
    [ "$found" = 1 ] || die "unknown stage '$FROM_STAGE' (use --list-stages)"
fi

missing_tools=""
for c in debootstrap xorriso mksquashfs rsync chroot mountpoint awk sed; do
    command -v "$c" >/dev/null 2>&1 || missing_tools="$missing_tools $c"
done
[ -z "$missing_tools" ] || die "missing host tools:$missing_tools
Install them with:
  Ubuntu/Debian/Parrot:  apt-get install -y debootstrap xorriso squashfs-tools rsync mtools dosfstools grub-pc-bin grub-efi-amd64-bin
On a non-Ubuntu host you also need the Ubuntu archive keyring - see below."

# The Ubuntu archive signing keyring is required to debootstrap Ubuntu. On
# Ubuntu it comes from the ubuntu-minimal/ubuntu-keyring packages; on Debian
# and Parrot that package is NOT in the repos, so we fetch it from the Ubuntu
# pool with the bundled helper.
KEYRING=/usr/share/keyrings/ubuntu-archive-keyring.gpg
if [ ! -f "$KEYRING" ]; then
    echo "Ubuntu archive keyring not found at $KEYRING." >&2
    if [ -x "$PROJECT_DIR/scripts/fetch-ubuntu-keyring.sh" ] && [ "$(id -u)" -eq 0 ]; then
        echo "Fetching it now with scripts/fetch-ubuntu-keyring.sh ..." >&2
        if "$PROJECT_DIR/scripts/fetch-ubuntu-keyring.sh" && [ -f "$KEYRING" ]; then
            echo "Keyring installed - continuing." >&2
        else
            die "could not install the Ubuntu archive keyring automatically.
Run it by hand:   sudo ./scripts/fetch-ubuntu-keyring.sh
(it downloads the official ubuntu-keyring .deb from the Ubuntu pool and
extracts $KEYRING)"
        fi
    else
        die "install the Ubuntu archive keyring first:
  On Ubuntu:              apt-get install ubuntu-keyring
  On Debian / Parrot /    sudo ./scripts/fetch-ubuntu-keyring.sh
    any non-Ubuntu host:  (fetches the official ubuntu-keyring .deb and installs
                           $KEYRING)"
    fi
fi
DEBOOTSTRAP_SCRIPTS=/usr/share/debootstrap/scripts
if [ ! -e "$DEBOOTSTRAP_SCRIPTS/$UBUNTU_SUITE" ]; then
    if [ -e "$DEBOOTSTRAP_SCRIPTS/gutsy" ]; then
        warn "debootstrap has no '$UBUNTU_SUITE' script - linking it to the generic Ubuntu script"
        ln -sf gutsy "$DEBOOTSTRAP_SCRIPTS/$UBUNTU_SUITE" 2>/dev/null \
            || die "could not create the debootstrap script link (need root, or a writable $DEBOOTSTRAP_SCRIPTS)"
    else
        die "debootstrap is too old for $UBUNTU_SUITE - install a newer debootstrap"
    fi
fi

avail_kb=$(df --output=avail -k "$WORK_DIR" | tail -1)
[ "$avail_kb" -ge $((25 * 1024 * 1024)) ] || warn "less than 25 GiB free under $WORK_DIR - the build may run out of space"

if [ "$DO_SHELL" = 1 ]; then
    [ -d "$CHROOT/usr" ] || die "no chroot yet - run a build first"
    log "Entering the chroot (type 'exit' to leave)"
    mount_chroot
    chroot "$CHROOT" /usr/bin/env -i HOME=/root TERM="${TERM:-xterm}" LANG=C.UTF-8 \
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        PS1='(cfl-chroot) \u@\h:\w# ' /bin/bash --norc || true
    exit 0
fi

log "$CFL_NAME $CFL_VERSION - Ubuntu $UBUNTU_VERSION ($UBUNTU_SUITE/$ARCH) build"
info "work: $WORK_DIR"
info "cache: $CACHE_DIR"
info "output: $OUT_DIR/$ISO_NAME"
info "kernel: $KERNEL_PKG   live user: $LIVE_USER@$LIVE_HOSTNAME   locale: $LIVE_LOCALE/$LIVE_KEYMAP"
start_ts=$(date +%s)

# =============================================================================
# stage: bootstrap
# =============================================================================
stage_bootstrap() {
    log "[bootstrap] debootstrap $UBUNTU_SUITE ($MIRROR)"
    umount_chroot
    rm -rf "$CHROOT"
    debootstrap --arch="$ARCH" --variant=minbase --components=main,universe \
        --keyring="$KEYRING" --cache-dir="$CACHE_DIR" \
        --include=ca-certificates,gnupg,locales,apt-utils,dialog,curl \
        "$UBUNTU_SUITE" "$CHROOT" "$MIRROR"

    echo "$LIVE_HOSTNAME" > "$CHROOT/etc/hostname"
    cat > "$CHROOT/etc/hosts" <<EOF
127.0.0.1   localhost
127.0.1.1   $LIVE_HOSTNAME

::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF
    # no services may start inside the chroot
    printf '#!/bin/sh\nexit 101\n' > "$CHROOT/usr/sbin/policy-rc.d"
    chmod 0755 "$CHROOT/usr/sbin/policy-rc.d"
    # kernel and bootloader postinst scripts must be inert during the build
    divert_stub /usr/sbin/update-initramfs
    divert_stub /usr/sbin/update-grub
    divert_stub /usr/sbin/grub-install
    mkdir -p "$CHROOT/etc/default/grub.d"
    printf 'GRUB_DISABLE_OS_PROBER=true\n' > "$CHROOT/etc/default/grub.d/zz-cfl-build.cfg"

    # DKMS handling. A DKMS module (e.g. lime-forensics-dkms) compiles a kernel
    # module in its postinst; if that compile fails, the postinst fails and the
    # whole apt transaction breaks, poisoning every later package in the batch.
    # Two officially-supported gates in /usr/lib/dkms/common.postinst let us
    # avoid that:
    #   /etc/dkms/no-autoinstall         -> install source only, never build
    #   /etc/dkms/no-autoinstall-errors  -> a failed build is "Ignored", not fatal
    # We ship no-autoinstall-errors PERMANENTLY (so a module that cannot compile
    # against a given kernel never bricks a package install on the built system
    # either), and add no-autoinstall for the duration of the package stages so
    # nothing is built mid-transaction. The finalize stage removes no-autoinstall
    # and does one explicit, non-fatal build pass against the target kernel.
    mkdir -p "$CHROOT/etc/dkms"
    : > "$CHROOT/etc/dkms/no-autoinstall-errors"
    : > "$CHROOT/etc/dkms/no-autoinstall"
}

# =============================================================================
# stage: apt
# =============================================================================
stage_apt() {
    log "[apt] archive sources, pins and build-time settings"
    rm -f "$CHROOT/etc/apt/sources.list"
    mkdir -p "$CHROOT/etc/apt/sources.list.d" "$CHROOT/etc/apt/preferences.d" "$CHROOT/etc/apt/apt.conf.d"
    local suites="$UBUNTU_SUITE $UBUNTU_SUITE-updates"
    [ "$ENABLE_BACKPORTS" = 1 ] && suites="$suites $UBUNTU_SUITE-backports"
    cat > "$CHROOT/etc/apt/sources.list.d/ubuntu.sources" <<EOF
Types: deb
URIs: $MIRROR
Suites: $suites
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: $SECURITY_MIRROR
Suites: $UBUNTU_SUITE-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
    # snaps have no place on a forensic workstation (and cannot run from a
    # read-only squashfs without a writable /var/lib/snapd anyway). Pinning
    # snapd to a negative priority makes it uninstallable, which also blocks
    # the Ubuntu snap-stub packages (firefox, thunderbird, chromium-browser,
    # ...) - those are installed as real .debs from vendor repos, or omitted.
    cat > "$CHROOT/etc/apt/preferences.d/cfl-no-snap" <<'EOF'
Package: snapd
Pin: release *
Pin-Priority: -10
EOF
    cat > "$CHROOT/etc/apt/apt.conf.d/99cfl-build" <<'EOF'
// CFL build-time apt settings (removed in the finalize stage)
Acquire::Languages "none";
Acquire::Retries "3";
APT::Get::Assume-Yes "true";
APT::Install-Suggests "false";
Dpkg::Use-Pty "0";
EOF
    apt_chroot update
    apt_chroot dist-upgrade
}

# =============================================================================
# stage: base
# =============================================================================
stage_base() {
    log "[base] Ubuntu base system, kernel, live boot, bootloaders, firmware"
    # debconf answers (grub must not touch the build host, wireshark setuid, ...)
    cp config/preseed/build.preseed "$WORK_DIR/build.preseed"
    subst "$WORK_DIR/build.preseed"
    run_chroot debconf-set-selections < "$WORK_DIR/build.preseed"

    install_list "ubuntu-base" 1 ubuntu-minimal ubuntu-standard
    install_list "kernel" 1 "$KERNEL_PKG" "$KERNEL_HEADERS_PKG"
    # firmware + live-boot/bootloader lists (0200, 0300)
    install_lists "02[0-9][0-9]-*.list"
    install_lists "03[0-9][0-9]-*.list"
    [ -n "$(kernel_ver)" ] || die "no kernel installed in the chroot (KERNEL_PKG=$KERNEL_PKG)"
    info "kernel version: $(kernel_ver)"
}

# =============================================================================
# stage: desktop
# =============================================================================
stage_desktop() {
    log "[desktop] GNOME on Xorg, shell extensions and workstation applications"
    install_lists "01[0-9][0-9]-*.list"

    # Firefox (and Thunderbird) as real .debs / binaries - never snaps. They
    # are deliberately NOT in the package lists: in the Ubuntu archive both are
    # snap stubs (PreDepends: snapd, which we pin out). install_browser tries
    # three independent sources in turn and VERIFIES a working firefox binary,
    # so the image can never end up without a browser silently.
    install_browser
}

# ---------------------------------------------------------------------------
# Browser installation: Mozilla APT repo -> Mozilla Team PPA -> official
# Mozilla tarball. Whichever succeeds first wins; the result is verified.
# ---------------------------------------------------------------------------
# Install a browser package from the Mozilla APT repo, but ONLY if its apt
# candidate actually originates from packages.mozilla.org. This guarantees we
# never fall back to the Ubuntu snap-stub (which would drag in the pinned-out
# snapd and fail), and cleanly skips a package Mozilla does not publish (e.g.
# Thunderbird) instead of aborting. $1 is the package; further args are
# optional language packs.
mozilla_install() {
    local pkg="$1"; shift
    local l10n=("$@")
    if run_chroot apt-cache policy "$pkg" 2>/dev/null | grep -q 'packages\.mozilla\.org'; then
        if apt_chroot install --no-install-recommends "$pkg" "${l10n[@]}"; then
            info "installed $pkg from packages.mozilla.org"
        elif apt_chroot install --no-install-recommends "$pkg"; then
            info "installed $pkg from packages.mozilla.org (without the language pack)"
        else
            warn "$pkg failed to install from packages.mozilla.org"
            echo "mozilla failed $pkg" >> "$WORK_DIR/packages-skipped.txt"
        fi
    else
        warn "$pkg is not offered by packages.mozilla.org - skipping it (no snap is ever installed)"
        echo "mozilla-unavailable $pkg" >> "$WORK_DIR/packages-skipped.txt"
    fi
}

browser_ok() { [ -x "$CHROOT/usr/bin/firefox" ] || [ -x "$CHROOT/usr/local/bin/firefox" ] || [ -x "$CHROOT/opt/firefox/firefox" ]; }

install_browser() {
    log "[desktop] web browser (Firefox, no snap)"
    mkdir -p "$CHROOT/etc/apt/keyrings"

    # --- source 1: Mozilla's own APT repository (packages.mozilla.org) ------
    if [ "$MOZILLA_APT" = 1 ] && ! browser_ok; then
        info "trying packages.mozilla.org (Mozilla APT repo)"
        if run_chroot sh -c 'curl -fsSL --retry 3 --connect-timeout 20 https://packages.mozilla.org/apt/repo-signing-key.gpg -o /etc/apt/keyrings/packages.mozilla.org.asc' \
           && [ -s "$CHROOT/etc/apt/keyrings/packages.mozilla.org.asc" ]; then
            cat > "$CHROOT/etc/apt/sources.list.d/mozilla.sources" <<'EOF'
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF
            cat > "$CHROOT/etc/apt/preferences.d/mozilla" <<'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF
            if apt_chroot update >/dev/null 2>&1; then
                mozilla_install firefox    firefox-l10n-en-gb
                mozilla_install thunderbird thunderbird-l10n-en-gb
            else
                warn "apt update failed for packages.mozilla.org - trying the next source"
                rm -f "$CHROOT/etc/apt/sources.list.d/mozilla.sources" "$CHROOT/etc/apt/preferences.d/mozilla"
                apt_chroot update >/dev/null 2>&1 || true
            fi
        else
            warn "could not fetch the Mozilla APT signing key - trying the next source"
        fi
    fi

    # --- source 2: the Mozilla Team PPA (firefox / firefox-esr as .deb) -----
    if ! browser_ok; then
        info "trying the Mozilla Team PPA (ppa:mozillateam/ppa)"
        local ppa_key="0AB215679C571D1C8325275B9BDB3D89CE49EC21"
        if run_chroot sh -c "curl -fsSL --retry 3 --connect-timeout 20 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${ppa_key}' | gpg --dearmor -o /etc/apt/keyrings/mozillateam-ppa.gpg" \
           && [ -s "$CHROOT/etc/apt/keyrings/mozillateam-ppa.gpg" ]; then
            cat > "$CHROOT/etc/apt/sources.list.d/mozillateam-ppa.sources" <<EOF
Types: deb
URIs: https://ppa.launchpadcontent.net/mozillateam/ppa/ubuntu
Suites: $UBUNTU_SUITE
Components: main
Signed-By: /etc/apt/keyrings/mozillateam-ppa.gpg
EOF
            cat > "$CHROOT/etc/apt/preferences.d/mozillateam-ppa" <<'EOF'
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOF
            if apt_chroot update >/dev/null 2>&1; then
                # prefer firefox-esr (stable, no snap), then firefox from the PPA
                local p
                for p in firefox-esr firefox; do
                    if run_chroot apt-cache policy "$p" 2>/dev/null | grep -q 'LP-PPA-mozillateam\|ppa.launchpadcontent.net'; then
                        apt_chroot install --no-install-recommends "$p" && break
                    fi
                done
            else
                warn "apt update failed for the Mozilla Team PPA - trying the next source"
                rm -f "$CHROOT/etc/apt/sources.list.d/mozillateam-ppa.sources" "$CHROOT/etc/apt/preferences.d/mozillateam-ppa"
                apt_chroot update >/dev/null 2>&1 || true
            fi
        else
            warn "could not fetch the Mozilla Team PPA key - trying the next source"
        fi
    fi

    # --- source 3: Mozilla's official Linux tarball (always works if there is
    #     any internet at all) ------------------------------------------------
    if ! browser_ok; then
        info "trying the official Mozilla tarball (download.mozilla.org)"
        rm -rf "$CHROOT/opt/firefox" "$CHROOT/tmp/firefox.tar.xz" "$CHROOT/tmp/firefox.tar.bz2"
        local got=0
        if run_chroot sh -c 'curl -fsSL --retry 3 --connect-timeout 20 "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-GB" -o /tmp/firefox.tar.xz'; then
            # Mozilla serves .tar.xz (newer) or .tar.bz2 (older); detect
            if run_chroot tar -tJf /tmp/firefox.tar.xz >/dev/null 2>&1; then
                run_chroot tar -xJf /tmp/firefox.tar.xz -C /opt && got=1
            elif run_chroot tar -tjf /tmp/firefox.tar.xz >/dev/null 2>&1; then
                run_chroot tar -xjf /tmp/firefox.tar.xz -C /opt && got=1
            fi
        fi
        rm -f "$CHROOT/tmp/firefox.tar.xz"
        if [ "$got" = 1 ] && [ -x "$CHROOT/opt/firefox/firefox" ]; then
            ln -sf /opt/firefox/firefox "$CHROOT/usr/local/bin/firefox"
            info "installed Firefox tarball to /opt/firefox"
        fi
    fi

    # --- normalise: a `firefox` command and a firefox.desktop must always exist
    #     (the dock favourite and the CFL menu refer to firefox.desktop) ------
    if [ ! -x "$CHROOT/usr/bin/firefox" ] && [ ! -x "$CHROOT/usr/local/bin/firefox" ]; then
        if [ -x "$CHROOT/usr/bin/firefox-esr" ]; then
            printf '#!/bin/sh\nexec /usr/bin/firefox-esr "$@"\n' > "$CHROOT/usr/local/bin/firefox"
            chmod 0755 "$CHROOT/usr/local/bin/firefox"
        fi
    fi
    if browser_ok; then
        if [ ! -f "$CHROOT/usr/share/applications/firefox.desktop" ]; then
            # tarball / esr-only case: provide the desktop id the dock expects
            local ffexec="firefox" fficon="firefox"
            [ -x "$CHROOT/opt/firefox/firefox" ] && fficon="/opt/firefox/browser/chrome/icons/default/default128.png"
            cat > "$CHROOT/usr/share/applications/firefox.desktop" <<EOF
[Desktop Entry]
Version=1.0
Name=Firefox Web Browser
Comment=Browse the World Wide Web
GenericName=Web Browser
Keywords=Internet;WWW;Browser;Web;Explorer
Exec=$ffexec %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=$fficon
Categories=GNOME;GTK;Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
StartupNotify=true
StartupWMClass=firefox
EOF
        fi
        # default browser system-wide
        mkdir -p "$CHROOT/etc/xdg"
        cat > "$CHROOT/etc/xdg/mimeapps.list" <<'EOF'
[Default Applications]
text/html=firefox.desktop
x-scheme-handler/http=firefox.desktop
x-scheme-handler/https=firefox.desktop
x-scheme-handler/about=firefox.desktop
x-scheme-handler/unknown=firefox.desktop
application/xhtml+xml=firefox.desktop
EOF
        info "browser OK: $(ls "$CHROOT"/usr/bin/firefox "$CHROOT"/usr/local/bin/firefox "$CHROOT"/opt/firefox/firefox 2>/dev/null | head -1 | sed "s|$CHROOT||")"
    else
        warn "NO BROWSER could be installed (all three sources failed - is the build host online?)"
        echo "browser failed firefox (mozilla apt, mozillateam ppa, tarball all failed)" >> "$WORK_DIR/packages-skipped.txt"
        [ "$PACKAGE_STRICT" = 1 ] && die "PACKAGE_STRICT=1 and no browser could be installed"
    fi
}

# =============================================================================
# stage: packages
# =============================================================================
stage_packages() {
    log "[packages] forensic tool lists, installer extras and system utilities"
    install_lists "[1-9][0-9][0-9][0-9]-*.list"
    if [ -s "$WORK_DIR/packages-skipped.txt" ]; then
        warn "$(wc -l < "$WORK_DIR/packages-skipped.txt") package(s) skipped - see $WORK_DIR/packages-skipped.txt"
    fi
}

# =============================================================================
# stage: overlay
# =============================================================================
stage_overlay() {
    log "[overlay] config/includes.chroot and generated configuration"
    rsync -a config/includes.chroot/ "$CHROOT/"
    chmod 0755 "$CHROOT"/usr/local/bin/* "$CHROOT"/usr/local/sbin/* 2>/dev/null || true

    # Calamares installer configuration (branding, modules, sequence)
    rm -rf "$CHROOT/etc/calamares"
    mkdir -p "$CHROOT/etc/calamares"
    rsync -a config/calamares/ "$CHROOT/etc/calamares/"
    # Guard: Calamares expands dollar-variables in shellprocess commands itself
    # and aborts the install ("Could not run command ... missing variables") on
    # any it does not define. The logic must live in scripts called by path.
    # Fail the build here rather than ship an ISO whose installer cannot work.
    local spc spcmd
    for spc in "$CHROOT"/etc/calamares/modules/shellprocess_*.conf; do
        [ -e "$spc" ] || continue
        if grep -q '\$' "$spc"; then
            die "installer config $(basename "$spc") contains a shell variable, so the installer would fail at that step.
This source tree predates the installer fix (v2.0.1). Update it (git pull, or a fresh clone) and rebuild:  sudo ./build.sh --from overlay"
        fi
    done
    for spcmd in $(grep -hoE 'command: */usr/local/sbin/[A-Za-z0-9_.-]+' "$CHROOT"/etc/calamares/modules/shellprocess_*.conf 2>/dev/null | awk '{print $2}'); do
        [ -x "$CHROOT$spcmd" ] || die "the installer calls $spcmd but it is missing from the image (config/includes.chroot$spcmd)"
    done

    # placeholders in every text file we ship
    grep -rlI '@CFL_[A-Z_]*@\|@UBUNTU_[A-Z_]*@\|@LIVE_[A-Z_]*@\|@INSTALL_[A-Z_]*@\|@ISO_VOLID@\|@BUILD_DATE@' \
        "$CHROOT/etc" "$CHROOT/usr/local" "$CHROOT/usr/share/cfl-forensics" "$CHROOT/usr/share/applications" 2>/dev/null \
        | while read -r f; do subst "$f"; done

    # --- live session (casper) ------------------------------------------------
    cat > "$CHROOT/etc/casper.conf" <<EOF
# CFL Forensics live session - read by casper at boot
export USERNAME="$LIVE_USER"
export USERFULLNAME="$LIVE_USER_FULLNAME"
export HOST="$LIVE_HOSTNAME"
export BUILD_SYSTEM="Ubuntu"
# FLAVOUR must be non-empty or casper ignores USERNAME/HOST above
export FLAVOUR="$CFL_NAME"
EOF

    # --- GDM: Xorg session by default; the commented autologin lines are the
    #     exact form casper's 15autologin script uncomments in the live session
    mkdir -p "$CHROOT/etc/gdm3"
    {
        echo "# CFL Forensics - GDM configuration"
        echo "[daemon]"
        if [ "$WAYLAND" = 1 ]; then echo "WaylandEnable=true"; else echo "WaylandEnable=false"; fi
        echo "#  AutomaticLoginEnable = true"
        echo "#  AutomaticLogin = user1"
        echo "DefaultSession=gnome-xorg.desktop"
        echo
        echo "[security]"
        echo
        echo "[xdmcp]"
        echo
        echo "[chooser]"
        echo
        echo "[debug]"
        echo "#Enable=true"
    } > "$CHROOT/etc/gdm3/custom.conf"
    # the live user's session defaults (AccountsService)
    mkdir -p "$CHROOT/var/lib/AccountsService/users"
    cat > "$CHROOT/var/lib/AccountsService/users/$LIVE_USER" <<EOF
[User]
Session=gnome-xorg
XSession=gnome-xorg
Icon=/usr/share/pixmaps/cfl-logo.png
SystemAccount=false
EOF

    # --- locale, keyboard, time zone ----------------------------------------------
    {
        echo "$LIVE_LOCALE UTF-8"
        for l in $EXTRA_LOCALES; do echo "$l UTF-8"; done
    } > "$CHROOT/etc/locale.gen"
    printf 'LANG=%s\n' "$LIVE_LOCALE" > "$CHROOT/etc/default/locale"
    cat > "$CHROOT/etc/default/keyboard" <<EOF
XKBMODEL="pc105"
XKBLAYOUT="$LIVE_KEYMAP"
XKBVARIANT=""
XKBOPTIONS=""
BACKSPACE="guess"
EOF
    ln -sf "/usr/share/zoneinfo/$LIVE_TIMEZONE" "$CHROOT/etc/localtime"
    echo "$LIVE_TIMEZONE" > "$CHROOT/etc/timezone"

    # --- os-release branding (ID stays 'ubuntu' so tooling keeps working) -----------
    local osr="$CHROOT/usr/lib/os-release"
    if [ -f "$osr" ]; then
        sed -i -e "s|^PRETTY_NAME=.*|PRETTY_NAME=\"$CFL_NAME $CFL_VERSION (Ubuntu $UBUNTU_VERSION LTS)\"|" \
               -e "s|^NAME=.*|NAME=\"$CFL_NAME\"|" \
               -e "s|^HOME_URL=.*|HOME_URL=\"$CFL_URL\"|" \
               -e "s|^SUPPORT_URL=.*|SUPPORT_URL=\"$CFL_URL\"|" \
               -e "s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"$CFL_URL\"|" \
               -e '/^LOGO=/d' -e '/^CFL_VERSION=/d' "$osr"
        printf 'LOGO=cfl-logo\nCFL_VERSION="%s"\n' "$CFL_VERSION" >> "$osr"
    fi
    cat > "$CHROOT/etc/cfl-forensics-release" <<EOF
$CFL_NAME $CFL_VERSION "$CFL_CODENAME" - Ubuntu $UBUNTU_VERSION LTS ($UBUNTU_SUITE) - build $BUILD_DATE
source: commit $SRC_COMMIT
$CFL_PUBLISHER
EOF

    # --- networking: NetworkManager manages everything -----------------------------
    mkdir -p "$CHROOT/etc/netplan" "$CHROOT/etc/NetworkManager/conf.d"
    cat > "$CHROOT/etc/netplan/01-network-manager-all.yaml" <<'EOF'
# Let NetworkManager manage all devices on this system
network:
  version: 2
  renderer: NetworkManager
EOF
    chmod 0600 "$CHROOT/etc/netplan/01-network-manager-all.yaml"

    # --- initramfs: include everything needed to boot from any medium ----------------
    sed -i 's/^MODULES=.*/MODULES=most/' "$CHROOT/etc/initramfs-tools/initramfs.conf"

    # --- installed-system GRUB defaults (dual-boot: os-prober on) ----------------
    cat > "$CHROOT/etc/default/grub" <<EOF
# CFL Forensics - GRUB defaults for the installed system
GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=10
GRUB_DISTRIBUTOR="$CFL_NAME"
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX=""
GRUB_GFXMODE=auto
GRUB_GFXPAYLOAD_LINUX=keep
GRUB_THEME=/boot/grub/themes/cfl/theme.txt
EOF
    mkdir -p "$CHROOT/boot/grub/themes/cfl"
    rsync -a config/bootloaders/grub/themes/cfl/ "$CHROOT/boot/grub/themes/cfl/"
    cp "$CHROOT/usr/share/grub/unicode.pf2" "$CHROOT/boot/grub/themes/cfl/" 2>/dev/null || true
}

# =============================================================================
# stage: hooks
# =============================================================================
stage_hooks() {
    if [ "$SKIP_HOOKS" = 1 ]; then
        log "[hooks] skipped (--skip-hooks)"
        return 0
    fi
    log "[hooks] running config/hooks/*.hook inside the chroot"
    mkdir -p "$WORK_DIR/hooks" "$CHROOT/var/log/cfl-forensics"
    rm -rf "$CHROOT/tmp/cfl-hooks"
    mkdir -p "$CHROOT/tmp/cfl-hooks"
    cp config/hooks/*.hook "$CHROOT/tmp/cfl-hooks/"
    local h name
    for h in config/hooks/*.hook; do
        name=$(basename "$h" .hook)
        if [ -e "$STAMPS/hook-$name" ]; then
            info "$name (done)"
            continue
        fi
        info "$name"
        if run_chroot bash "/tmp/cfl-hooks/$name.hook" > "$WORK_DIR/hooks/$name.log" 2>&1; then
            touch "$STAMPS/hook-$name"
        else
            tail -n 20 "$WORK_DIR/hooks/$name.log" | sed 's/^/      /'
            if [ "$HOOK_STRICT" = 1 ]; then
                die "hook $name failed (HOOK_STRICT=1) - see $WORK_DIR/hooks/$name.log"
            fi
            warn "hook $name failed - build continues (see $WORK_DIR/hooks/$name.log)"
            touch "$STAMPS/hook-$name"
        fi
    done
    rm -rf "$CHROOT/tmp/cfl-hooks"
}

# =============================================================================
# stage: finalize
# =============================================================================
stage_finalize() {
    log "[finalize] Plymouth theme, casper hardening, initramfs, cleanup"
    local kver
    kver=$(kernel_ver)

    # --- boot splash: NONE. The image boots quietly with no graphical logo
    #     screen. "splash" is deliberately absent from every kernel command
    #     line (ISO menu, loopback entry and the installed system's GRUB
    #     defaults), so Plymouth never draws a theme. Plymouth itself stays
    #     installed only because casper/cryptsetup can use it for prompts. -----
    rm -rf "$CHROOT/usr/share/plymouth/themes/cfl-forensics"

    # --- casper hardening (forensic live boot) ------------------------------------
    local cb="/usr/share/initramfs-tools/scripts/casper-bottom"
    if [ -e "$CHROOT$cb/13swap" ]; then
        # 13swap activates every swap partition it finds on internal disks
        # (writes to potential evidence) - move it out of the initramfs
        mkdir -p "$CHROOT/usr/share/cfl-forensics/casper-disabled"
        run_chroot dpkg-divert --local --rename --quiet --add \
            --divert /usr/share/cfl-forensics/casper-disabled/13swap "$cb/13swap"
    fi
    local cs="$CHROOT/usr/share/initramfs-tools/scripts/casper"
    local ch="$CHROOT/usr/share/initramfs-tools/scripts/casper-helpers"
    if [ -f "$cs" ] && ! grep -q 'cfl_ro_mount' "$cs"; then
        # medium search: never replay a journal on a candidate partition
        sed -i 's|mount -t ${fstype} -o ro,noatime "${devname}" $mountpoint|cfl_ro_mount "${fstype}" "${devname}" "$mountpoint"|g' "$cs"
        cat >> "$ch" <<'EOF'

# CFL Forensics: read-only mount that also disables journal/log replay, so
# probing an internal partition for the live medium never writes to it.
cfl_ro_mount() {
    _fstype="$1"; _dev="$2"; _mp="$3"
    case "$_fstype" in
        ext2|ext3|ext4) mount -t "$_fstype" -o ro,noatime,noload "$_dev" "$_mp" && return 0 ;;
        xfs)            mount -t "$_fstype" -o ro,noatime,norecovery "$_dev" "$_mp" && return 0 ;;
        btrfs)          mount -t "$_fstype" -o ro,noatime,nologreplay "$_dev" "$_mp" && return 0 ;;
    esac
    mount -t "$_fstype" -o ro,noatime "$_dev" "$_mp"
}
EOF
        grep -q 'cfl_ro_mount' "$cs" || warn "casper mount patch did not apply - check the casper version"
    fi

    # --- locales, schemas, dconf, caches -----------------------------------------
    run_chroot locale-gen
    run_chroot glib-compile-schemas /usr/share/glib-2.0/schemas || true
    run_chroot dconf update || true
    run_chroot update-desktop-database /usr/share/applications || true
    run_chroot gtk-update-icon-cache -f -q /usr/share/icons/hicolor || true
    run_chroot fc-cache -f || true
    run_chroot systemctl enable cfl-live.service NetworkManager || true
    run_chroot systemctl disable apt-daily.timer apt-daily-upgrade.timer motd-news.timer 2>/dev/null || true
    run_chroot systemctl mask apt-daily.service apt-daily-upgrade.service 2>/dev/null || true
    # Ubuntu Pro adverts off (the client itself comes with ubuntu-minimal)
    mkdir -p "$CHROOT/var/lib/ubuntu-advantage"
    echo '{"apt_news": false}' > "$CHROOT/var/lib/ubuntu-advantage/user-config.json"
    # no root logins; the live user has passwordless sudo, installed users use sudo
    run_chroot passwd -l root >/dev/null 2>&1 || true
    run_chroot usermod -s /bin/bash root || true
    # zsh (macOS-style prompt) for new users, bash stays available
    [ -x "$CHROOT/usr/bin/zsh" ] && sed -i 's|^SHELL=.*|SHELL=/usr/bin/zsh|' "$CHROOT/etc/default/useradd"

    # --- DKMS kernel modules: one explicit, non-fatal build against the target
    #     kernel (headers are present now; the packages installed source-only) --------
    if [ -x "$CHROOT/usr/sbin/dkms" ] && ls "$CHROOT"/usr/src/*/dkms.conf >/dev/null 2>&1; then
        rm -f "$CHROOT/etc/dkms/no-autoinstall"   # allow building again
        local dkms_report="$CHROOT/usr/share/cfl-forensics/DKMS-STATUS.txt"
        mkdir -p "$CHROOT/usr/share/cfl-forensics"
        {
            echo "CFL Forensics - DKMS module build status for kernel $kver ($(date -u '+%Y-%m-%d %H:%M UTC'))"
            echo "=================================================================="
        } > "$dkms_report"
        local conf name ver dir
        for conf in "$CHROOT"/usr/src/*/dkms.conf; do
            [ -e "$conf" ] || continue
            # parse PACKAGE_NAME/VERSION from dkms.conf without sourcing it
            name=$(sed -n 's/^[[:space:]]*PACKAGE_NAME=["'"'"']\{0,1\}\([^"'"'"']*\).*/\1/p' "$conf" | head -1)
            ver=$(sed -n 's/^[[:space:]]*PACKAGE_VERSION=["'"'"']\{0,1\}\([^"'"'"']*\).*/\1/p' "$conf" | head -1)
            if [ -z "$name" ] || [ -z "$ver" ]; then
                dir=$(basename "$(dirname "$conf")")
                name=${dir%-*}
                ver=${dir##*-}
            fi
            info "DKMS: building $name/$ver for $kver"
            run_chroot dkms add -m "$name" -v "$ver" >/dev/null 2>&1 || true
            if run_chroot dkms build -m "$name" -v "$ver" -k "$kver" >>"$dkms_report" 2>&1 \
               && run_chroot dkms install -m "$name" -v "$ver" -k "$kver" --force >>"$dkms_report" 2>&1; then
                echo "OK    $name/$ver built and installed for $kver" >> "$dkms_report"
                info "DKMS: $name/$ver OK"
            else
                echo "FAIL  $name/$ver did NOT build for $kver (see log above)" >> "$dkms_report"
                warn "DKMS module $name/$ver did not build for kernel $kver - it is shipped as source and will be rebuilt on the target if that kernel can compile it. See /usr/share/cfl-forensics/DKMS-STATUS.txt"
                echo "$name/$ver dkms-build-failed (kernel $kver)" >> "$WORK_DIR/packages-skipped.txt"
            fi
        done
        # keep no-autoinstall-errors in the image so a future kernel that cannot
        # compile a module never breaks apt on the installed/live system
    fi

    # --- restore diverted tools and build the live initramfs ---------------------------
    rm -f "$CHROOT/etc/default/grub.d/zz-cfl-build.cfg"
    undivert_stub /usr/sbin/update-initramfs
    undivert_stub /usr/sbin/update-grub
    undivert_stub /usr/sbin/grub-install
    info "building initramfs for $kver (casper UUID enabled)"
    rm -f "$CHROOT/boot/initrd.img-$kver"
    run_chroot env CASPER_GENERATE_UUID=1 update-initramfs -c -k "$kver"
    [ -s "$CHROOT/boot/initrd.img-$kver" ] || die "initramfs was not created"
    # recover the UUID casper embedded so the ISO can carry .disk/casper-uuid-generic
    rm -rf "$CHROOT/tmp/cfl-initrd"
    run_chroot unmkinitramfs "/boot/initrd.img-$kver" /tmp/cfl-initrd
    local uuidf
    uuidf=$(find "$CHROOT/tmp/cfl-initrd" -path '*/conf/uuid.conf' | head -1)
    [ -n "$uuidf" ] || die "casper UUID not found in the initramfs"
    cp "$uuidf" "$WORK_DIR/casper-uuid"
    rm -rf "$CHROOT/tmp/cfl-initrd"
    info "casper UUID: $(cat "$WORK_DIR/casper-uuid")"
    # the kernel/initrd used by the installed system are regenerated by
    # Calamares; keep the ones we just built for the live medium
    cp "$CHROOT/boot/vmlinuz-$kver" "$WORK_DIR/vmlinuz"
    cp "$CHROOT/boot/initrd.img-$kver" "$WORK_DIR/initrd"

    # --- cleanup ----------------------------------------------------------------------
    rm -f "$CHROOT/usr/sbin/policy-rc.d" "$CHROOT/etc/apt/apt.conf.d/99cfl-build"
    rm -rf "$CHROOT/var/lib/apt/lists"/* "$CHROOT/var/cache/apt/"*.bin "$CHROOT/root/.cache" \
           "$CHROOT/tmp"/* "$CHROOT/var/tmp"/* "$CHROOT/var/crash"/* "$CHROOT/root/.bash_history"
    find "$CHROOT/var/log" -type f -name '*.log' -exec truncate -s 0 {} + 2>/dev/null || true
    find "$CHROOT/var/log" -type f \( -name '*.gz' -o -name '*.1' \) -delete 2>/dev/null || true
    : > "$CHROOT/etc/machine-id"
    rm -f "$CHROOT/var/lib/dbus/machine-id"
    umount_chroot
    rm -f "$CHROOT/etc/resolv.conf"
    ln -s ../run/systemd/resolve/stub-resolv.conf "$CHROOT/etc/resolv.conf"
    rm -rf "${CHROOT:?}/run"/*
}

# =============================================================================
# stage: squashfs
# =============================================================================
stage_squashfs() {
    log "[squashfs] casper/filesystem.squashfs"
    umount_chroot
    mkdir -p "$ISO_TREE/casper"
    rm -f "$ISO_TREE/casper/filesystem.squashfs"

    run_chroot dpkg-query -W --showformat='${Package} ${Version}\n' > "$ISO_TREE/casper/filesystem.manifest"
    umount_chroot
    # packages the installer removes from the installed system (Ubiquity
    # convention; Calamares uses config/calamares/modules/packages.conf)
    printf '%s\n' casper calamares > "$ISO_TREE/casper/filesystem.manifest-remove"
    du -sx --block-size=1 "$CHROOT" | cut -f1 > "$ISO_TREE/casper/filesystem.size"

    local comp=(-comp xz -Xbcj x86 -b 1M)
    if [ "$SQUASH_COMP" = zstd ]; then
        if mksquashfs -help 2>&1 | grep -q zstd; then
            comp=(-comp zstd -Xcompression-level "$SQUASH_LEVEL" -b 1M)
        else
            warn "host mksquashfs has no zstd support - using xz"
        fi
    fi
    mksquashfs "$CHROOT" "$ISO_TREE/casper/filesystem.squashfs" \
        "${comp[@]}" -noappend -no-progress -processors "$PARALLEL" \
        -wildcards -e 'proc/*' 'sys/*' 'dev/*' 'run/*' 'tmp/*' 'var/tmp/*' \
                      'var/cache/apt/archives/*' 'var/lib/apt/lists/*'
    ls -lh "$ISO_TREE/casper/filesystem.squashfs" | awk '{print "    size: " $5}'
}

# =============================================================================
# stage: bootloader
# =============================================================================
stage_bootloader() {
    log "[bootloader] GRUB (BIOS El Torito + Secure-Boot EFI image), menu and theme"
    local kver
    kver=$(kernel_ver)
    mkdir -p "$ISO_TREE/boot/grub/i386-pc" "$ISO_TREE/boot/grub/fonts" "$ISO_TREE/boot/grub/themes" \
             "$ISO_TREE/EFI/boot" "$ISO_TREE/casper"

    cp "$WORK_DIR/vmlinuz" "$ISO_TREE/casper/vmlinuz"
    cp "$WORK_DIR/initrd"  "$ISO_TREE/casper/initrd"

    # --- BIOS: El Torito core image whose embedded config finds the medium by
    #     /.disk/info, so it boots from CD and from a hybrid USB stick alike
    cat > "$CHROOT/tmp/cfl-embed.cfg" <<'EOF'
search --no-floppy --file --set=root /.disk/info
set prefix=($root)/boot/grub
configfile ($root)/boot/grub/grub.cfg
EOF
    run_chroot grub-mkimage -O i386-pc-eltorito -o /tmp/cfl-eltorito.img -p /boot/grub \
        -c /tmp/cfl-embed.cfg \
        biosdisk iso9660 part_msdos part_gpt fat ext2 exfat ntfs \
        normal configfile search search_fs_file search_fs_uuid search_label \
        linux linux16 boot chain loopback gzio xzio lzopio test true echo sleep \
        all_video video_bochs video_cirrus gfxterm gfxterm_background gfxmenu png jpeg font \
        loadenv halt reboot ls cat probe minicmd keystatus
    cp "$CHROOT/tmp/cfl-eltorito.img" "$ISO_TREE/boot/grub/i386-pc/eltorito.img"
    cp "$CHROOT"/usr/lib/grub/i386-pc/*.mod "$CHROOT"/usr/lib/grub/i386-pc/*.lst "$ISO_TREE/boot/grub/i386-pc/"
    cp "$CHROOT/usr/lib/grub/i386-pc/boot_hybrid.img" "$WORK_DIR/boot_hybrid.img"
    rm -f "$CHROOT/tmp/cfl-embed.cfg" "$CHROOT/tmp/cfl-eltorito.img"

    # --- UEFI: Microsoft-signed shim -> Canonical-signed GRUB (Secure Boot) ------------
    # The .debs ship the signed binaries directly (shimx64.efi.signed.latest,
    # gcdx64.efi.signed), so they exist as long as the packages installed.
    #
    # IMPORTANT: this stage runs from the HOST with the chroot unmounted. The
    # shim-signed postinst also creates /usr/lib/shim/shimx64.efi.signed as an
    # update-alternatives symlink with an ABSOLUTE target (/etc/alternatives/...),
    # which resolves inside the chroot but DANGLES when read from the host. So
    # prefer the real regular files (.latest, then .previous) and only fall back
    # to the symlink after resolving it relative to the chroot.
    local shim grub mm cand
    shim=""
    for cand in "$CHROOT/usr/lib/shim/shimx64.efi.signed.latest" \
                "$CHROOT/usr/lib/shim/shimx64.efi.signed.previous"; do
        if [ -f "$cand" ] && [ ! -L "$cand" ]; then shim="$cand"; break; fi
    done
    if [ -z "$shim" ] && [ -L "$CHROOT/usr/lib/shim/shimx64.efi.signed" ]; then
        # resolve the alternatives chain relative to the chroot root
        cand=$(run_chroot readlink -f /usr/lib/shim/shimx64.efi.signed 2>/dev/null || true)
        umount_chroot
        [ -n "$cand" ] && [ -f "$CHROOT$cand" ] && shim="$CHROOT$cand"
    fi
    grub="$CHROOT/usr/lib/grub/x86_64-efi-signed/gcdx64.efi.signed"
    mm="$CHROOT/usr/lib/shim/mmx64.efi"
    if [ -z "$shim" ]; then
        if run_chroot dpkg -l shim-signed 2>/dev/null | grep -q '^ii'; then
            umount_chroot
            die "shim-signed is installed but no signed shim binary (shimx64.efi.signed.latest/.previous) was found under $CHROOT/usr/lib/shim/ - contents: $(ls "$CHROOT/usr/lib/shim/" 2>/dev/null | tr '\n' ' ')"
        else
            umount_chroot
            die "shim-signed did not install (see $WORK_DIR/packages-skipped.txt). This is usually a grub package conflict: install grub-efi-amd64 (not grub-pc) alongside grub-pc-bin. Re-run:  sudo ./build.sh --from base"
        fi
    fi
    if [ ! -f "$grub" ]; then
        if run_chroot dpkg -l grub-efi-amd64-signed 2>/dev/null | grep -q '^ii'; then
            umount_chroot
            die "grub-efi-amd64-signed is installed but $grub is missing - unexpected package layout"
        else
            umount_chroot
            die "grub-efi-amd64-signed did not install (see $WORK_DIR/packages-skipped.txt). Ensure grub-efi-amd64 + grub-efi-amd64-bin (matching versions) are installed. Re-run:  sudo ./build.sh --from base"
        fi
    fi
    info "signed shim: ${shim#"$CHROOT"}"
    cp "$shim" "$ISO_TREE/EFI/boot/bootx64.efi"
    cp "$grub" "$ISO_TREE/EFI/boot/grubx64.efi"
    [ -f "$mm" ] && cp "$mm" "$ISO_TREE/EFI/boot/mmx64.efi"

    local efi_kb
    efi_kb=$(( ( $(du -ck "$ISO_TREE"/EFI/boot/* | tail -1 | cut -f1) + 4096 ) / 1024 * 1024 ))
    [ "$efi_kb" -lt 8192 ] && efi_kb=8192
    rm -f "$CHROOT/tmp/cfl-efi.img"
    run_chroot mkfs.vfat -C -n CFL_EFI /tmp/cfl-efi.img "$efi_kb" >/dev/null
    cp "$ISO_TREE/EFI/boot/"* "$CHROOT/tmp/"
    run_chroot mmd -i /tmp/cfl-efi.img ::EFI ::EFI/boot
    run_chroot mcopy -i /tmp/cfl-efi.img /tmp/bootx64.efi /tmp/grubx64.efi ::EFI/boot/
    [ -f "$mm" ] && run_chroot mcopy -i /tmp/cfl-efi.img /tmp/mmx64.efi ::EFI/boot/
    cp "$CHROOT/tmp/cfl-efi.img" "$WORK_DIR/efi.img"
    rm -f "$CHROOT"/tmp/cfl-efi.img "$CHROOT"/tmp/*.efi
    umount_chroot

    # --- menu, theme, font, memtest ------------------------------------------------------
    cp config/bootloaders/grub/grub.cfg "$ISO_TREE/boot/grub/grub.cfg"
    cp config/bootloaders/grub/loopback.cfg "$ISO_TREE/boot/grub/loopback.cfg"
    subst "$ISO_TREE/boot/grub/grub.cfg" "$ISO_TREE/boot/grub/loopback.cfg"
    rsync -a config/bootloaders/grub/themes/ "$ISO_TREE/boot/grub/themes/"
    cp "$CHROOT/usr/share/grub/unicode.pf2" "$ISO_TREE/boot/grub/fonts/unicode.pf2"
    cp "$CHROOT/usr/share/grub/unicode.pf2" "$ISO_TREE/boot/grub/themes/cfl/unicode.pf2"
    [ -f "$CHROOT/boot/memtest86+x64.bin" ] && cp "$CHROOT/boot/memtest86+x64.bin" "$ISO_TREE/boot/memtest86+x64.bin"
    [ -f "$CHROOT/boot/memtest86+x64.efi" ] && cp "$CHROOT/boot/memtest86+x64.efi" "$ISO_TREE/boot/memtest86+x64.efi"
    info "kernel $kver, EFI image $((efi_kb / 1024)) MiB"
}

# =============================================================================
# stage: iso
# =============================================================================
stage_iso() {
    log "[iso] $ISO_NAME"
    mkdir -p "$ISO_TREE/.disk"
    echo "$CFL_NAME $CFL_VERSION \"$CFL_CODENAME\" - Release $ARCH ($BUILD_DATE) [$SRC_COMMIT]" > "$ISO_TREE/.disk/info"
    : > "$ISO_TREE/.disk/base_installable"
    echo "full_cd/single" > "$ISO_TREE/.disk/cd_type"
    echo "$CFL_URL" > "$ISO_TREE/.disk/release_notes_url"
    cp "$WORK_DIR/casper-uuid" "$ISO_TREE/.disk/casper-uuid-generic"
    cp config/includes.iso/README.txt "$ISO_TREE/README.txt"
    subst "$ISO_TREE/README.txt"

    ( cd "$ISO_TREE" && find . -type f ! -name md5sum.txt ! -path './boot.catalog' -print0 \
        | sort -z | xargs -0 md5sum > md5sum.txt )

    local out="$OUT_DIR/$ISO_NAME"
    rm -f "$out"
    xorriso -as mkisofs \
        -r -V "$ISO_VOLID" -iso-level 3 -l \
        -publisher "$CFL_PUBLISHER" -preparer "CFL Forensics build.sh" \
        -o "$out" \
        --grub2-mbr "$WORK_DIR/boot_hybrid.img" \
        --protective-msdos-label -partition_cyl_align off -partition_offset 16 --mbr-force-bootable \
        -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b "$WORK_DIR/efi.img" \
        -appended_part_as_gpt -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
        -c /boot.catalog \
        -b /boot/grub/i386-pc/eltorito.img -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
        -eltorito-alt-boot -e '--interval:appended_partition_2:all::' -no-emul-boot \
        "$ISO_TREE"

    ( cd "$OUT_DIR" && sha256sum "$ISO_NAME" > SHA256SUMS && md5sum "$ISO_NAME" > MD5SUMS )
    cp "$ISO_TREE/casper/filesystem.manifest" "$OUT_DIR/${ISO_NAME%.iso}.manifest"
    [ -s "$WORK_DIR/packages-skipped.txt" ] && cp "$WORK_DIR/packages-skipped.txt" "$OUT_DIR/${ISO_NAME%.iso}.packages-skipped.txt"
    [ -f "$CHROOT/usr/share/cfl-forensics/TOOL-HEALTH.txt" ] && cp "$CHROOT/usr/share/cfl-forensics/TOOL-HEALTH.txt" "$OUT_DIR/${ISO_NAME%.iso}.tool-health.txt"
}

# =============================================================================
# main
# =============================================================================
ran_any=0
for s in "${STAGES[@]}"; do
    if stamped "$s"; then
        info "stage $s: done"
        continue
    fi
    "stage_$s"
    stamp "$s"
    ran_any=1
done
umount_chroot

elapsed=$(( $(date +%s) - start_ts ))
if [ "$ran_any" = 0 ]; then
    warn "NOTHING WAS REBUILT: every stage was already complete, so the ISO in $OUT_DIR is the one from the previous build
      (built $(date -r "$OUT_DIR/$ISO_NAME" '+%Y-%m-%d %H:%M' 2>/dev/null || echo 'unknown date')). It does NOT include any source changes made since.
      To pick up changed files:   sudo ./build.sh --from overlay      (configs, launchers, installer)
      To rebuild everything:      sudo ./build.sh --clean"
fi
log "Build finished in $((elapsed / 60)) min"
info "source    : commit $SRC_COMMIT   (stamped into /etc/cfl-forensics-release in the image)"
ls -lh "$OUT_DIR/$ISO_NAME" | awk '{print "    " $5 "  " $9}'
info "checksums : $OUT_DIR/SHA256SUMS"
info "manifest  : $OUT_DIR/${ISO_NAME%.iso}.manifest"
info "test (VM) : ./scripts/test-iso-qemu.sh $OUT_DIR/$ISO_NAME          # BIOS"
info "            ./scripts/test-iso-qemu.sh --uefi $OUT_DIR/$ISO_NAME   # UEFI/Secure Boot firmware"
info "write USB : sudo ./scripts/write-usb.sh $OUT_DIR/$ISO_NAME /dev/sdX"
