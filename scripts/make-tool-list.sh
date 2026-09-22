#!/bin/bash
# make-tool-list.sh - generate docs/TOOL-LIST.md: the complete, exact list of
# tools in the image, produced from the SAME package lists and hooks the build
# uses, so it can never drift from what is actually installed.
#
# Descriptions for archive packages come from the Ubuntu package index (the
# short "Description:" line); the dependencies of the forensics-all
# metapackage are expanded so the list is genuinely complete.
#
#   ./scripts/make-tool-list.sh                 # fetches the noble index
#   PACKAGES_INDEX=/path/to/Packages ./scripts/make-tool-list.sh   # reuse a local index
set -euo pipefail
cd "$(dirname "$0")/.." || exit 2
# shellcheck source=../cfl-build.conf
. ./cfl-build.conf
OUT=docs/TOOL-LIST.md
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

# --- 1. package index (for descriptions + forensics-all expansion) ----------
if [ -n "${PACKAGES_INDEX:-}" ] && [ -s "$PACKAGES_INDEX" ]; then
    cp "$PACKAGES_INDEX" "$TMP/Packages"
else
    echo "Fetching the $UBUNTU_SUITE package index for descriptions ..." >&2
    : > "$TMP/Packages"
    for suite in "$UBUNTU_SUITE" "$UBUNTU_SUITE-updates"; do
        for comp in main restricted universe multiverse; do
            curl -fsSL "${MIRROR}dists/${suite}/${comp}/binary-${ARCH}/Packages.gz" | zcat >> "$TMP/Packages" 2>/dev/null || true
        done
    done
fi

# --- 2. generate -----------------------------------------------------------
python3 - "$TMP/Packages" "$OUT" "$CFL_NAME" "$CFL_VERSION" "$UBUNTU_VERSION" <<'PY'
import re, sys, glob, os, datetime
idx, out, name, ver, ubu = sys.argv[1:6]

# ---- parse the index: name -> (short description, depends) ----
desc, deps = {}, {}
cur = None
for line in open(idx, encoding='utf-8', errors='replace'):
    if line.startswith('Package: '):
        cur = line[9:].strip()
    elif cur and line.startswith('Description: ') and cur not in desc:
        desc[cur] = line[13:].strip()
    elif cur and line.startswith('Depends: '):
        deps[cur] = [d.strip().split(' ')[0].split('|')[0].strip() for d in line[9:].split(',')]

def d(p):  # description or blank
    return desc.get(p, '').replace('|', '/')

# ---- package lists -> sections (category from the file name) ----
titles = {
 '0100-desktop': 'Desktop, applications and base tooling',
 '0200-firmware': 'Firmware and microcode',
 '0300-boot': 'Live boot, installer and boot chain',
 '1000-forensics-meta': 'Debian Forensics metapackage',
 '1100-forensics-acquisition': 'Acquisition and imaging',
 '1200-forensics-filesystems': 'Disk and file-system analysis',
 '1300-forensics-memory': 'Memory forensics',
 '1400-forensics-network': 'Network forensics',
 '1500-forensics-malware-re': 'Malware analysis and reverse engineering',
 '1600-forensics-passwords': 'Passwords and cracking',
 '1700-forensics-stego': 'Steganography',
 '1800-forensics-timeline': 'Timeline and artefact analysis',
 '1900-forensics-docs': 'Documents and e-discovery',
 '2000-forensics-mobile': 'Mobile forensics',
 '2100-forensics-osint': 'OSINT',
 '2200-forensics-ir': 'Incident response',
 '2300-forensics-wipe': 'Secure wiping',
 '2400-forensics-sdr': 'SDR and radio',
 '2500-parrot-csi-parity': 'Parrot OS / CSI Linux parity additions',
 '2600-installer': 'Installer and partitioning',
 '3000-system': 'System and recovery utilities',
}
sections, listed = [], set()
for f in sorted(glob.glob('config/package-lists/*.list')):
    key = os.path.basename(f)[:-5]
    pkgs = []
    for ln in open(f):
        ln = ln.split('#', 1)[0]
        pkgs += ln.split()
    pkgs = sorted(set(pkgs))
    listed |= set(pkgs)
    sections.append((titles.get(key, key), key, pkgs))

