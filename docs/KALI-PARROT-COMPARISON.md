# Kali Linux & Parrot OS comparison

How CFL Forensics was checked against **Kali Linux** (its official
`kali-tools-*` metapackages, kali.org, 2026) and **Parrot OS** (its
`parrot-tools-*` metapackages, ParrotSec/parrot-tools), what we adopted,
and what we deliberately left out.

## Scope

Kali and Parrot are **penetration-testing** distributions; CFL Forensics
is a **DFIR + OSINT workstation**. We therefore compared their
forensics, OSINT, incident-response, SDR and reversing categories in
full, and excluded their offensive categories (exploitation,
post-exploitation, web/vuln assessment, social engineering, VoIP
attacks) - adding those would change the character of the distro.

## Added for Kali & Parrot parity - Debian packages

| Area | Packages |
|---|---|
| Acquisition | `scantool` (OBD-II vehicle diagnostics), `ow-shell` `ow-tools` (1-Wire devices) |
| Network | `tcpreplay`, `zenmap`, `darkstat`, `etherape` |
| Malware/RE | `python3-distorm3`, `libsmali-java` |
| Passwords | `patator` |
| Timeline/registry | `python3-dfwinreg` (`forensic-artifacts` was already included) |
| Documents | `mdbtools` (Microsoft Access) |
| OSINT | `gobuster`, `python3-shodan`, `instaloader`, `wafw00f` |
| SDR | `gnuradio`, `inspectrum`, `multimon-ng`, `gr-osmosdr`, `gr-iqbal`, `gr-air-modes`, `uhd-host`, `chirp`, `rfdump` |

## Added from upstream (build hooks)

| Tool | Purpose |
|---|---|
| **SSLyze** | Deep TLS configuration analysis (pipx) |
| **Maryam** | Modular OSINT framework (pipx, best effort) |
| **URLCrazy** | Typosquatting domain generation/testing (Ruby) |
| **pdfid / pdf-parser** | DidierStevens PDF structure triage and internals |

## Already in CFL Forensics (no action needed)

The overlap was already large: sleuthkit/Autopsy, plaso, Volatility 3,
ewf-tools/afflib, dc3dd/dcfldd/ddrescue, binwalk, foremost/scalpel/
magicrescue/recoverjpeg, bulk_extractor, regripper/reglookup/winregfs/
libhivex, grokevt, galleta/pasco/rifiuti/rifiuti2, vinetto/undbx/
pst-utils, exifprobe/exiv2, hashdeep/md5deep/ssdeep, memdump, aesfix/
aeskeyfind/rsakeyfind, edb, radare2, Ghidra, JADX, apktool, readpe,
john/hashcat/ophcrack, hydra/medusa/ncrack, cewl/crunch/pipal/pdfcrack/
rarcrack/samdump2, steghide/stegosuite/stegsnow, Wireshark/tcpdump/
tcpflow/tcpick, masscan/p0f/ike-scan/hping3/braa/fping/onesixtyone/
netdiscover/arp-scan/nbtscan alternatives, inetsim, unhide, xmount,
gpart/gparted, parted, lvm2, smartmontools, rsync, cabextract, sqlitebrowser,
upx, yara, can-utils, the full `forensics-all`/`forensics-extra` tail,
plus everything adopted in the CSI Linux round (see CSI-COMPARISON.md).

## Deliberately excluded

| Item | Why |
|---|---|
| Metasploit, Armitage, BeEF, sqlmap, nikto, wapiti, ZAP, SET, veil, weevely, exploitdb, peass, mimikatz/wce/ollydbg (Windows binaries), dnschef, responder, sslsplit attacks, sipvicious VoIP floods, THC-* attack tools | Offensive/pentest scope - outside a DFIR workstation |
| dex2jar | Not in trixie; JADX/enjarify/androguard cover Dalvik |
| rizin / rizin-cutter | Not in trixie; radare2 + Ghidra cover the space |
| xplico | Removed from Debian; unmaintained upstream |
| dumpzilla, javasnoop, firmware-mod-kit, nasty, rephrase, truecrack, rcracki-mt, rsmangler, gpp-decrypt | Abandoned or Kali-only packaging |
| SecLists | ~1 GB wordlist repo; `crunch`/`cewl` + packaged wordlists cover generation |
| kalibrate-rtl, gscanbus | Not packaged in trixie |
| EyeWitness, Dradis, Faraday, logseq | Heavy app stacks (Selenium/Rails/Electron); `cutycapt` and Cherrytree cover capture/notes |
| 2ping, amap, autorecon, dnsmap, enum4linux, smbmap, inspy, ismtp, lbd, irpas, intrace, etherape alternatives, patchleaks, rocket, nmapsi4 | Pentest recon/attack tools or stale |
| Kismet | Not in trixie (documented previously) |
