# CFL Forensics 2.0 - complete tool list

Every package and tool in the CFL Forensics 2.0 image (Ubuntu 24.04 LTS). This file is **generated from the build's own package lists and hooks** by `scripts/make-tool-list.sh`, so it matches what is installed rather than what was intended. Package descriptions are the one-line summaries from the Ubuntu archive.

**Totals:** 539 archive packages (including 21 pulled in by `forensics-all`), 22 PyPI tools, 28 upstream/GitHub tools, 2 Mozilla applications - **591 items**. Metapackages and libraries bring further tools transitively; run `cfl-tools` on the live system for the on-disk inventory.

_Generated 2026-09-22._

## Contents
- [Desktop, applications and base tooling](#desktop-applications-and-base-tooling)
- [Firmware and microcode](#firmware-and-microcode)
- [Live boot, installer and boot chain](#live-boot-installer-and-boot-chain)
- [Debian Forensics metapackage](#debian-forensics-metapackage)
- [Acquisition and imaging](#acquisition-and-imaging)
- [Disk and file-system analysis](#disk-and-file-system-analysis)
- [Memory forensics](#memory-forensics)
- [Network forensics](#network-forensics)
- [Malware analysis and reverse engineering](#malware-analysis-and-reverse-engineering)
- [Passwords and cracking](#passwords-and-cracking)
- [Steganography](#steganography)
- [Timeline and artefact analysis](#timeline-and-artefact-analysis)
- [Documents and e-discovery](#documents-and-e-discovery)
- [Mobile forensics](#mobile-forensics)
- [OSINT](#osint)
- [Incident response](#incident-response)
- [Secure wiping](#secure-wiping)
- [SDR and radio](#sdr-and-radio)
- [Parrot OS / CSI Linux parity additions](#parrot-os-csi-linux-parity-additions)
- [Installer and partitioning](#installer-and-partitioning)
- [System and recovery utilities](#system-and-recovery-utilities)
- [Pulled in by forensics-all](#pulled-in-by-forensics-all)
- [Installed from PyPI (pipx)](#installed-from-pypi-pipx)
- [Built or fetched from upstream](#built-or-fetched-from-upstream)
- [Mobile and OSINT script tools (git)](#mobile-and-osint-script-tools-git)
- [Web browser and e-mail](#web-browser-and-e-mail)

## Desktop, applications and base tooling
<sub>`config/package-lists/0100-desktop.list` - 87 packages</sub>

| Package | Description |
|---|---|
| `baobab` | GNOME disk usage analyzer |
| `bluez` | Bluetooth tools and daemons |
| `build-essential` | Informational list of build-essential packages |
| `ca-certificates` | Common CA certificates |
| `cherrytree` | hierarchical note taking application |
| `curl` | command line tool for transferring data with URL syntax |
| `dconf-cli` | simple configuration storage system - utilities |
| `dconf-gsettings-backend` | simple configuration storage system - GSettings back-end |
| `default-jre-headless` | Standard Java or Java compatible Runtime (headless) |
| `dialog` | Displays user-friendly dialog boxes from shell scripts |
| `dkms` | Dynamic Kernel Module System (DKMS) |
| `eog` | Eye of GNOME graphics viewer program |
| `evince` | Document (PostScript, PDF) viewer |
| `file-roller` | archive manager for GNOME |
| `fonts-dejavu` | metapackage to pull in fonts-dejavu-core, -mono and -extra |
| `fonts-inter` | Inter font family |
| `fonts-jetbrains-mono` | free and open-source typeface for developers |
| `fonts-liberation2` | transitional dummy package |
| `fonts-noto-color-emoji` | color emoji font from Google |
| `fonts-noto-core` | "No Tofu" font families with large Unicode coverage (core) |
| `fonts-powerline` | prompt and statusline utility (symbols font) |
| `gdm3` | GNOME Display Manager |
| `gimp` | GNU Image Manipulation Program |
| `git` | fast, scalable, distributed revision control system |
| `gnome-backgrounds` | Set of backgrounds packaged with the GNOME desktop |
| `gnome-bluetooth-sendto` | GNOME Bluetooth Send To app |
| `gnome-calculator` | GNOME desktop calculator |
| `gnome-control-center` | utilities to configure the GNOME desktop |
| `gnome-disk-utility` | manage and configure disk drives and media |
| `gnome-keyring` | GNOME keyring services (daemon and tools) |
| `gnome-menus` | GNOME implementation of the freedesktop menu specification |
| `gnome-session` | GNOME Session Manager - GNOME 3 session |
| `gnome-shell` | graphical shell for the GNOME desktop |
| `gnome-shell-extension-appindicator` | AppIndicator, KStatusNotifierItem and tray support for GNOME Shell |
| `gnome-shell-extension-desktop-icons-ng` | desktop icon support for GNOME Shell |
| `gnome-shell-extension-manager` | Utility for managing GNOME Shell Extensions |
| `gnome-shell-extension-ubuntu-dock` | Ubuntu Dock for GNOME Shell |
| `gnome-shell-extensions` | Extensions to extend functionality of GNOME Shell |
| `gnome-system-monitor` | Process viewer and system resource monitor for GNOME |
| `gnome-terminal` | GNOME terminal emulator application |
| `gnome-text-editor` | simple text editor for GNOME |
| `gnome-tweaks` | tool to adjust advanced configuration settings for GNOME |
| `gnupg` | GNU privacy guard - a free PGP replacement |
| `gtkhash` | GTK+ utility for computing checksums and more |
| `gvfs` | userspace virtual filesystem - GIO module |
| `gvfs-backends` | userspace virtual filesystem - backends |
| `gvfs-fuse` | userspace virtual filesystem - fuse server |
| `imagemagick` | image manipulation programs -- binaries |
| `keepassxc` | Cross Platform Password Manager |
| `libglib2.0-bin` | Programs for the GLib library |
| `libglib2.0-dev-bin` | Development utilities for the GLib library |
| `libreoffice-calc` | office productivity suite -- spreadsheet |
| `libreoffice-writer` | office productivity suite -- word processor |
| `libxml2-utils` | GNOME XML library - utilities |
| `mate-terminal` | MATE terminal emulator application |
| `nautilus` | file manager and graphical shell for GNOME |
| `network-manager` | network management framework (daemon and userspace tools) |
| `network-manager-gnome` | network management framework (GNOME frontend) |
| `openjdk-21-jre` | OpenJDK Java runtime, using Hotspot JIT |
| `optipng` | advanced PNG (Portable Network Graphics) optimizer |
| `p7zip-full` | transitional package |
| `pipewire` | audio and video processing engine multimedia server |
| `pipewire-pulse` | PipeWire PulseAudio daemon |
| `pipx` | execute binaries from Python packages in isolated environments |
| `pkexec` | run commands as another user with polkit authorization |
| `polkitd` | framework for managing administrative policies and privileges |
| `polkitd-pkla` | Legacy "local authority" (.pkla) backend for polkitd |
| `python3-pip` | Python package installer |
| `python3-venv` | venv module for python3 (default python3 version) |
| `sassc` | C/C++ port of the Sass CSS precompiler - command-line tool |
| `seahorse` | GNOME front end for GnuPG |
| `udisks2` | D-Bus service to access and manipulate storage devices |
| `unzip` | De-archiver for .zip files |
| `vlc` | multimedia player and streamer |
| `wget` | retrieves files from the web |
| `wireplumber` | modular session / policy manager for PipeWire |
| `x11-xserver-utils` | X server utilities |
| `xdg-desktop-portal-gnome` | GNOME portal backend for xdg-desktop-portal |
| `xdg-user-dirs` | tool to manage well known user directories |
| `xdg-user-dirs-gtk` | tool to manage well known user directories (Gtk extension) |
| `xdg-utils` | desktop integration utilities from freedesktop.org |
| `xinit` | X server initialisation tool |
| `xorg` | X.Org X Window System |
| `xserver-xorg-legacy` | setuid root Xorg server wrapper |
| `yaru-theme-gtk` | Yaru GTK theme from the Ubuntu Community |
| `yaru-theme-icon` | Yaru icon theme from the Ubuntu Community |
| `zsh` | shell with lots of features |

## Firmware and microcode
<sub>`config/package-lists/0200-firmware.list` - 3 packages</sub>

| Package | Description |
|---|---|
| `amd64-microcode` | Processor microcode firmware for AMD CPUs |
| `intel-microcode` | Processor microcode firmware for Intel CPUs |
| `linux-firmware` | Firmware for Linux kernel drivers |

## Live boot, installer and boot chain
<sub>`config/package-lists/0300-boot.list` - 20 packages</sub>

| Package | Description |
|---|---|
| `casper` | Run a "live" preinstalled system from read-only media |
| `dosfstools` | utilities for making and checking MS-DOS FAT filesystems |
| `efibootmgr` | Interact with the EFI Boot Manager |
| `grub-efi-amd64` | GRand Unified Bootloader, version 2 (EFI-AMD64 version) |
| `grub-efi-amd64-bin` | GRand Unified Bootloader, version 2 (EFI-AMD64 modules) |
| `grub-efi-amd64-signed` | GRand Unified Bootloader, version 2 (EFI-AMD64 version, signed) |
| `grub-pc-bin` | GRand Unified Bootloader, version 2 (PC/BIOS modules) |
| `initramfs-tools` | generic modular initramfs generator (automation) |
| `memtest86+` | stand-alone memory tester for x86 and x86-64 |
| `mokutil` | tools for manipulating machine owner keys |
| `mtools` | Tools for manipulating MSDOS files |
| `ntfs-3g` | read/write NTFS driver for FUSE |
| `os-prober` | utility to detect other OSes on a set of drives |
| `plymouth` | boot animation, logger and I/O multiplexer |
| `plymouth-label` | boot animation, logger and I/O multiplexer - label control |
| `plymouth-theme-spinner` | boot animation, logger and I/O multiplexer - spinner theme |
| `sbsigntool` | Tools to manipulate signatures on UEFI binaries and drivers |
| `shim-signed` | Secure Boot chain-loading bootloader (Microsoft-signed binary) |
| `squashfs-tools` | Tool to create and append to squashfs filesystems |
| `systemd-resolved` | systemd DNS resolver |

## Debian Forensics metapackage
<sub>`config/package-lists/1000-forensics-meta.list` - 1 packages</sub>

| Package | Description |
|---|---|
| `forensics-all` | Debian Forensics Environment - essential components (metapackage) |

## Acquisition and imaging
<sub>`config/package-lists/1100-forensics-acquisition.list` - 34 packages</sub>

| Package | Description |
|---|---|
| `afflib-tools` | Advanced Forensics Format Library (utilities) |
| `can-utils` | SocketCAN userspace utilities and tools |
| `cryptsetup` | disk encryption support - startup scripts |
| `dares` | rescue files from damaged CDs and DVDs (ncurses-interface) |
| `dc3dd` | patched version of GNU dd with forensic features |
| `dcfldd` | enhanced version of dd for forensics and security |
| `ddrescueview` | graphical viewer for GNU ddrescue map files |
| `ddrutility` | set of data recovery utilities for use with GNU ddrescue |
| `dmsetup` | Linux Kernel Device Mapper userspace library |
| `ewf-tools` | collection of tools for reading and writing EWF files |
| `gddrescue` | GNU data recovery tool |
| `guestfish` | guest filesystem shell |
| `guymager` | Forensic imaging tool based on Qt |
| `hdparm` | tune hard disk parameters for high performance |
| `kpartx` | create device mappings for partitions |
| `libguestfs-tools` | guest disk image management system - tools |
| `lvm2` | Linux Logical Volume Manager |
| `mdadm` | tool for managing Linux MD devices (software RAID) |
| `mtd-utils` | Memory Technology Device Utilities |
| `myrescue` | rescue data from damaged disks |
| `nvme-cli` | NVMe management tool |
| `ow-shell` | shell utilities to talk to an 1-Wire owserver |
| `ow-tools` | tools to monitor or inspect a ow-server link |
| `partclone` | Utility to clone and restore a partition |
| `qemu-utils` | QEMU utilities |
| `recoverdm` | recover files on disks with damaged sectors |
| `safecopy` | data recovery tool for problematic or damaged media |
| `scantool` | OBD-II vehicle diagnostic scanner |
| `sdparm` | Output and modify SCSI device parameters |
| `smartmontools` | control and monitor storage systems using S.M.A.R.T. |
| `tableau-parm` | tableau write-blocking bridge query/command utility |
| `testdisk` | Partition scanner and disk recovery tool, and PhotoRec file recovery tool |
| `xmount` | tool for crossmounting between disk image formats |
| `xva-img` | Citrix XenServer .xva disk extraction tool |

## Disk and file-system analysis
<sub>`config/package-lists/1200-forensics-filesystems.list` - 37 packages</sub>

| Package | Description |
|---|---|
| `apfsprogs` | experimental APFS tools for Linux |
| `btrfs-progs` | Checksumming Copy on Write Filesystem utilities |
| `disktype` | detection of content format of a disk or disk image |
| `dislocker` | read/write encrypted BitLocker volumes |
| `dmg2img` | Tool for converting compressed dmg files to hfsplus images |
| `dosfstools` | utilities for making and checking MS-DOS FAT filesystems |
| `erofs-utils` | Utilities for EROFS File System |
| `exfatprogs` | exFAT file system utilities |
| `f2fs-tools` | Tools for Flash-Friendly File System |
| `fuse3` | Filesystem in Userspace (3.x version) |
| `gdisk` | GPT fdisk text-mode partitioning tool |
| `gfs2-utils` | Global File System 2 - filesystem tools |
| `gparted` | GNOME partition editor |
| `hfsplus` | Tools to access HFS+ formatted volumes |
| `hfsprogs` | mkfs and fsck for HFS and HFS+ file systems |
| `jfsutils` | utilities for managing the JFS filesystem |
| `libbde-utils` | Tools to access the BitLocker Drive Encryption format. |
| `libfsapfs-utils` | APFS access library -- Utilities |
| `libfsntfs-utils` | NTFS access library -- Utilities |
| `libfvde-utils` | FileVault Drive Encryption access library -- Utilities |
| `libqcow-utils` | QEMU Copy-On-Write image format access library -- Utilities |
| `libsmraw-utils` | split RAW image format access library -- Utilities |
| `libvmdk-utils` | VMWare Virtual Disk format access library -- Utilities |
| `libvshadow-utils` | Volume Shadow Snapshot format access library -- Utilities |
| `libvslvm-utils` | Linux LVM volume system format access library -- Utilities |
| `mtools` | Tools for manipulating MSDOS files |
| `nilfs-tools` | Continuous Snapshotting Log-structured Filesystem |
| `ntfs-3g` | read/write NTFS driver for FUSE |
| `ocfs2-tools` | tools for managing OCFS2 cluster filesystems |
| `parted` | disk partition manipulator |
| `reiserfsprogs` | User-level tools for ReiserFS filesystems |
| `sleuthkit` | tools for forensics analysis on volume and filesystem data |
| `squashfs-tools` | Tool to create and append to squashfs filesystems |
| `squashfs-tools-ng` | New set of tools for working with SquashFS images |
| `sshfs` | filesystem client based on SSH File Transfer Protocol |
| `udftools` | tools for UDF filesystems and DVD/CD-R(W) drives |
| `xfsprogs` | Utilities for managing the XFS filesystem |

## Memory forensics
<sub>`config/package-lists/1300-forensics-memory.list` - 5 packages</sub>

| Package | Description |
|---|---|
| `aeskeyfind` | tool for locating AES keys in a captured memory image |
| `dwarfdump` | utility to dump DWARF debug information from ELF objects |
| `lime-forensics-dkms` | kernel module to memory dump (DKMS) |
| `memdump` | utility to dump memory contents to standard output |
| `rsakeyfind` | locates BER-encoded RSA private keys in memory images |

## Network forensics
<sub>`config/package-lists/1400-forensics-network.list` - 49 packages</sub>

| Package | Description |
|---|---|
| `arp-scan` | arp scanning and fingerprinting tool |
| `arpwatch` | Ethernet/FDDI station activity monitor |
| `bettercap` | Complete, modular, portable and easily extensible MITM framework |
| `bind9-dnsutils` | Clients provided with BIND 9 |
| `braa` | Mass SNMP scanner |
| `chaosreader` | trace network sessions and export it to html format |
| `darkstat` | network traffic analyzer |
| `driftnet` | picks out and displays images from network traffic |
| `dsniff` | Various tools to sniff network traffic for cleartext insecurities |
| `etherape` | graphical network monitor |
| `ettercap-text-only` | Ettercap console-mode executable |
| `fping` | sends ICMP ECHO_REQUEST packets to network hosts |
| `geoip-bin` | IP lookup command line tools that use the GeoIP library |
| `horst` | Highly Optimized Radio Scanning Tool |
| `hping3` | Active Network Smashing Tool |
| `ike-scan` | discover and fingerprint IKE hosts (IPsec VPN Servers) |
| `iperf3` | Internet Protocol bandwidth measuring tool |
| `lft` | layer-four traceroute |
| `masscan` | TCP port scanner |
| `mtr` | Full screen ncurses and X11 traceroute tool |
| `ncat` | NMAP netcat reimplementation |
| `netcat-openbsd` | TCP/IP swiss army knife |
| `netdiscover` | active/passive network address scanner using ARP requests |
| `netsniff-ng` | Linux network packet sniffer toolkit |
| `ngrep` | grep for network traffic |
| `nmap` | The Network Mapper |
| `onesixtyone` | fast and simple SNMP scanner |
| `p0f` | Passive OS fingerprinting tool |
| `packit` | network packet generator and capture tool |
| `pcapfix` | repairs broken pcap and pcapng files |
| `pcaputils` | specialized libpcap utilities |
| `proxychains4` | redirect connections through socks/http proxies (proxychains-ng) |
| `sipvicious` | tools to audit SIP based VoIP systems |
| `sngrep` | Ncurses SIP Messages flow viewer |
| `socat` | multipurpose relay for bidirectional data transfer |
| `ssldump` | SSLv3/TLS network protocol analyzer |
| `sslscan` | Tests SSL/TLS enabled services to discover supported cipher suites |
| `tcpdump` | command-line network traffic analyzer |
| `tcpflow` | TCP flow recorder |
| `tcpick` | TCP stream sniffer and connection tracker |
| `tcpreplay` | Tool to replay saved tcpdump files at arbitrary speeds |
| `tcptrace` | Tool for analyzing tcpdump output |
| `termshark` | Terminal UI for tshark, inspired by Wireshark |
| `testssl.sh` | Command line tool to check TLS/SSL ciphers, protocols and cryptographic flaws |
| `tshark` | network traffic analyzer - console version |
| `whois` | intelligent WHOIS client |
| `wireshark` | network traffic analyzer - graphical interface |
| `zenmap` | The Network Mapper Front End |
| `zmap` | network scanner for researchers |

## Malware analysis and reverse engineering
<sub>`config/package-lists/1500-forensics-malware-re.list` - 28 packages</sub>

| Package | Description |
|---|---|
| `androguard` | full Python tool to play with Android files |
| `apktool` | tool for reverse engineering Android apk files |
| `binwalk` | tool library for analyzing binary blobs and executable code |
| `capstone-tool` | lightweight multi-architecture disassembly framework - command line tool |
| `clamav` | anti-virus utility for Unix - command-line interface |
| `clamav-daemon` | anti-virus utility for Unix - scanner daemon |
| `de4dot` | .NET deobfuscator and unpacker |
| `edb-debugger` | cross platform x86/x86-64 debugger |
| `enjarify` | translate Dalvik bytecode to equivalent Java bytecode |
| `gdb` | GNU Debugger |
| `ghex` | GNOME Hex editor for files |
| `hexcompare` | utility to compare and identify binary files |
| `hexedit` | viewer and editor in hexadecimal or ASCII for files or devices |
| `libsmali-java` | assembler/disassembler for Android's dex format |
| `ltrace` | Tracks runtime library calls in dynamically linked programs |
| `nasm` | General-purpose x86 assembler |
| `okteta` | hexadecimal editor for binary files |
| `python3-capstone` | lightweight multi-architecture disassembly framework - Python bindings |
| `python3-distorm3` | powerful disassembler library for x86/AMD64 binary streams (Python3 bindings) |
| `python3-unicorn` | Lightweight CPU emulator framework (Python 3 bindings) |
| `python3-yara` | Python 3 bindings for YARA |
| `readpe` | command-line tools to manipulate Windows PE files |
| `shed` | simple hex editor with a pico-style interface |
| `strace` | System call tracer |
| `upx-ucl` | efficient live-compressor for executables |
| `wxhexeditor` | hexadecimal editor for massive files |
| `xxd` | tool to make (or reverse) a hex dump |
| `yara` | Pattern matching swiss knife for malware researchers |

## Passwords and cracking
<sub>`config/package-lists/1600-forensics-passwords.list` - 40 packages</sub>

| Package | Description |
|---|---|
| `aircrack-ng` | wireless WEP/WPA cracking utilities |
| `argon2` | memory-hard hashing function - utility |
| `bruteforce-luks` | Try to find a password of a LUKS encrypted volume |
| `bruteforce-salted-openssl` | try to find the passphrase for files encrypted with OpenSSL |
| `bruteforce-wallet` | try to find the password of an encrypted wallet file |
| `brutespray` | Python bruteforce tool |
| `bully` | Implementation of the WPS brute force attack, written in C |
| `ccrypt` | secure encryption and decryption of files and streams |
| `cewl` | custom word list generator |
| `chntpw` | NT SAM password recovery utility |
| `cowpatty` | Brute-force WPA dictionary attack |
| `creddump7` | Python tool to extract credentials and secrets from Windows registry hives |
| `crunch` | tool for creating wordlist |
| `cryptmount` | Management of encrypted file systems |
| `cupp` | generate dictionaries for attacks from personal data |
| `fcrackzip` | password cracker for zip archives |
| `gnupg2` | GNU privacy guard - a free PGP replacement (dummy transitional package) |
| `hashcat` | World's fastest and most advanced password recovery utility |
| `hashid` | Identify the different types of hashes used to encrypt data |
| `hcxkeys` | Tools to generate plainmasterkeys (rainbowtables) |
| `hcxtools` | Tools for converting captures to use with hashcat or John the Ripper |
| `hydra` | very fast network logon cracker |
| `john` | active password cracking tool |
| `maskprocessor` | high-performance word generator with a per-position configurable charset |
| `mdk4` | Wireless attack tool for IEEE 802.11 networks |
| `medusa` | fast, parallel, modular, login brute-forcer for network services |
| `ncrack` | High-speed network authentication cracking tool |
| `ophcrack` | Microsoft Windows password cracker using rainbow tables (gui) |
| `ophcrack-cli` | Microsoft Windows password cracker using rainbow tables (cmdline) |
| `patator` | Multi-purpose brute-forcer |
| `pdfcrack` | PDF files password cracker |
| `pixiewps` | Offline WPS bruteforce tool |
| `polenum` | Extracts the password policy from a Windows system |
| `princeprocessor` | standalone password candidate generator using the PRINCE algorithm |
| `rarcrack` | Password cracker for rar archives |
| `reaver` | brute force attack tool against Wi-Fi Protected Setup PIN number |
| `samdump2` | Dump Windows 2k/NT/XP password hashes |
| `statsprocessor` | word generator based on per-position Markov chains |
| `sucrack` | multithreaded su bruteforcer |
| `wifite` | Python script to automate wireless auditing using aircrack-ng tools |

## Steganography
<sub>`config/package-lists/1700-forensics-stego.list` - 10 packages</sub>

| Package | Description |
|---|---|
| `gifshuffle` | Steganography program to gif images |
| `outguess` | universal steganographic tool |
| `ruby-full` | Ruby full installation (default version) |
| `snowdrop` | plain text watermarking and watermark recovery |
| `stegcracker` | steganography brute-force tool |
| `steghide` | steganography hiding tool |
| `stegosuite` | steganography tool to hide information in image files |
| `stegseek` | Worlds fastest steghide cracker |
| `stegsnow` | steganography using ASCII files |
| `stepic` | Python 3 Steganography in Images |

## Timeline and artefact analysis
<sub>`config/package-lists/1800-forensics-timeline.list` - 27 packages</sub>

| Package | Description |
|---|---|
| `forensic-artifacts` | knowledge base of forensic artifacts (data files) |
| `galleta` | Internet Explorer cookie forensic analysis tool |
| `grokevt` | scripts for reading Microsoft Windows event log files |
| `libhivex-bin` | utilities for reading and writing Windows Registry hives |
| `lnav` | ncurses-based log file viewer |
| `mac-robber` | collects data about allocated files in mounted filesystems |
| `mblaze` | UNIX utilities to deal with Maildir |
| `mboxgrep` | Grep through mailboxes |
| `pasco` | Internet Explorer cache forensic analysis tool |
| `pff-tools` | utilities for MS Outlook PAB, PST and OST files |
| `plaso` | super timeline all the things -- metapackage |
| `pst-utils` | tools for reading Microsoft Outlook PST files |
| `python3-dfwinreg` | Digital Forensics Windows Registry library for Python 3 |
| `python3-evtx` | parser for recent Windows Event Log files -- Python 3 version |
| `python3-hivex` | Python 3 bindings for hivex |
| `reglookup` | utility to analysis for Windows NT-based registry |
| `regripper` | perform forensic analysis of registry hives |
| `rifiuti` | MS Windows recycle bin analysis tool |
| `rifiuti2` | replacement for rifiuti, a MS Windows recycle bin analysis tool |
| `ripmime` | Extract attachments out of MIME encoded emails |
| `sqlite3` | Command line interface for SQLite 3 |
| `sqlitebrowser` | GUI editor for SQLite databases |
| `time-decode` | Timestamp and datetime decoder/encoder |
| `undbx` | tool to extract, recover and undelete e-mail messages from .dbx files |
| `usbrip` | USB device artifacts tracker |
| `vinetto` | forensics tool to examine Thumbs.db files |
| `winregfs` | Windows registry FUSE filesystem |

## Documents and e-discovery
<sub>`config/package-lists/1900-forensics-docs.list` - 28 packages</sub>

| Package | Description |
|---|---|
| `ansifilter` | parse common (terminal) ANSI codes and remove or convert them |
| `antiword` | Converts MS Word files to text, PS, PDF and XML |
| `audacity` | fast, cross-platform audio editor |
| `catdoc` | text extractor for MS-Office files |
| `docx2txt` | Convert Microsoft OOXML files to plain text |
| `exif` | command-line utility to show EXIF information in JPEG files |
| `exifprobe` | read metadata from digital pictures |
| `exiftags` | utility to read Exif tags from a digital camera JPEG file |
| `exiv2` | EXIF/IPTC/XMP metadata manipulation tool |
| `ffmpeg` | Tools for transcoding, streaming and playing of multimedia files |
| `libimage-exiftool-perl` | library and program to read and write meta information in multimedia files |
| `mat2` | Metadata anonymisation toolkit v2 |
| `mdbtools` | JET / MS Access database (MDB) tools |
| `mediainfo` | command-line utility for reading information from audio/video files |
| `metacam` | extract EXIF information from digital camera files |
| `missidentify` | find win32 applications |
| `mupdf-tools` | command line tools for the MuPDF viewer |
| `ocrmypdf` | add an OCR text layer to PDF files |
| `pdfresurrect` | tool for extracting/scrubbing versioning data from PDF documents |
| `pecomato` | Picture-embedded contents manipulation tool |
| `pngcheck` | print info and check PNG, JNG and MNG files |
| `poppler-utils` | PDF utilities (based on Poppler) |
| `psrip` | Extract images from PostScript files |
| `qpdf` | tools for transforming and inspecting PDF files |
| `sox` | Swiss army knife of sound processing |
| `unrtf` | RTF to other formats converter |
| `vokoscreen-ng` | easy to use screencast creator |
| `wv` | Programs for accessing Microsoft Word documents |

## Mobile forensics
<sub>`config/package-lists/2000-forensics-mobile.list` - 10 packages</sub>

| Package | Description |
|---|---|
| `aapt` | Android Asset Packaging Tool |
| `adb` | Android Debug Bridge |
| `fastboot` | Android fastboot tool |
| `ideviceinstaller` | Utility to manage installed applications on an iDevice |
| `ifuse` | FUSE module for iPhone and iPod Touch devices |
| `ipheth-utils` | USB tethering driver support utilities for the iPhone |
| `libimobiledevice-utils` | Utitilies for communicating with iPhone and other Apple devices |
| `libplist-utils` | Apple property list converter |
| `mtp-tools` | Media Transfer Protocol (MTP) library tools |
| `usbmuxd` | USB multiplexor daemon for iPhone and iPod Touch devices |

## OSINT
<sub>`config/package-lists/2100-forensics-osint.list` - 21 packages</sub>

| Package | Description |
|---|---|
| `altdns` | Subdomain discovery through alterations and permutations |
| `cutycapt` | utility to capture WebKit's rendering of a web page |
| `dmitry` | Deepmagic Information Gathering Tool |
| `dnsenum` | tool to enumerate domain DNS information |
| `dnsrecon` | Powerful DNS enumeration script |
| `fierce` | Domain DNS scanner |
| `gobuster` | Directory/file & DNS busting tool written in Go |
| `httrack` | Copy websites to your computer (Offline browser) |
| `i2pd` | Full-featured C++ implementation of I2P client |
| `instaloader` | Instagram automatic photo downloader |
| `knockpy` | Python3 tool designed to enumerate subdomains on a target domain |
| `lynis` | security auditing tool for Unix based systems |
| `macchanger` | utility for manipulating the MAC address of network interfaces |
| `obfs4proxy` | pluggable transport proxy for Tor, implementing obfs4 |
| `python3-shodan` | Official Python library for Shodan (Python 3) |
| `sherlock` | Find usernames across social networks |
| `ssh-audit` | tool for ssh server auditing |
| `sublist3r` | Fast subdomains enumeration tool for penetration testers |
| `tor` | anonymizing overlay network for TCP |
| `wafw00f` | identify and fingerprint Web Application Firewall products |
| `whatweb` | Next generation web scanner |

## Incident response
<sub>`config/package-lists/2200-forensics-ir.list` - 14 packages</sub>

| Package | Description |
|---|---|
| `acct` | GNU Accounting utilities for process and login accounting |
| `aide` | Advanced Intrusion Detection Environment - dynamic binary |
| `chkrootkit` | rootkit detector |
| `clamtk` | graphical front-end for ClamAV |
| `firejail` | sandbox to restrict the application environment |
| `hashdeep` | recursively compute hashsums or piecewise hashings |
| `inetsim` | Software suite for simulating common internet services |
| `inotify-tools` | command-line programs providing a simple interface to inotify |
| `python3-impacket` | Python3 module to easily build and dissect network protocols |
| `qemu-system-x86` | QEMU full system emulation binaries (x86) |
| `rkhunter` | rootkit, backdoor, sniffer and exploit scanner |
| `suricata` | Next Generation Intrusion Detection and Prevention Tool |
| `tripwire` | file and directory integrity checker |
| `unhide` | forensic tool to find hidden processes and ports |

## Secure wiping
<sub>`config/package-lists/2300-forensics-wipe.list` - 5 packages</sub>

| Package | Description |
|---|---|
| `bleachbit` | delete unnecessary files from the system |
| `nwipe` | Utility to securely erase disks |
| `scrub` | writes patterns on magnetic media to thwart data recovery |
| `secure-delete` | tools to wipe files, free disk space, swap and memory |
| `wipe` | secure file deletion |

## SDR and radio
<sub>`config/package-lists/2400-forensics-sdr.list` - 17 packages</sub>

| Package | Description |
|---|---|
| `airspy` | Tiny and efficient software defined radio receiver - utilities |
| `airspyhf` | HF+VHF software defined radio receiver - user runtime |
| `bladerf` | Nuand bladeRF software-defined radio device (tools) |
| `chirp` | Configuration tool for amateur radios |
| `gnuradio` | GNU Radio Software Radio Toolkit |
| `gqrx-sdr` | Software defined radio receiver |
| `gr-air-modes` | Gnuradio Mode-S/ADS-B radio |
| `gr-iqbal` | GNU Radio Blind IQ imbalance estimator and correction |
| `gr-osmosdr` | Gnuradio blocks from the OsmoSDR project |
| `hackrf` | Software defined radio peripheral - utilities |
| `inspectrum` | tool for visualising captured radio signals |
| `multimon-ng` | digital radio transmission decoder |
| `rfdump` | tool to decode RFID tag data |
| `rtl-433` | Decode 433.9 Mhz data |
| `rtl-sdr` | Software defined radio receiver for Realtek RTL2832U (tools) |
| `soapysdr-tools` | software defined radio interface library tools |
| `uhd-host` | universal hardware driver for Ettus Research products - host apps |

## Parrot OS / CSI Linux parity additions
<sub>`config/package-lists/2500-parrot-csi-parity.list` - 32 packages</sub>

| Package | Description |
|---|---|
| `android-sdk-platform-tools-common` | Tools for interacting with an Android platform - Common files |
| `autopsy` | graphical interface to SleuthKit |
| `ent` | pseudorandom number sequence test program |
| `ffuf` | Fast web fuzzer written in Go (program) |
| `gdb-multiarch` | GNU Debugger (with support for multiple architectures) |
| `ghostscript` | interpreter for the PostScript language and for PDF |
| `guestfs-tools` | guest disk image management system - tools |
| `hashcat-data` | Data files for hashcat advanced password recovery utility |
| `john-data` | active password cracking tool - character sets |
| `libewf-dev` | support for Expert Witness Compression format (development) |
| `nbtscan` | scan networks searching for NetBIOS information |
| `origami` | command-line management tool for Folding @ Home clients |
| `pev` | text-based tool to analyze PE files (transitional package) |
| `proxychains` | proxy chains - redirect connections through proxy servers |
| `python3-artifacts` | knowledge base of forensic artifacts (Python 3) |
| `python3-dfvfs` | Digital Forensics Virtual File System |
| `python3-pefile` | Portable Executable (PE) parsing module for Python |
| `python3-plaso` | super timeline all the things -- Python 3 |
| `python3-pwntools` | CTF framework and exploit development library |
| `python3-scapy` | Packet generator/sniffer and network scanner/discovery (Python 3) |
| `radare2` | free and advanced command line hexadecimal editor |
| `scrcpy` | Display and control your Android device |
| `smbclient` | command-line SMB/CIFS clients for Unix |
| `smbmap` | handy SMB enumeration tool |
| `ssdeep` | recursive piecewise hashing tool |
| `sslsplit` | transparent and scalable SSL/TLS interception |
| `torbrowser-launcher` | helps download and run the Tor Browser Bundle |
| `torsocks` | use SOCKS-friendly applications with Tor |
| `wfuzz` | Web application bruteforcer |
| `yt-dlp` | downloader of videos from YouTube and other sites |
| `zulucrypt-cli` | tool for encrypting volumes |
| `zulucrypt-gui` | graphical front end for zulucrypt-cli |

## Installer and partitioning
<sub>`config/package-lists/2600-installer.list` - 9 packages</sub>

| Package | Description |
|---|---|
| `calamares` | distribution-independent installer framework |
| `gdisk` | GPT fdisk text-mode partitioning tool |
| `gparted` | GNOME partition editor |
| `pandoc` | general markup converter |
| `parted` | disk partition manipulator |
| `python3-parted` | Python 3 interface for libparted |
| `wmctrl` | control an EWMH/NetWM compatible X Window Manager |
| `xterm` | X terminal emulator |
| `zenity` | Display graphical dialog boxes from shell scripts |

## System and recovery utilities
<sub>`config/package-lists/3000-system.list` - 41 packages</sub>

| Package | Description |
|---|---|
| `aria2` | High speed download utility |
| `bash-completion` | programmable completion for the bash shell |
| `btop` | Modern and colorful command line resource monitor that shows usage and stats |
| `cabextract` | Microsoft Cabinet file unpacker |
| `duf` | Disk Usage/Free Utility |
| `ext3grep` | tool to help recover deleted files on ext3 filesystems |
| `ext4magic` | recover deleted files from ext3 or ext4 partitions |
| `extundelete` | utility to recover deleted files from ext3/ext4 partition |
| `fatcat` | FAT filesystem explore, extract, repair, and forensic tool |
| `foremost` | forensic program to recover lost files |
| `gpart` | Guess PC disk partition table, find lost partitions |
| `htop` | interactive processes viewer |
| `inxi` | full featured system information script |
| `less` | pager program similar to more |
| `lshw` | information about hardware configuration |
| `lz4` | Fast LZ compression algorithm library - tool |
| `magicrescue` | recover files by looking for magic bytes |
| `mc` | Midnight Commander - a powerful file manager |
| `most` | Pager program similar to more and less |
| `nano` | small, friendly text editor inspired by Pico |
| `ncdu` | ncurses disk usage viewer |
| `openssh-client` | secure shell (SSH) client, for secure access to remote machines |
| `p7zip-full` | transitional package |
| `pciutils` | PCI utilities |
| `pigz` | Parallel Implementation of GZip |
| `pv` | Shell pipeline element to meter data passing through |
| `rclone` | rsync for commercial cloud storage |
| `recoverjpeg` | recover JFIF (JPEG) pictures and MOV movies |
| `rsync` | fast, versatile, remote (and local) file-copying tool |
| `scalpel` | fast filesystem-independent file recovery |
| `screen` | terminal multiplexer with VT100/ANSI terminal emulation |
| `scrounge-ntfs` | Data recovery program for NTFS filesystems |
| `testdisk` | Partition scanner and disk recovery tool, and PhotoRec file recovery tool |
| `tmux` | terminal multiplexer |
| `tree` | displays an indented directory tree, in color |
| `unrar-free` | Unarchiver for .rar files |
| `usbutils` | Linux USB utilities |
| `vim` | Vi IMproved - enhanced vi editor |
| `xz-utils` | XZ-format compression utilities |
| `zip` | Archiver for .zip files |
| `zstd` | fast lossless compression algorithm -- CLI tool |

## Pulled in by forensics-all
<sub>dependencies of the `forensics-all` metapackage not already listed above - 21 packages</sub>

| Package | Description |
|---|---|
| `aesfix` | tool for correcting bit errors in an AES key schedule |
| `btscanner` | ncurses-based scanner for Bluetooth devices |
| `cisco7crack` | Crypt and decrypt the cisco type 7 passwords |
| `crack` | Password guessing program (crypt() variant) |
| `dirb` | URL bruteforcing tool |
| `doona` | Network fuzzer forked from bed |
| `ed2k-hash` | tool for generating ed2k-links |
| `forensics-colorize` | show differences between files using color graphics |
| `hashrat` | hashing tool supporting several hashes and recursivity |
| `mfcuk` | MiFare Classic Universal toolKit |
| `mfoc` | MIFARE Classic offline cracker |
| `nasty` | tool which helps you to recover your GPG passphrase |
| `ndiff` | The Network Mapper - result compare utility |
| `o-saft` | SSL advanced forensic tool |
| `pipebench` | measure the speed of stdin/stdout communication |
| `pnscan` | Multi threaded port scanner |
| `pompem` | Exploit and Vulnerability Finder |
| `rephrase` | Specialized passphrase recovery tool for GnuPG |
| `rhash` | utility for computing hash sums and magnet links |
| `unhide.rb` | Forensics tool to find processes hidden by rootkits |
| `wapiti` | web application vulnerability scanner |

## Installed from PyPI (pipx)
<sub>`config/hooks/0300-pipx-tools.hook` - each in its own isolated venv</sub>

| Tool | Description |
|---|---|
| **volatility3** | Volatility 3 memory-forensics framework |
| **mitmproxy** | Interactive HTTPS proxy for traffic inspection |
| **oletools** | Analyse Microsoft OLE2/Office files and macros (olevba, oleid, …) |
| **theharvester** | E-mail, subdomain and host OSINT gathering |
| **pysim** | SIM card reading and programming tools |
| **ghunt** | Google account OSINT |
| **sslyze** | TLS/SSL configuration scanner |
| **recon-ng** | Web reconnaissance framework |
| **plaso** | plaso / log2timeline super-timeline creation (current release) |
| **OnionSearch** | Search engine aggregator for .onion sites |
| **spiderfoot** | Automated OSINT collection and correlation |
| **osrframework** | Username, domain and e-mail OSINT (usufy, mailfy, …) |
| **maryam** | Modular OSINT framework |
| **waymore** | Wayback Machine URL and content discovery |
| **holehe** | Which sites an e-mail address is registered on |
| **maigret** | Username dossier across hundreds of sites |
| **socialscan** | Username / e-mail availability and OSINT |
| **h8mail** | E-mail breach and credential OSINT |
| **toutatis** | Instagram account OSINT |
| **pyhindsight** | Hindsight - web-browser history forensics (Chrome/Edge/Brave) |
| **mvt** | Mobile Verification Toolkit - iOS/Android spyware IOC triage |
| **andriller** | Android forensic extraction and decoding (GUI) |

## Built or fetched from upstream
<sub>`config/hooks/0200-ghidra.hook`, `0400-upstream-tools.hook`, `0100-whitesur-theme.hook`</sub>

| Tool | Description |
|---|---|
| **Ghidra** | NSA software reverse-engineering suite (from the official GitHub release) |
| **JADX** | Dex-to-Java decompiler with GUI |
| **Amass** | In-depth attack-surface / subdomain mapping (OWASP) |
| **assetfinder** | Subdomain discovery |
| **bulk_extractor** | High-speed feature extraction and carving (current upstream build) |
| **Didier Stevens Suite** | pdfid, pdf-parser, oledump, zipdump, emldump, … (PDF/Office malware triage) |
| **exiflooter** | Image EXIF geolocation OSINT |
| **hashcat-utils** | Wordlist and rule utilities for hashcat |
| **mdbtools (upstream)** | Microsoft Access .mdb/.accdb export (current build) |
| **metagoofil** | Metadata extraction from public documents |
| **pipal** | Password statistics analyser |
| **urlcrazy** | Typosquatting / URL variation generator |
| **zsteg** | PNG/BMP steganography detection |
| **WhiteSur theme** | macOS-style GTK/Shell theme and icons |
| **ArcMenu** | The "Apps" menu (GNOME Shell extension, from extensions.gnome.org) |

## Mobile and OSINT script tools (git)
<sub>`config/hooks/0450-script-tools.hook` - cloned, given a venv and a command wrapper</sub>

| Tool | Description |
|---|---|
| **iLEAPP** | iOS Logs, Events and Plists Parser (abrignoni) |
| **ALEAPP** | Android Logs, Events and Protobuf Parser |
| **RLEAPP** | Returns / cloud-data LEAPP parser |
| **VLEAPP** | Vehicle data LEAPP parser |
| **WLEAPP** | Windows LEAPP parser |
| **cLEAPP** | Chromebook LEAPP parser |
| **Photon** | Fast web crawler for OSINT |
| **Blackbird** | Username and e-mail search across social networks |
| **email2phonenumber** | Recover a phone number from an e-mail address (OSINT) |
| **RecuperaBit** | NTFS reconstruction and deleted-file recovery |
| **AutoTimeliner** | Automatic timeline extraction from memory images |
| **Carbon14** | Web-page age estimation (OSINT) |
| **DumpsterDiver** | Secrets and keys discovery in files |

## Web browser and e-mail
<sub>installed in the build's desktop stage from Mozilla (APT repo → PPA → official tarball)</sub>

| Tool | Description |
|---|---|
| **Firefox** | Web browser - real .deb from Mozilla (never a snap) |
| **Thunderbird** | E-mail client - from Mozilla, when published in their APT repo |

---
*Computer Forensics Lab Ltd - regenerate with `./scripts/make-tool-list.sh`*
