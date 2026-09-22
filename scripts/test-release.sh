#!/bin/bash
# CFL Forensics - static pre-build checks. Validates the project WITHOUT
# building an ISO: script syntax, shellcheck, GRUB menu syntax, Calamares YAML,
# desktop entries, package-list hygiene and the presence of every referenced
# file. Safe to run anywhere (no root, no network).
#
#   ./scripts/test-release.sh
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2
PASS=0; FAIL=0; SKIP=0
ok()   { printf '  \033[32mPASS\033[0m %s\n' "$1"; PASS=$((PASS+1)); }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$1"; FAIL=$((FAIL+1)); }
skip() { printf '  \033[33mSKIP\033[0m %s\n' "$1"; SKIP=$((SKIP+1)); }
have() { command -v "$1" >/dev/null 2>&1; }

# test values used to make placeholder files parseable
sub() { sed -e 's/@CFL_VERSION@/2.0/g; s/@CFL_NAME@/CFL Forensics/g; s/@CFL_URL@/https:\/\/cflab.uk\//g' \
            -e 's/@CFL_PUBLISHER@/CFL/g; s/@LIVE_HOSTNAME@/cfl-forensics/g; s/@LIVE_USER@/cfl/g' \
            -e 's/@LIVE_USER_FULLNAME@/CFL Examiner/g; s/@LIVE_LOCALE@/en_GB.UTF-8/g; s/@LIVE_KEYMAP@/gb/g' \
            -e 's/@INSTALL_REQ_GIB@/126/g; s/@INSTALL_MIN_GIB@/128/g; s/@INSTALL_TZ_REGION@/Europe/g' \
            -e 's/@INSTALL_TZ_ZONE@/London/g; s/@UBUNTU_SUITE@/noble/g; s/@UBUNTU_VERSION@/24.04/g' \
            -e 's/@ISO_VOLID@/CFLFORENSICS/g; s/@BUILD_DATE@/20260912/g; s/@CFL_CODENAME@/Noble/g' "$1"; }

echo "== 1. shell syntax =="
for f in build.sh scripts/*.sh config/hooks/*.hook \
         config/includes.chroot/usr/local/bin/* config/includes.chroot/usr/local/sbin/*; do
    [ -f "$f" ] || continue
    intr=$(head -1 "$f")
    if echo "$intr" | grep -q 'bin/bash'; then
        bash -n "$f" 2>/dev/null && ok "bash -n $f" || bad "bash -n $f"
    elif echo "$intr" | grep -q 'bin/sh'; then
        sh -n "$f" 2>/dev/null && ok "sh -n $f" || bad "sh -n $f"
    fi
done

echo "== 2. shellcheck (warnings+errors) =="
if have shellcheck; then
    for f in build.sh scripts/*.sh; do
        shellcheck -x -S warning "$f" >/dev/null 2>&1 && ok "shellcheck $f" || bad "shellcheck $f"
    done
    # hooks: errors only (they use build-env helpers)
    for f in config/hooks/*.hook; do
        shellcheck -S error "$f" >/dev/null 2>&1 && ok "shellcheck $f" || bad "shellcheck $f"
    done
else
    skip "shellcheck not installed"
fi

echo "== 2b. no calls to undefined shell functions (bash -n / shellcheck miss these) =="
if [ -x scripts/check-undefined-functions.sh ]; then
    if out=$(./scripts/check-undefined-functions.sh build.sh scripts/*.sh 2>&1); then
        ok "every function called in build.sh and scripts/ is defined"
    else
        printf '%s\n' "$out" | sed 's/^/      /'
        bad "a script calls a function that is never defined (would fail at runtime with 'command not found')"
    fi
else
    skip "scripts/check-undefined-functions.sh missing"
fi

echo "== 3. GRUB menu syntax =="
if have grub-script-check; then
    for f in config/bootloaders/grub/grub.cfg config/bootloaders/grub/loopback.cfg; do
        sub "$f" > /tmp/cfl-grub-test.cfg
        grub-script-check /tmp/cfl-grub-test.cfg 2>/dev/null && ok "grub-script-check $f" || bad "grub-script-check $f"
    done
    rm -f /tmp/cfl-grub-test.cfg
else
    skip "grub-script-check not installed (grub-common)"
fi

echo "== 4. Calamares YAML =="
if have python3 && python3 -c 'import yaml' 2>/dev/null; then
    for f in config/calamares/settings.conf config/calamares/branding/cfl/branding.desc config/calamares/modules/*.conf; do
        sub "$f" | python3 -c 'import yaml,sys; list(yaml.safe_load_all(sys.stdin))' 2>/dev/null \
            && ok "yaml $f" || bad "yaml $f"
    done
else
    skip "python3-yaml not installed"
fi

echo "== 5. desktop entries =="
if have desktop-file-validate; then
    n=0
    for f in config/includes.chroot/usr/share/applications/*.desktop \
             config/includes.chroot/etc/skel/Desktop/*.desktop \
             config/includes.chroot/etc/xdg/autostart/*.desktop; do
        [ -f "$f" ] || continue
        desktop-file-validate "$f" >/dev/null 2>&1 || { bad "desktop-file-validate $f"; n=1; }
    done
    [ "$n" = 0 ] && ok "all .desktop files validate"
else
    skip "desktop-file-validate not installed"
fi

echo "== 6. package lists non-empty & comment-clean =="
for f in config/package-lists/*.list; do
    c=$(sed -e 's/#.*//' "$f" | tr -s ' \t\n' '\n' | grep -vc '^$' || true)
    [ "$c" -gt 0 ] && ok "$(basename "$f") ($c pkgs)" || bad "$(basename "$f") is empty"
