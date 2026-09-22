# CSI Linux comparison

How CFL Forensics was checked against **CSI Linux** (the Ubuntu-based
DFIR/OSINT distribution), what we adopted, and what we deliberately left
out. Based on CSI Linux's official installer sources
(`CSILinux/CSILinux-Powerup` and `CSILinux/csitools` on GitHub, July 2026).

## Method

CSI Linux publishes its toolset through its *Powerup* installer: category
package lists (`csi_cf.txt`, `csi_osint.txt`, `csi_ir.txt`, `csi_ma.txt`,
`csi_sigint.txt`, …) plus a large update script (`csitoolsupdate24.sh`)
that clones tools from GitHub and pip-installs others. We extracted that
inventory, removed duplicates, and diffed it against the CFL Forensics
package lists and build hooks.

**Result:** CFL Forensics already covered the large majority of CSI's
forensic tooling (both are anchored on the Debian/Ubuntu forensics
ecosystem). The genuine gaps have now been closed as follows.

## Added for CSI parity - Debian packages

Available in Debian trixie and now in `config/package-lists/`:

| Area | Packages |
|---|---|
| Case workflow | `zenity`, `wmctrl`, `xterm`, `pandoc`, `cherrytree`, `keepassxc`, `gtkhash` |
| File systems | `apfsprogs`, `gfs2-utils`, `ocfs2-tools`, `reiserfsprogs` |
| Acquisition | `can-utils` (vehicle CAN-bus capture) |
| Network | `mtr`, `lft` |
| Documents/media | `pdfresurrect`, `ocrmypdf`, `audacity`, `vokoscreen-ng` |
| Mobile | `aapt` |
| OSINT & anonymity | `knockpy`, `cutycapt`, `httrack`, `tor`, `obfs4proxy`, `i2pd`, `macchanger` |
| Incident response | `clamtk`, `inotify-tools`, `hashdeep` |
| Steganography | `stegosuite` |
| Signals (SDR) | `rtl-sdr`, `rtl-433`, `gqrx-sdr`, `soapysdr-tools`, `hackrf`, `bladerf`, `airspy`, `airspyhf` |

## Added for CSI parity - from upstream (build hooks)

Not packaged in Debian; installed by `0300-pipx-tools.hook.chroot` and
`0450-script-tools.hook.chroot` (best effort, logged, launchers pruned if
a tool fails to land):

| Tool | Purpose | Licence |
|---|---|---|
| **iLEAPP / ALEAPP / RLEAPP / VLEAPP / WLEAPP / cLEAPP** | Mobile, app, vehicle, Windows and ChromeOS artefact parsers (the *LEAPP* family) | MIT |
| **OnionSearch** | Dark-web (.onion) search across multiple engines | GPL-3.0 |
| **GHunt** | Google-account OSINT | GPL-3.0 |
| **Photon** | High-speed OSINT web crawler | GPL-3.0 |
| **Blackbird** | Username search across hundreds of sites | MIT |
| **email2phonenumber** | Email → phone-number OSINT | GPL-3.0 |
| **RecuperaBit** | Reconstruction of heavily damaged NTFS volumes | GPL-3.0 |
| **AutoTimeliner** | One-command plaso super-timelines | MIT |
| **Carbon14** | USB and artefact timeline builder | GPL-3.0 |
| **DumpsterDiver** | Finds secrets/credentials in file trees | GPL-3.0 |

OnionSearch needs the `tor` service running (`sudo systemctl start tor`);
`tor` and `obfs4proxy` are installed.

## Case management

CSI Linux's *CSI Case Management* is a set of bash/zenity scripts in their
`csitools` repository. **That repository carries no licence file**, so the
scripts are all-rights-reserved and cannot legally be redistributed in
another distro. A clean-room equivalent (`cfl-case`) was built and shipped
in earlier builds; it has since been **removed at the project owner's
request**. Cases are simply organised under the `/cases/` workspace, and
notes can be kept in Cherrytree (Document & Media Analysis menu).

## Already in CFL Forensics (no action needed)

A non-exhaustive list of CSI tools CFL already had: sleuthkit/Autopsy,
plaso, Volatility 3, Guymager, ewfacquire, dc3dd/dcfldd, regripper,
vinetto, magicrescue/recoverjpeg/scrounge-ntfs, Wireshark/termshark,
tcpdump, tcpflow, masscan/zmap/arp-scan/netdiscover, bettercap, dsniff,
ssldump/sslscan/testssl.sh, binwalk, radare2, Ghidra, JADX, edb,
john/hashcat/ophcrack, hydra/medusa/ncrack, steghide/stegseek/stegsnow/
stegcracker/outguess/zsteg, exiftool/mat2, ffmpeg/sox/mediainfo, adb +
libimobiledevice suite, recon-ng, theHarvester, SpiderFoot, OSRFramework,
sherlock, waymore, sublist3r, fierce, Amass, metagoofil, aircrack-ng
suite, kismet alternatives (horst), lynis, rkhunter/chkrootkit, clamav,
inetsim, firejail, nwipe/shred/scrub/sfill, and the full
`forensics-all`/`forensics-extra` metapackage tail.

## Deliberately excluded

| CSI item | Why |
|---|---|
| `csitools` scripts (incl. CSI Case Management) | No licence in the repo → not redistributable |
| Maltego | Proprietary; an all-open-source build excludes it (recon-ng/SpiderFoot cover the space) |
| Signal/Telegram/Discord/Slack/Zoom/Brave/VS Code clients | Proprietary or third-party APT repos; not forensic tools |
| Armitage, wifipumpkin3, Storm-Breaker, Cuckoo | Offensive/pentest frameworks - outside this distro's DFIR scope |
| sqlmap, nikto, dirb, zaproxy | Web-application pentest; out of scope |
| Kismet | Not in trixie; `aircrack-ng`/`horst` cover wireless capture |
| sn0int | Removed from trixie (Rust crate churn); build via cargo if required |
| Cutter, jd-gui | Not in trixie; radare2 + Ghidra + JADX cover RE/decompilation |
| VeraCrypt, zuluCrypt | Not in trixie (licensing); `cryptsetup`/`dislocker` cover LUKS/BitLocker |
| `realtek-rtl88xxau-dkms`, dump1090, hacktv | Not packaged in trixie |
| fred / fred-reports | Ubuntu-only packages; Autopsy/regripper cover registry analysis |
| lokinet, orjail | Not in Debian; `tor` + `i2pd` provide anonymous transport |
| Osintgram, InstagramOSINT, Moriarty, Masto, Goohak, Geogramint, ReconDog, FinalRecon, Rock-ON, Navi, DumpsterDiver forks, dumpzilla | Abandoned or broken upstream |
| obs-studio, openshot, handbrake, gramps, transmission | Size/out of scope; `vokoscreen-ng` covers screen recording |
