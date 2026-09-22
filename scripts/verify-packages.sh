#!/bin/bash
# Check every package named in config/package-lists/*.list against the live
# Ubuntu archive index, WITHOUT building anything. Run before a build to catch
# a package that was renamed or dropped in the target suite.
#
#   ./verify-packages.sh              # uses UBUNTU_SUITE from cfl-build.conf
#   UBUNTU_SUITE=oracular ./verify-packages.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=../cfl-build.conf
. ./cfl-build.conf
SUITE="${UBUNTU_SUITE:-noble}"
MIRROR="${MIRROR:-http://archive.ubuntu.com/ubuntu/}"
ARCH="${ARCH:-amd64}"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

echo "Fetching package indices for $SUITE / $SUITE-updates / $SUITE-security ($ARCH) ..."
: > "$WORK/index.txt"
for suite in "$SUITE" "$SUITE-updates" "$SUITE-security"; do
    base="$MIRROR"; [ "$suite" = "$SUITE-security" ] && base="${SECURITY_MIRROR:-http://security.ubuntu.com/ubuntu/}"
    for comp in main restricted universe multiverse; do
        url="${base}dists/${suite}/${comp}/binary-${ARCH}/Packages.gz"
        curl -sfL "$url" | zcat 2>/dev/null | awk '/^Package: /{print $2}' >> "$WORK/index.txt" || true
        # provides (virtual packages)
        curl -sfL "$url" | zcat 2>/dev/null | awk -F': ' '/^Provides: /{gsub(/,/," ",$2); print $2}' | tr ' ' '\n' | sed 's/(.*//' >> "$WORK/index.txt" || true
    done
done
sort -u "$WORK/index.txt" > "$WORK/have.txt"
echo "archive lists $(wc -l < "$WORK/have.txt") package/provide names"
echo

missing=0
for f in config/package-lists/*.list; do
    while read -r p; do
        [ -z "$p" ] && continue
        grep -qx "$p" "$WORK/have.txt" || { printf '  MISSING  %-40s (%s)\n' "$p" "$(basename "$f")"; missing=$((missing+1)); }
    done < <(sed -e 's/#.*//' "$f" | tr -s ' \t\n' '\n' | grep -v '^$')
done
echo
if [ "$missing" -eq 0 ]; then
    echo "All packages resolve in $SUITE. (Tools installed by hooks - recon-ng, waymore, assetfinder, exiflooter, ghidra, jadx, amass, etc. - are intentionally not in these lists.)"
else
    echo "$missing package name(s) not found - update the lists or add them to a hook."
    exit 1
fi