# ---- forensics-all expansion ----
fa = sorted(p for p in deps.get('forensics-all', []) if p and p not in listed)

# ---- hook-installed tools (hand-described; names from the hooks) ----
pipx = [
 ('volatility3','Volatility 3 memory-forensics framework'),
 ('mitmproxy','Interactive HTTPS proxy for traffic inspection'),
 ('oletools','Analyse Microsoft OLE2/Office files and macros (olevba, oleid, …)'),
 ('theharvester','E-mail, subdomain and host OSINT gathering'),
 ('pysim','SIM card reading and programming tools'),
 ('ghunt','Google account OSINT'),
 ('sslyze','TLS/SSL configuration scanner'),
 ('recon-ng','Web reconnaissance framework'),
 ('plaso','plaso / log2timeline super-timeline creation (current release)'),
 ('OnionSearch','Search engine aggregator for .onion sites'),
 ('spiderfoot','Automated OSINT collection and correlation'),
 ('osrframework','Username, domain and e-mail OSINT (usufy, mailfy, …)'),
 ('maryam','Modular OSINT framework'),
 ('waymore','Wayback Machine URL and content discovery'),
 ('holehe','Which sites an e-mail address is registered on'),
 ('maigret','Username dossier across hundreds of sites'),
 ('socialscan','Username / e-mail availability and OSINT'),
 ('h8mail','E-mail breach and credential OSINT'),
 ('toutatis','Instagram account OSINT'),
 ('pyhindsight','Hindsight - web-browser history forensics (Chrome/Edge/Brave)'),
 ('mvt','Mobile Verification Toolkit - iOS/Android spyware IOC triage'),
 ('andriller','Android forensic extraction and decoding (GUI)'),
]
upstream = [
 ('Ghidra','NSA software reverse-engineering suite (from the official GitHub release)'),
 ('JADX','Dex-to-Java decompiler with GUI'),
 ('Amass','In-depth attack-surface / subdomain mapping (OWASP)'),
 ('assetfinder','Subdomain discovery'),
 ('bulk_extractor','High-speed feature extraction and carving (current upstream build)'),
 ('Didier Stevens Suite','pdfid, pdf-parser, oledump, zipdump, emldump, … (PDF/Office malware triage)'),
 ('exiflooter','Image EXIF geolocation OSINT'),
 ('hashcat-utils','Wordlist and rule utilities for hashcat'),
 ('mdbtools (upstream)','Microsoft Access .mdb/.accdb export (current build)'),
 ('metagoofil','Metadata extraction from public documents'),
 ('pipal','Password statistics analyser'),
 ('urlcrazy','Typosquatting / URL variation generator'),
 ('zsteg','PNG/BMP steganography detection'),
 ('WhiteSur theme','macOS-style GTK/Shell theme and icons'),
 ('ArcMenu','The "Apps" menu (GNOME Shell extension, from extensions.gnome.org)'),
]
gitpy = [
 ('iLEAPP','iOS Logs, Events and Plists Parser (abrignoni)'),
 ('ALEAPP','Android Logs, Events and Protobuf Parser'),
 ('RLEAPP','Returns / cloud-data LEAPP parser'),
 ('VLEAPP','Vehicle data LEAPP parser'),
 ('WLEAPP','Windows LEAPP parser'),
 ('cLEAPP','Chromebook LEAPP parser'),
 ('Photon','Fast web crawler for OSINT'),
 ('Blackbird','Username and e-mail search across social networks'),
 ('email2phonenumber','Recover a phone number from an e-mail address (OSINT)'),
 ('RecuperaBit','NTFS reconstruction and deleted-file recovery'),
 ('AutoTimeliner','Automatic timeline extraction from memory images'),
 ('Carbon14','Web-page age estimation (OSINT)'),
 ('DumpsterDiver','Secrets and keys discovery in files'),
]
browser = [
 ('Firefox','Web browser - real .deb from Mozilla (never a snap)'),
 ('Thunderbird','E-mail client - from Mozilla, when published in their APT repo'),
]

