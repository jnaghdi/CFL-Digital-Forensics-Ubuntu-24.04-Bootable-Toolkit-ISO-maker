# Parrot OS / CSI Linux tool parity - Ubuntu 24.04 build

This records the check of CFL Forensics @CFL_VERSION@ against the forensic,
OSINT, incident-response, reverse-engineering and SDR tooling of **Parrot OS**
(`parrot-tools-forensics`, `-osint`, `-reverse`, `-sdr`) and **CSI Linux**
(its Powerup category lists and `csitoolsupdate` script). CSI's *Case
Management* is deliberately excluded (see the end of this note).

The original Debian-based comparison (`CSI-COMPARISON.md`,
`KALI-PARROT-COMPARISON.md`) still applies. What changed on Ubuntu is that
several tools the Debian comparison had to exclude as "not in trixie" **are**
packaged by Ubuntu, and every candidate below was re-verified against the live
noble archive index rather than assumed.

## Method

1. Took every tool named in the two Parrot/CSI category sets plus the items
   the Debian comparison excluded for packaging reasons.
2. Resolved package-name differences (`exiftool` → `libimage-exiftool-perl`,
   `photorec` → `testdisk`, `ddrescue` → `gddrescue`, `md5deep` → `hashdeep`,
   `hivex` → `libhivex-bin`, `readpst` → `pst-utils`, `android-tools-adb` →
   `adb`, …) so nothing was counted as missing that was really present.
3. Excluded anything already installed by a build hook (Ghidra, JADX, Amass,
   Volatility 3, oletools, recon-ng, SpiderFoot, the xLEAPP family, Photon,
   Blackbird, RecuperaBit, AutoTimeliner, Carbon14, DumpsterDiver, …).
4. Checked the remainder against the noble package index; what exists was added
   to a package list, what is on PyPI was added to the pipx hook, and the rest
   is listed as unavailable with the reason.

**Result:** the large majority of both distros' DFIR/OSINT tooling was already
present. The genuine gaps were closed as follows.

## Added - Ubuntu archive packages (`config/package-lists/2500-parrot-csi-parity.list`)

| Area | Packages |
|---|---|
| Disk / carving | `autopsy` (2.x web UI for Sleuth Kit), `ssdeep`, `ent`, `guestfs-tools`, `libewf-dev` |
| Timeline libs | `python3-plaso`, `python3-dfvfs`, `python3-artifacts` |
| Malware / RE | `radare2`, `pev`, `gdb-multiarch`, `python3-pefile`, `python3-pwntools`, `python3-scapy` |
| Network | `nbtscan`, `smbclient`, `smbmap`, `sslsplit`, `ffuf`, `wfuzz` |
| OSINT / anonymity | `torbrowser-launcher`, `torsocks`, `proxychains`, `yt-dlp` |
| Mobile | `scrcpy`, `android-sdk-platform-tools-common` |
| Passwords | `hashcat-data`, `john-data` |
| Documents | `origami`, `ghostscript` |
| Encryption | `zulucrypt-gui`, `zulucrypt-cli` (VeraCrypt/TrueCrypt/LUKS volumes) |

All 32 names were verified to exist in the noble archive.

## Added - from PyPI via pipx (`config/hooks/0300-pipx-tools.hook`)

| Tool | Purpose |
|---|---|
| **holehe** | which sites an e-mail address is registered on |
| **maigret** | username dossier across hundreds of sites |
| **socialscan** | username / e-mail availability and OSINT |
| **h8mail** | e-mail breach and credential OSINT |
| **toutatis** | Instagram account OSINT |
| **pyhindsight** (Hindsight) | web-browser history forensics (Chrome/Edge/Brave) |
| **mvt** (Mobile Verification Toolkit) | iOS/Android IOC triage for spyware |
| **andriller** | Android forensic extraction (GUI) |

Every one has a launcher in the CFL menu (30 new launchers in total, all in the
same `cfl-run` terminal format as the rest), placed in the matching category.

## Already present - no action needed

sherlock (archive), theHarvester, recon-ng, SpiderFoot, OSRFramework, GHunt,
OnionSearch, Photon, Blackbird, email2phonenumber, Amass, metagoofil, waymore,
Sublist3r, fierce, dnsrecon, instaloader, exiftool, exifprobe, mat2, Autopsy
(Sleuth Kit CLI), plaso (pipx), Volatility 3, LiME, bulk_extractor, binwalk,
foremost, scalpel, testdisk/photorec, dc3dd/dcfldd, Guymager, ewf-tools,
afflib, xmount, hashdeep, yara, ClamAV, rkhunter, chkrootkit, unhide, lynis,
regripper, galleta/pasco/rifiuti, vinetto, pst-utils/pff-tools, Ghidra, JADX,
apktool, androguard, adb/fastboot, the libimobiledevice suite, the xLEAPP
family, Wireshark/tshark, tcpdump, tcpflow, ngrep, dsniff, bettercap,
mitmproxy, john, hashcat, ophcrack, hydra, medusa, ncrack, steghide,
stegosuite, outguess, zsteg, stegseek, aircrack-ng, gnuradio/rtl-sdr/gqrx,
nwipe/shred/scrub, and the full `forensics-all` metapackage tail.

## Not available on Ubuntu 24.04 - and why

| Tool | Reason |
|---|---|
| **Case management** (CSI `csitools`) | Excluded by decision; also unlicensed upstream, not redistributable |
| Kismet, Cutter/rizin, dex2jar, jd-gui, xplico, dumpzilla | Not in the Ubuntu archive; covered by aircrack-ng/horst, radare2 + Ghidra + JADX, and the browser/timeline tools |
| VeraCrypt | Licensing keeps it out of the archive; **zuluCrypt** (added) manages VeraCrypt/TrueCrypt volumes, `cryptsetup`/`dislocker` cover LUKS/BitLocker |
| Maltego | Proprietary; recon-ng/SpiderFoot/Maigret cover the space |
| twint, Osintgram, Moriarty and similar | Abandoned/broken upstream |
| SecLists / `wordlists` | ~1 GB; `crunch`, `cewl`, `john-data`, `hashcat-data` cover it |
| Metasploit, sqlmap, nikto, BeEF, SET, … | Offensive/pentest scope - outside a DFIR workstation |

---

*Computer Forensics Lab Ltd - @CFL_URL@*