done

echo "== 6b. no snap-stub packages in the lists (would need the pinned-out snapd) =="
# Ubuntu ships firefox/thunderbird/chromium-browser (and a few others) as .deb
# stubs that PreDepend on snapd. This image pins snapd out, so such a name in a
# package list aborts the build. They must be installed from a vendor repo in
# build.sh instead, never listed here.
SNAP_STUBS="firefox firefox-esr thunderbird chromium-browser chromium"
stub_hits=0
for f in config/package-lists/*.list; do
    while read -r p; do
        [ -z "$p" ] && continue
        for stub in $SNAP_STUBS; do
            [ "$p" = "$stub" ] && { bad "$(basename "$f") lists snap-stub '$p' (install it from a vendor repo, not a list)"; stub_hits=$((stub_hits+1)); }
        done
    done < <(sed -e 's/#.*//' "$f" | tr -s ' \t\n' '\n' | grep -v '^$')
done
[ "$stub_hits" -eq 0 ] && ok "no snap-stub packages listed"

echo "== 6c. grub package set is conflict-free (grub-pc meta must not sit with grub-efi) =="
# grub-pc (the meta) Conflicts with grub-efi-amd64. Installing both makes apt
# drop grub-efi-amd64-signed and shim-signed, breaking Secure Boot. The BIOS
# El Torito image needs grub-pc-BIN (modules), which coexists with grub-efi.
allpkgs=$(cat config/package-lists/*.list | sed -e 's/#.*//' | tr -s ' \t\n' '\n' | grep -v '^$')
if printf '%s\n' "$allpkgs" | grep -qx 'grub-pc'; then
    bad "grub-pc (meta) is listed - it conflicts with grub-efi-amd64; use grub-pc-bin instead"
elif printf '%s\n' "$allpkgs" | grep -qx 'grub-efi-amd64-signed' && ! printf '%s\n' "$allpkgs" | grep -qxE 'grub-efi-amd64'; then
    bad "grub-efi-amd64-signed is listed without grub-efi-amd64 (needed to satisfy its dependency)"
else
    ok "grub package set is conflict-free (grub-pc-bin + grub-efi-amd64 + signed)"
fi

echo "== 6d. bootloader shim detection survives host-side dangling alternatives symlinks =="
# The shim-signed postinst creates /usr/lib/shim/shimx64.efi.signed as an
# update-alternatives symlink with an ABSOLUTE target. Read from the build
# host (chroot unmounted) that symlink dangles. build.sh must therefore pick
# the real .latest/.previous file, never the symlink. Simulate that layout.
_t=$(mktemp -d)
mkdir -p "$_t/usr/lib/shim" "$_t/etc/alternatives"
printf 'x' > "$_t/usr/lib/shim/shimx64.efi.signed.latest"
ln -s /usr/lib/shim/shimx64.efi.signed.latest "$_t/etc/alternatives/shimx64.efi.signed"
ln -s /etc/alternatives/shimx64.efi.signed "$_t/usr/lib/shim/shimx64.efi.signed"
_shim=""
for _c in "$_t/usr/lib/shim/shimx64.efi.signed.latest" "$_t/usr/lib/shim/shimx64.efi.signed.previous"; do
    if [ -f "$_c" ] && [ ! -L "$_c" ]; then _shim="$_c"; break; fi
done
if [ -n "$_shim" ] && grep -q 'shimx64.efi.signed.latest' build.sh && grep -q '\[ ! -L "\$cand" \]' build.sh; then
    ok "shim detection prefers the real .latest file over the alternatives symlink"
else
    bad "shim detection would pick the dangling alternatives symlink (host-side -f fails)"
fi
rm -rf "$_t"

echo "== 6e. terminal launchers cannot hang or show the 'Relaunch' bar =="
# exit-action must be 'close' (hold => "child process exited ... Relaunch" bar;
# restart => tool re-run in a loop) and cfl-run must end in an interactive shell
# after a stdin-closed, timed-out usage probe, so a bare tool never blocks.
dc=config/includes.chroot/etc/dconf/db/local.d/01-cfl-forensics
if grep -qE "exit-action='(hold|restart)'" "$dc"; then
    bad "terminal exit-action is hold/restart - tools would show the Relaunch bar or loop"
else
    ok "terminal exit-action is 'close' (no Relaunch bar, no restart loop)"
fi
cr=config/includes.chroot/usr/local/bin/cfl-run
if grep -q '</dev/null' "$cr" && grep -q 'timeout ' "$cr" && grep -qE 'exec "\$\{SHELL' "$cr"; then
    ok "cfl-run probes usage with stdin closed + timeout, then execs a shell"
else
    bad "cfl-run lacks the stdin-closed/timeout probe or the trailing shell"
fi
# app-grid folders: one per launcher category (the extension-free CFL menu)
fc=$(grep -oE "categories=\['X-CFL-[A-Za-z]+'\]" "$dc" | grep -oE 'X-CFL-[A-Za-z]+' | sort -u)
lc=$(grep -h '^Categories=' config/includes.chroot/usr/share/applications/cfl-*.desktop | grep -oE 'X-CFL-[A-Za-z]+' | sort -u)
if [ "$fc" = "$lc" ] && [ -n "$fc" ]; then
    ok "GNOME app-grid folders cover every launcher category ($(printf '%s\n' "$lc" | wc -l))"
else
    bad "app-grid folders do not match launcher categories"
fi

echo "== 7. referenced files exist =="
check() { [ -e "$1" ] && ok "exists: $1" || bad "missing: $1"; }
check config/calamares/branding/cfl/logo.png
check config/calamares/branding/cfl/welcome.png
check config/calamares/branding/cfl/slide1.png
check config/calamares/branding/cfl/slide2.png
check config/calamares/branding/cfl/show.qml
check config/bootloaders/grub/themes/cfl/theme.txt
check config/bootloaders/grub/themes/cfl/splash.png
check config/includes.chroot/usr/share/backgrounds/cfl-forensics/cfl-wallpaper.png
check config/includes.chroot/usr/local/bin/cfl-run
check config/includes.chroot/usr/local/bin/cfl-run-gui
check config/includes.chroot/usr/local/sbin/cfl-live-setup
check config/includes.chroot/usr/lib/systemd/system/cfl-live.service
check config/preseed/build.preseed
check config/includes.iso/README.txt

echo "== 8. Calamares sequence integrity =="
if have python3 && python3 -c 'import yaml' 2>/dev/null; then
    python3 - <<'PY' && ok "every exec/show module has a config or is a known core module" || bad "sequence references a module with no config"
import yaml, glob, os, sys
s=list(yaml.safe_load_all(open('config/calamares/settings.conf')))[0]
mods=set()
for phase in s['sequence']:
    for k,v in phase.items():
        for m in v: mods.add(m.split('@')[0])
have=set(os.path.basename(p)[:-5] for p in glob.glob('config/calamares/modules/*.conf'))
# core modules that ship no .conf are fine
core={'partition','summary','finished','hwclock','umount','localecfg','luksbootkeyfile','initramfs'}
missing=[m for m in mods if m not in have and m not in core]
# shellprocess instances resolve via instances: list
missing=[m for m in missing if m!='shellprocess']
sys.exit(1 if missing else 0)
PY
else
    skip "python3-yaml not installed (sequence check)"
fi

echo
echo "================  PASS=$PASS  FAIL=$FAIL  SKIP=$SKIP  ================"
[ "$FAIL" -eq 0 ]