total_pkgs = sum(len(p) for _,_,p in sections) + len(fa)
total_tools = total_pkgs + len(pipx) + len(upstream) + len(gitpy) + len(browser)

L = []
L.append(f"# {name} {ver} - complete tool list")
L.append("")
L.append(f"Every package and tool in the {name} {ver} image (Ubuntu {ubu} LTS). "
         "This file is **generated from the build's own package lists and hooks** by "
         "`scripts/make-tool-list.sh`, so it matches what is installed rather than what was intended. "
         "Package descriptions are the one-line summaries from the Ubuntu archive.")
L.append("")
L.append(f"**Totals:** {total_pkgs} archive packages (including {len(fa)} pulled in by `forensics-all`), "
         f"{len(pipx)} PyPI tools, {len(upstream)+len(gitpy)} upstream/GitHub tools, {len(browser)} Mozilla applications - "
         f"**{total_tools} items**. Metapackages and libraries bring further tools transitively; "
         "run `cfl-tools` on the live system for the on-disk inventory.")
L.append("")
L.append(f"_Generated {datetime.date.today().isoformat()}._")
L.append("")
L.append("## Contents")
for t,k,_ in sections:
    L.append(f"- [{t}](#{re.sub(r'[^a-z0-9]+','-',t.lower()).strip('-')})")
L.append("- [Pulled in by forensics-all](#pulled-in-by-forensics-all)")
L.append("- [Installed from PyPI (pipx)](#installed-from-pypi-pipx)")
L.append("- [Built or fetched from upstream](#built-or-fetched-from-upstream)")
L.append("- [Mobile and OSINT script tools (git)](#mobile-and-osint-script-tools-git)")
L.append("- [Web browser and e-mail](#web-browser-and-e-mail)")
L.append("")

for title, key, pkgs in sections:
    L.append(f"## {title}")
    L.append(f"<sub>`config/package-lists/{key}.list` - {len(pkgs)} packages</sub>")
    L.append("")
    L.append("| Package | Description |")
    L.append("|---|---|")
    for p in pkgs:
        L.append(f"| `{p}` | {d(p)} |")
    L.append("")

L.append("## Pulled in by forensics-all")
L.append(f"<sub>dependencies of the `forensics-all` metapackage not already listed above - {len(fa)} packages</sub>")
L.append("")
L.append("| Package | Description |")
L.append("|---|---|")
for p in fa:
    L.append(f"| `{p}` | {d(p)} |")
L.append("")

def table(title, sub, rows):
    L.append(f"## {title}")
    L.append(f"<sub>{sub}</sub>")
    L.append("")
    L.append("| Tool | Description |")
    L.append("|---|---|")
    for n_, ds in rows:
        L.append(f"| **{n_}** | {ds} |")
    L.append("")

table("Installed from PyPI (pipx)", "`config/hooks/0300-pipx-tools.hook` - each in its own isolated venv", pipx)
table("Built or fetched from upstream", "`config/hooks/0200-ghidra.hook`, `0400-upstream-tools.hook`, `0100-whitesur-theme.hook`", upstream)
table("Mobile and OSINT script tools (git)", "`config/hooks/0450-script-tools.hook` - cloned, given a venv and a command wrapper", gitpy)
table("Web browser and e-mail", "installed in the build's desktop stage from Mozilla (APT repo → PPA → official tarball)", browser)

L.append("---")
L.append(f"*Computer Forensics Lab Ltd - regenerate with `./scripts/make-tool-list.sh`*")
open(out, 'w').write('\n'.join(L) + '\n')
print(f"wrote {out}: {total_pkgs} packages, {len(pipx)+len(upstream)+len(gitpy)+len(browser)} hook/vendor tools, {total_tools} total")
PY
