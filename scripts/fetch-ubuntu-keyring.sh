#!/usr/bin/env bash
# Install the Ubuntu archive signing keyring on a non-Ubuntu host (e.g. Debian
# or Parrot), so debootstrap and build.sh can verify the Ubuntu archive.
#
# Debian/Parrot do not package `ubuntu-keyring`, so this fetches the official
# .deb from the Ubuntu pool and extracts just the keyring file. Run as root.
#
#   sudo ./scripts/fetch-ubuntu-keyring.sh
set -euo pipefail

DEST=/usr/share/keyrings/ubuntu-archive-keyring.gpg
POOL="${UBUNTU_POOL:-http://archive.ubuntu.com/ubuntu}/pool/main/u/ubuntu-keyring/"

if [ "$(id -u)" -ne 0 ]; then
    echo "This needs root (it writes to /usr/share/keyrings/). Re-run with sudo." >&2
    exit 1
fi

if [ -f "$DEST" ]; then
    echo "Ubuntu archive keyring already present at $DEST - nothing to do."
    exit 0
fi

fetch() { if command -v curl >/dev/null 2>&1; then curl -fsSL "$1"; else wget -qO- "$1"; fi; }

echo "Locating the newest ubuntu-keyring package in the Ubuntu pool ..."
deb=$(fetch "$POOL" | grep -oE 'ubuntu-keyring_[0-9.]+_all\.deb' | sort -V | tail -1)
[ -n "$deb" ] || { echo "ERROR: could not find ubuntu-keyring in $POOL" >&2; exit 1; }
echo "  -> $deb"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
echo "Downloading ..."
fetch "$POOL$deb" > "$tmp/$deb"

echo "Extracting the keyring ..."
dpkg-deb -x "$tmp/$deb" "$tmp/x"
src="$tmp/x/usr/share/keyrings/ubuntu-archive-keyring.gpg"
[ -f "$src" ] || { echo "ERROR: keyring not found inside $deb" >&2; exit 1; }

# sanity-check it really is a GPG keyring before trusting it
if command -v gpg >/dev/null 2>&1; then
    if ! gpg --no-default-keyring --keyring "$src" --list-keys >/dev/null 2>&1; then
        echo "ERROR: downloaded file is not a valid GPG keyring - refusing to install it" >&2
        exit 1
    fi
fi

install -m 0644 "$src" "$DEST"
echo "Installed $DEST"
echo "You can now run:  ./build.sh"
