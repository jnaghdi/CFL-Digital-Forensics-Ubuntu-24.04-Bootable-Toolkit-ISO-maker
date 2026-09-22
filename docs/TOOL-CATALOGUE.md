# CFL Forensics - Tool Catalogue

Complete inventory of software shipped in the CFL Forensics image. Every entry below is open source and installed from the Debian 13 (trixie) repositories unless noted otherwise.


## Debian Forensics Blend (installed as metapackages)

`forensics-all` and `forensics-extra` pull in the full, community-maintained Debian Forensics toolset - acquisition, carving, crypto, stego, network, wireless, anti-forensics and more.


### forensics-all dependencies

| Package | Description |
|---|---|
| `aesfix` | tool for correcting bit errors in an AES key schedule |
| `afflib-tools` | Advanced Forensics Format Library (utilities) |
| `altdns` | Subdomain discovery through alterations and permutations |
| `argon2` | memory-hard hashing function - utility |
| `assetfinder` | Find domains and subdomains related to a given domain |
| `braa` | Mass SNMP scanner |
| `bruteforce-salted-openssl` | try to find the passphrase for files encrypted with OpenSSL |
| `bruteforce-wallet` | try to find the password of an encrypted wallet file |
| `btscanner` | ncurses-based scanner for Bluetooth devices |
| `capstone-tool` | lightweight multi-architecture disassembly framework - command line tool |
| `ccrypt` | secure encryption and decryption of files and streams |
| `cewl` | custom word list generator |
| `chaosreader` | trace network sessions and export it to html format |
| `chkrootkit` | rootkit detector |
| `cisco7crack` | Crypt and decrypt the cisco type 7 passwords |
| `cowpatty` | Brute-force WPA dictionary attack |
| `creddump7` | Python tool to extract credentials and secrets from Windows registry hives |
| `dc3dd` | patched version of GNU dd with forensic features |
| `dirb` | URL bruteforcing tool |
| `dislocker` | read/write encrypted BitLocker volumes |
| `dnsrecon` | Powerful DNS enumeration script |
| `doona` | Network fuzzer forked from bed |
| `ed2k-hash` | tool for generating ed2k-links |
| `ewf-tools` | collection of tools for reading and writing EWF files |
| `ext4magic` | recover deleted files from ext3 or ext4 partitions |
| `extundelete` | utility to recover deleted files from ext3/ext4 partition |
| `fatcat` | FAT filesystem explore, extract, repair, and forensic tool |
| `fcrackzip` | password cracker for zip archives |
| `forensic-artifacts` | knowledge base of forensic artifacts (data files) |
| `forensics-colorize` | show differences between files using color graphics |
| `galleta` | Internet Explorer cookie forensic analysis tool |
| `gpshell` | GlobalPlatform Shell smart card script interpreter |
| `graudit` | grep rough audit - source code auditing tool |
| `grokevt` | scripts for reading Microsoft Windows event log files |
| `hashdeep` | recursively compute hashsums or piecewise hashings |
| `hashid` | Identify the different types of hashes used to encrypt data |
| `hashrat` | hashing tool supporting several hashes and recursivity |
| `hcxkeys` | Tools to generate plainmasterkeys (rainbowtables) |
| `hcxtools` | Tools for converting captures to use with hashcat or John the Ripper |
| `hydra` | very fast network logon cracker |
| `john` | active password cracking tool |
| `mac-robber` | collects data about allocated files in mounted filesystems |
| `maskprocessor` | high-performance word generator with a per-position configurable charset |
| `masscan` | TCP port scanner |
| `memdump` | utility to dump memory contents to standard output |
| `metacam` | extract EXIF information from digital camera files |
| `mfcuk` | MiFare Classic Universal toolKit |
| `mfoc` | MIFARE Classic offline cracker |
| `missidentify` | find win32 applications |
| `myrescue` | rescue data from damaged disks |
| `nasty` | tool which helps you to recover your GPG passphrase |
| `nbtscan` | scan networks searching for NetBIOS information |
| `ncrack` | High-speed network authentication cracking tool |
| `ngrep` | grep for network traffic |
| `ophcrack-cli` | Microsoft Windows password cracker using rainbow tables (cmdline) |
| `outguess` | universal steganographic tool |
| `pasco` | Internet Explorer cache forensic analysis tool |
| `pff-tools` | utilities for MS Outlook PAB, PST and OST files |
| `pipebench` | measure the speed of stdin/stdout communication |
| `pixiewps` | Offline WPS bruteforce tool |
| `pnscan` | Multi threaded port scanner |
| `polenum` | Extracts the password policy from a Windows system |
| `pompem` | Exploit and Vulnerability Finder |
| `readpe` | command-line tools to manipulate Windows PE files |
| `recoverdm` | recover files on disks with damaged sectors |
| `recoverjpeg` | recover JFIF (JPEG) pictures and MOV movies |
| `regripper` | perform forensic analysis of registry hives |
| `rephrase` | Specialized passphrase recovery tool for GnuPG |
| `rhash` | utility for computing hash sums and magnet links |
| `rifiuti` | MS Windows recycle bin analysis tool |
| `rifiuti2` | replacement for rifiuti, a MS Windows recycle bin analysis tool |
| `rkhunter` | rootkit, backdoor, sniffer and exploit scanner |
| `rsakeyfind` | locates BER-encoded RSA private keys in memory images |
| `safecopy` | data recovery tool for problematic or damaged media |
| `samdump2` | Dump Windows 2k/NT/XP password hashes |
| `scalpel` | fast filesystem-independent file recovery |
| `scrounge-ntfs` | Data recovery program for NTFS filesystems |
| `shed` | simple hex editor with a pico-style interface |
| `sherlock` | Find usernames across social networks |
| `sleuthkit` | tools for forensics analysis on volume and filesystem data |
| `smbmap` | handy SMB enumeration tool |
| `snowdrop` | plain text watermarking and watermark recovery |
| `sploitscan` | Search for CVE information |
| `ssdeep` | recursive piecewise hashing tool |
| `ssldump` | SSLv3/TLS network protocol analyzer |
| `statsprocessor` | word generator based on per-position Markov chains |
| `stegsnow` | steganography using ASCII files |
| `sucrack` | multithreaded su bruteforcer |
| `tableau-parm` | tableau write-blocking bridge query/command utility |
| `tcpdump` | command-line network traffic analyzer |
| `tcpick` | TCP stream sniffer and connection tracker |
| `testssl.sh` | Command line tool to check TLS/SSL ciphers, protocols and cryptographic flaws |
| `undbx` | tool to extract, recover and undelete e-mail messages from .dbx files |
| `unhide` | forensic tool to find hidden processes and ports |
| `unhide.rb` | Forensics tool to find processes hidden by rootkits |
| `usbrip` | USB device artifacts tracker |
| `vinetto` | forensics tool to examine Thumbs.db files |
| `waymore` | Tool to discover extensive data from online archives |
| `wfuzz` | Web application bruteforcer |
| `winregfs` | Windows registry FUSE filesystem |
| `wipe` | secure file deletion |
| `yara` | Pattern matching swiss knife for malware researchers |

### forensics-all recommendations (auto-installed)

| Package | Description |
|---|---|
| `acct` | GNU Accounting utilities for process and login accounting |
| `aeskeyfind` | tool for locating AES keys in a captured memory image |
| `aircrack-ng` | wireless WEP/WPA cracking utilities |
| `bruteforce-luks` | Try to find a password of a LUKS encrypted volume |
| `brutespray` | Python bruteforce tool |
| `bully` | Implementation of the WPS brute force attack, written in C |
| `de4dot` | .NET deobfuscator and unpacker |
| `dsniff` | Various tools to sniff network traffic for cleartext insecurities |
| `exiflooter` | finds geolocation on all image urls and directories |
| `exifprobe` | read metadata from digital pictures |
| `ext3grep` | tool to help recover deleted files on ext3 filesystems |
| `gpart` | Guess PC disk partition table, find lost partitions |
| `hashcat` | World's fastest and most advanced password recovery utility |
| `ike-scan` | discover and fingerprint IKE hosts (IPsec VPN Servers) |
| `magicrescue` | recover files by looking for magic bytes |
| `mdk3` | Wireless attack tool for IEEE 802.11 networks |
| `mdk4` | Wireless attack tool for IEEE 802.11 networks |
| `medusa` | fast, parallel, modular, login brute-forcer for network services |
| `ncat` | NMAP netcat reimplementation |
| `ndiff` | The Network Mapper - result compare utility |
| `nmap` | The Network Mapper |
| `paramspider` | Mining parameters from the dark corners of Web Archives |
| `plaso` | super timeline all the things -- metapackage |
| `reglookup` | utility to analysis for Windows NT-based registry |
| `stegcracker` | steganography brute-force tool |
| `steghide` | steganography hiding tool |
| `stegseek` | Worlds fastest steghide cracker |
| `time-decode` | Timestamp and datetime decoder/encoder |
| `wapiti` | not available in trixie - skipped by apt |
| `wifite` | Python script to automate wireless auditing using aircrack-ng tools |
| `xmount` | tool for crossmounting between disk image formats |

### forensics-extra dependencies

| Package | Description |
|---|---|
| `ancient` | decompression routines for ancient formats |
| `ansifilter` | parse common (terminal) ANSI codes and remove or convert them |
| `arc` | archive utility based on the MS-DOS ARC program |
| `bfbtester` | Brute Force Binary Tester |
| `bind9-dnsutils` | Clients provided with BIND 9 |
| `binutils` | GNU assembler, linker and binary utilities |
| `brotli` | lossless compression algorithm and format (command line utility) |
| `bzip2` | high-quality block-sorting file compressor - utilities |
| `bzip3` | better, faster and stronger spiritual successor to bzip2 - utilities |
| `cabextract` | Microsoft Cabinet file unpacker |
| `clzip` | C, lossless data compressor based on the LZMA algorithm |
| `comprez` | frontend to many compression programs |
| `crunch` | tool for creating wordlist |
| `cryptmount` | Management of encrypted file systems |
| `cupp` | generate dictionaries for attacks from personal data |
| `curl` | command line tool for transferring data with URL syntax |
| `dares` | rescue files from damaged CDs and DVDs (ncurses-interface) |
| `dcfldd` | enhanced version of dd for forensics and security |
| `ddrutility` | set of data recovery utilities for use with GNU ddrescue |
| `dhcpdump` | Parse DHCP packets from a network interface |
| `dictconv` | convert a dictionary file type to another dictionary file type |
| `diffstat` | produces graph of changes introduced by a diff file |
| `disktype` | detection of content format of a disk or disk image |
| `dmitry` | Deepmagic Information Gathering Tool |
| `dtach` | emulates the detach/attach feature of screen |
| `erofs-utils` | Utilities for EROFS File System |
| `ethstatus` | console-based ethernet statistics monitor |
| `ethtool` | display or change Ethernet device settings |
| `exif` | command-line utility to show EXIF information in JPEG files |
| `exiftags` | utility to read Exif tags from a digital camera JPEG file |
| `exiv2` | EXIF/IPTC/XMP metadata manipulation tool |
| `fdupes` | identifies duplicate files within given directories |
| `foremost` | forensic program to recover lost files |
| `funcoeszz` | script with 170+ useful mini applications |
| `gddrescue` | GNU data recovery tool |
| `gdisk` | GPT fdisk text-mode partitioning tool |
| `geoip-bin` | IP lookup command line tools that use the GeoIP library |
| `gifshuffle` | Steganography program to gif images |
| `heartbleeder` | test servers for OpenSSL CVE-2014-0160 aka Heartbleed |
| `hexcompare` | utility to compare and identify binary files |
| `hexedit` | viewer and editor in hexadecimal or ASCII for files or devices |
| `horst` | Highly Optimized Radio Scanning Tool |
| `hping3` | Active Network Smashing Tool |
| `imageindex` | generate static HTML galleries from images |
| `inxi` | full featured system information script |
| `ipgrab` | tcpdump-like utility that prints detailed header information |
| `ipv6toolkit` | Security assessment and troubleshooting tool for the IPv6 protocols |
| `jdupes` | identify and delete or link duplicate files |
| `less` | pager program similar to more |
| `libimage-exiftool-perl` | library and program to read and write meta information in multimedia files |
| `lltdscan` | Scan for LLTD-enabled hosts on your network |
| `lrzip` | compression program with a very high compression ratio |
| `lshw` | information about hardware configuration |
| `lynis` | security auditing tool for Unix based systems |
| `lz4` | Fast LZ compression algorithm library - tool |
| `lzma` | Compression and decompression in the LZMA format - command line utility |
| `lzop` | fast compression program |
| `mblaze` | UNIX utilities to deal with Maildir |
| `mboxgrep` | Grep through mailboxes |
| `mc` | Midnight Commander - a powerful file manager |
| `mdns-scan` | Scan for mDNS/DNS-SD services published on the local network |
| `memstat` | Identify what's using up virtual memory |
| `minizip` | compression library - minizip tools |
| `mpack` | tools for encoding/decoding MIME messages |
| `mscompress` | Microsoft "compress.exe/expand.exe" compatible (de)compressor |
| `nasm` | General-purpose x86 assembler |
| `nast` | packet sniffer and lan analyzer |
| `ncompress` | original Lempel-Ziv compress/uncompress programs |
| `netcat-openbsd` | TCP/IP swiss army knife |
| `netdiscover` | active/passive network address scanner using ARP requests |
| `nomarch` | Unpacks .ARC and .ARK MS-DOS archives |
| `ntfs-3g` | read/write NTFS driver for FUSE |
| `openpace` | cryptographic library for EAC version 2 (tools) |
| `packit` | network packet generator and capture tool |
| `parted` | disk partition manipulator |
| `pcapfix` | repairs broken pcap and pcapng files |
| `pcaputils` | specialized libpcap utilities |
| `pdfcrack` | PDF files password cracker |
| `pecomato` | Picture-embedded contents manipulation tool |
| `plzip` | parallel, lossless data compressor based on the LZMA algorithm |
| `png-definitive-guide` | PNG: The Definitive Guide |
| `pngcheck` | print info and check PNG, JNG and MNG files |
| `poppler-utils` | PDF utilities (based on Poppler) |
| `psrip` | Extract images from PostScript files |
| `rarcrack` | Password cracker for rar archives |
| `readstat` | read/write data sets from SAS, Stata, and SPSS |
| `rzip` | compression program for large files |
| `scrot` | command line screen capture utility |
| `secure-delete` | tools to wipe files, free disk space, swap and memory |
| `sipcrack` | SIP login dumper/cracker |
| `sipgrep` | command line tool to sniff, capture, display SIP messages |
| `sipvicious` | tools to audit SIP based VoIP systems |
| `sngrep` | Ncurses SIP Messages flow viewer |
| `squashfs-tools-ng` | New set of tools for working with SquashFS images |
| `ssh-audit` | tool for ssh server & client auditing |
| `sslscan` | Tests SSL/TLS enabled services to discover supported cipher suites |
| `stepic` | Python 3 Steganography in Images |
| `tcpflow` | TCP flow recorder |
| `tcptrace` | Tool for analyzing tcpdump output |
| `tshark` | network traffic analyzer - console version |
| `ugrep` | faster grep with an interactive query UI |
| `unrar-free` | Unarchiver for .rar files |
| `unzip` | De-archiver for .zip files |
| `wamerican` | American English dictionary words for /usr/share/dict |
| `wamerican-huge` | American English dictionary words for /usr/share/dict |
| `wamerican-insane` | American English dictionary words for /usr/share/dict |
| `wamerican-large` | American English dictionary words for /usr/share/dict |
| `wamerican-small` | American English dictionary words for /usr/share/dict |
| `wbrazilian` | Brazilian Portuguese wordlist |
| `wbritish` | British English dictionary words for /usr/share/dict |
| `wbritish-huge` | British English dictionary words for /usr/share/dict |
| `wbritish-insane` | British English dictionary words for /usr/share/dict |
| `wbritish-large` | British English dictionary words for /usr/share/dict |
| `wbritish-small` | British English dictionary words for /usr/share/dict |
| `wbulgarian` | Bulgarian dictionary words for /usr/share/dict |
| `wcanadian` | Canadian English dictionary words for /usr/share/dict |
| `wcanadian-huge` | Canadian English dictionary words for /usr/share/dict |
| `wcanadian-insane` | Canadian English dictionary words for /usr/share/dict |
| `wcanadian-large` | Canadian English dictionary words for /usr/share/dict |
| `wcanadian-small` | Canadian English dictionary words for /usr/share/dict |
| `wcatalan` | Catalan dictionary words for /usr/share/dict |
| `weplab` | tool designed to break WEP keys |
| `wesperanto` | Esperanto dictionary words for /usr/share/dict |
| `wfaroese` | Faroese dictionary / wordlist |
| `wfrench` | French dictionary words for /usr/share/dict |
| `wgaelic` | Scots Gaelic word list |
| `wgerman-medical` | German medical dictionary words for /usr/share/dict |
| `whatweb` | Next generation web scanner |
| `whois` | intelligent WHOIS client |
| `wirish` | Irish (Gaeilge) dictionary words for /usr/share/dict |
| `witalian` | Italian dictionary words for /usr/share/dict/ |
| `wmanx` | Manx Gaelic dictionary words for /usr/share/dict |
| `wngerman` | New German orthography wordlist |
| `wpolish` | Polish dictionary words for /usr/share/dict |
| `wportuguese` | European Portuguese wordlist |
| `wspanish` | Spanish dictionary words for /usr/share/dict |
| `wswedish` | Swedish dictionary words for /usr/share/dict |
| `wswiss` | Swiss (German) orthography wordlist |
| `wukrainian` | Ukrainian dictionary words for /usr/share/dict |
| `wzip` | Lossy compression and denoising |
| `xva-img` | Citrix XenServer .xva disk extraction tool |
| `xxd` | tool to make (or reverse) a hex dump |
| `xz-utils` | XZ-format compression utilities |
| `zpaq` | maximum reference compressor for ZPAQ open standard |

## Curated additions (explicit package lists)


### GNOME desktop, macOS theme toolchain & workstation apps - `config/package-lists/0100-desktop.list.chroot`

| Package | Description |
|---|---|
| `baobab` | GNOME disk usage analyzer |
| `build-essential` | Informational list of build-essential packages |
| `cherrytree` | hierarchical note taking application |
| `cifs-utils` | Common Internet File System utilities |
| `curl` | command line tool for transferring data with URL syntax |
| `dialog` | Displays user-friendly dialog boxes from shell scripts |
| `dkms` | Dynamic Kernel Module System (DKMS) |
| `eog` | Eye of GNOME graphics viewer program |
| `evince` | Document (PostScript, PDF) viewer |
| `file-roller` | archive manager for GNOME |
| `firefox-esr` | Mozilla Firefox web browser - Extended Support Release (ESR) |
| `fonts-inter` | Inter font family |
| `fonts-inter-variable` | Inter font family (VF) |
| `fonts-jetbrains-mono` | free and open-source typeface for developers |
| `fonts-powerline` | prompt and statusline utility (symbols font) |
| `gdm3` | GNOME Display Manager |
| `gimp` | GNU Image Manipulation Program |
| `git` | fast, scalable, distributed revision control system |
| `gnome-core` | GNOME Desktop Environment -- essential components |
| `gnome-disk-utility` | manage and configure disk drives and media |
| `gnome-shell-extension-appindicator` | AppIndicator, KStatusNotifierItem and tray support for GNOME Shell |
| `gnome-shell-extension-arc-menu` | shell extension designed to provide a panel menu |
| `gnome-shell-extension-dashtodock` | dash-to-dock extension for GNOME shell |
| `gnome-shell-extension-desktop-icons-ng` | desktop icon support for GNOME Shell |
| `gnome-shell-extensions` | Extensions to extend functionality of GNOME Shell |
| `gnome-terminal` | GNOME terminal emulator application |
| `gnome-text-editor` | simple text editor for GNOME |
| `gnome-tweaks` | tool to adjust advanced configuration settings for GNOME |
| `gvfs` | userspace virtual filesystem - GIO module |
| `gvfs-backends` | userspace virtual filesystem - backends |
| `gvfs-fuse` | userspace virtual filesystem - fuse server |
| `imagemagick` | image manipulation programs -- binaries |
| `libglib2.0-bin` | Programs for the GLib library |
| `libglib2.0-dev-bin` | Development utilities for the GLib library |
| `libreoffice-calc` | office productivity suite -- spreadsheet |
| `libreoffice-writer` | office productivity suite -- word processor |
| `libxml2-utils` | GNOME XML library - utilities |
| `linux-headers-amd64` | Header files for Linux amd64 configuration (meta-package) |
| `network-manager-gnome` | transitional package for network-manager-applet and nm-connection-editor |
| `openjdk-21-jre` | OpenJDK Java runtime, using Hotspot JIT |
| `optipng` | advanced PNG (Portable Network Graphics) optimizer |
| `pipx` | execute binaries from Python packages in isolated environments |
| `python3-pip` | Python package installer |
| `python3-venv` | venv module for python3 (default python3 version) |
| `sassc` | C/C++ port of the Sass CSS precompiler - command-line tool |
| `seahorse` | GNOME front end for GnuPG |
| `sudo` | Provide limited super user privileges to specific users |
| `thunderbird` | mail/news client with RSS, chat and integrated spam filter support |
| `udisks2` | D-Bus service to access and manipulate storage devices |
| `unzip` | De-archiver for .zip files |
| `vlc` | multimedia player and streamer |
| `wget` | retrieves files from the web |
| `xdg-user-dirs` | tool to manage well known user directories |
| `xdg-utils` | desktop integration utilities from freedesktop.org |
| `zsh` | shell with lots of features |

### Hardware support (non-free firmware for broad boot compatibility) - `config/package-lists/0200-firmware.list.chroot`

| Package | Description |
|---|---|
| `amd64-microcode` | Platform firmware and microcode for AMD CPUs and SoCs |
| `firmware-amd-graphics` | Binary firmware for AMD/ATI graphics and NPU chips |
| `firmware-atheros` | Binary firmware for Qualcomm Atheros wireless cards |
| `firmware-brcm80211` | Binary firmware for Broadcom/Cypress 802.11 wireless cards |
| `firmware-iwlwifi` | Binary firmware for Intel Wireless cards |
| `firmware-linux-free` | Binary firmware for various drivers in the Linux kernel |
| `firmware-misc-nonfree` | Binary firmware for various drivers in the Linux kernel |
| `firmware-realtek` | Binary firmware for Realtek network and audio chips |
| `firmware-sof-signed` | Intel SOF firmware - signed |
| `intel-microcode` | Processor microcode firmware for Intel CPUs |

### Calamares graphical installer - `config/package-lists/0300-installer.list.chroot`

| Package | Description |
|---|---|
| `calamares` | distribution-independent installer framework |
| `calamares-settings-debian` | Debian theme and settings for the Calamares Installer |
| `os-prober` | utility to detect other OSes on a set of drives |

### Acquisition, imaging & write-blocking - `config/package-lists/1100-forensics-acquisition.list.chroot`

| Package | Description |
|---|---|
| `afflib-tools` | Advanced Forensics Format Library (utilities) |
| `cryptsetup` | disk encryption support - startup scripts |
| `dares` | rescue files from damaged CDs and DVDs (ncurses-interface) |
| `dc3dd` | patched version of GNU dd with forensic features |
| `dcfldd` | enhanced version of dd for forensics and security |
| `ddrescueview` | graphical viewer for GNU ddrescue map files |
| `ddrutility` | set of data recovery utilities for use with GNU ddrescue |
| `dmsetup` | Linux Kernel Device Mapper userspace library |
| `ewf-tools` | collection of tools for reading and writing EWF files |
| `gddrescue` | GNU data recovery tool |
| `guymager` | Forensic imaging tool based on Qt |
| `hdparm` | tune hard disk parameters for high performance |
| `kpartx` | create device mappings for partitions |
| `libguestfs-tools` | guest disk image management system - tools |
| `lvm2` | Linux Logical Volume Manager |
| `mdadm` | tool for managing Linux MD devices (software RAID) |
| `mtd-utils` | Memory Technology Device Utilities |
| `myrescue` | rescue data from damaged disks |
| `nvme-cli` | NVMe management tool |
| `partclone` | Utility to clone and restore a partition |
| `qemu-utils` | QEMU utilities |
| `recoverdm` | recover files on disks with damaged sectors |
| `safecopy` | data recovery tool for problematic or damaged media |
| `sdparm` | Output and modify SCSI device parameters |
| `smartmontools` | control and monitor storage systems using S.M.A.R.T. |
| `tableau-parm` | tableau write-blocking bridge query/command utility |
| `testdisk` | Partition scanner and disk recovery tool, and PhotoRec file recovery tool |
| `xmount` | tool for crossmounting between disk image formats |
| `xva-img` | Citrix XenServer .xva disk extraction tool |

### File-system analysis & container/encryption formats - `config/package-lists/1200-forensics-filesystems.list.chroot`

| Package | Description |
|---|---|
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
| `gparted` | GNOME partition editor |
| `hfsplus` | Tools to access HFS+ formatted volumes |
| `hfsprogs` | mkfs and fsck for HFS and HFS+ file systems |
| `jfsutils` | utilities for managing the JFS filesystem |
| `libbde-utils` | Tools to access the BitLocker Drive Encryption format. |
| `libfsapfs-utils` | APFS access library -- Utilities |
| `libfsntfs-utils` | NTFS access library -- Utilities |
| `libfvde-utils` | FileVault Drive Encryption access library -- Utilities |
| `libphdi-utils` | Parallels Hard Disk image (PHDI) format access library -- Utilities |
| `libqcow-utils` | QEMU Copy-On-Write image format access library -- Utilities |
| `libsmraw-utils` | split RAW image format access library -- Utilities |
| `libvmdk-utils` | VMWare Virtual Disk format access library -- Utilities |
| `libvshadow-utils` | Volume Shadow Snapshot format access library -- Utilities |
| `libvslvm-utils` | Linux LVM volume system format access library -- Utilities |
| `mtools` | Tools for manipulating MSDOS files |
| `nilfs-tools` | Continuous Snapshotting Log-structured Filesystem |
| `ntfs-3g` | read/write NTFS driver for FUSE |
| `parted` | disk partition manipulator |
| `squashfs-tools` | Tool to create and append to squashfs filesystems |
| `squashfs-tools-ng` | New set of tools for working with SquashFS images |
| `sshfs` | filesystem client based on SSH File Transfer Protocol |
| `udftools` | tools for UDF filesystems and DVD/CD-R(W) drives |
| `xfsprogs` | Utilities for managing the XFS filesystem |

### Memory acquisition & analysis (volatility3 via hook) - `config/package-lists/1300-forensics-memory.list.chroot`

| Package | Description |
|---|---|
| `aeskeyfind` | tool for locating AES keys in a captured memory image |
| `dwarfdump` | utility to dump DWARF debug information from ELF objects |
| `lime-forensics-dkms` | kernel module to memory dump (DKMS) |
| `memdump` | utility to dump memory contents to standard output |
| `rsakeyfind` | locates BER-encoded RSA private keys in memory images |

### Network forensics & traffic analysis - `config/package-lists/1400-forensics-network.list.chroot`

| Package | Description |
|---|---|
| `arp-scan` | arp scanning and fingerprinting tool |
| `arpwatch` | Ethernet/FDDI station activity monitor |
| `bettercap` | Complete, modular, portable and easily extensible MITM framework |
| `bind9-dnsutils` | Clients provided with BIND 9 |
| `braa` | Mass SNMP scanner |
| `chaosreader` | trace network sessions and export it to html format |
| `driftnet` | picks out and displays images from network traffic |
| `dsniff` | Various tools to sniff network traffic for cleartext insecurities |
| `ettercap-text-only` | Ettercap console-mode executable |
| `fping` | sends ICMP ECHO_REQUEST packets to network hosts |
| `geoip-bin` | IP lookup command line tools that use the GeoIP library |
| `horst` | Highly Optimized Radio Scanning Tool |
| `hping3` | Active Network Smashing Tool |
| `ike-scan` | discover and fingerprint IKE hosts (IPsec VPN Servers) |
| `iperf3` | Internet Protocol bandwidth measuring tool |
| `masscan` | TCP port scanner |
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
| `tcptrace` | Tool for analyzing tcpdump output |
| `termshark` | Terminal UI for tshark, inspired by Wireshark |
| `testssl.sh` | Command line tool to check TLS/SSL ciphers, protocols and cryptographic flaws |
| `whois` | intelligent WHOIS client |
| `wireshark` | network traffic analyzer - graphical interface |
| `zmap` | network scanner for researchers |

### Malware analysis & reverse engineering (Ghidra/jadx via hook) - `config/package-lists/1500-forensics-malware-re.list.chroot`

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
| `ltrace` | Tracks runtime library calls in dynamically linked programs |
| `nasm` | General-purpose x86 assembler |
| `okteta` | hexadecimal editor for binary files |
| `python3-capstone` | lightweight multi-architecture disassembly framework - Python bindings |
| `python3-unicorn` | Lightweight CPU emulator framework (Python 3 bindings) |
| `python3-yara` | Python 3 bindings for YARA |
| `readpe` | command-line tools to manipulate Windows PE files |
| `shed` | simple hex editor with a pico-style interface |
| `strace` | System call tracer |
| `upx-ucl` | efficient live-compressor for executables |
| `wxhexeditor` | hexadecimal editor for massive files |
| `xxd` | tool to make (or reverse) a hex dump |
| `yara` | Pattern matching swiss knife for malware researchers |

### Password recovery & crypto analysis - `config/package-lists/1600-forensics-passwords.list.chroot`

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

### Steganography - `config/package-lists/1700-forensics-stego.list.chroot`

| Package | Description |
|---|---|
| `gifshuffle` | Steganography program to gif images |
| `outguess` | universal steganographic tool |
| `ruby-full` | Ruby full installation (default version) |
| `snowdrop` | plain text watermarking and watermark recovery |
| `stegcracker` | steganography brute-force tool |
| `steghide` | steganography hiding tool |
| `stegseek` | Worlds fastest steghide cracker |
| `stegsnow` | steganography using ASCII files |
| `stepic` | Python 3 Steganography in Images |

### Timelines, registry & artifact analysis - `config/package-lists/1800-forensics-timeline.list.chroot`

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

### Document, media & metadata analysis - `config/package-lists/1900-forensics-docs.list.chroot`

| Package | Description |
|---|---|
| `ansifilter` | parse common (terminal) ANSI codes and remove or convert them |
| `antiword` | Converts MS Word files to text, PS, PDF and XML |
| `catdoc` | text extractor for MS-Office files |
| `docx2txt` | Convert Microsoft OOXML files to plain text |
| `exif` | command-line utility to show EXIF information in JPEG files |
| `exifprobe` | read metadata from digital pictures |
| `exiftags` | utility to read Exif tags from a digital camera JPEG file |
| `exiv2` | EXIF/IPTC/XMP metadata manipulation tool |
| `ffmpeg` | Tools for transcoding, streaming and playing of multimedia files |
| `libimage-exiftool-perl` | library and program to read and write meta information in multimedia files |
| `mat2` | Metadata anonymisation toolkit v2 |
| `mediainfo` | command-line utility for reading information from audio/video files |
| `metacam` | extract EXIF information from digital camera files |
| `missidentify` | find win32 applications |
| `mupdf-tools` | command line tools for the MuPDF viewer |
| `pecomato` | Picture-embedded contents manipulation tool |
| `pngcheck` | print info and check PNG, JNG and MNG files |
| `poppler-utils` | PDF utilities (based on Poppler) |
| `psrip` | Extract images from PostScript files |
| `qpdf` | tools for transforming and inspecting PDF files |
| `sox` | Swiss army knife of sound processing |
| `unrtf` | RTF to other formats converter |
| `wv` | Programs for accessing Microsoft Word documents |

### Mobile device forensics - `config/package-lists/2000-forensics-mobile.list.chroot`

| Package | Description |
|---|---|
| `adb` | Android Debug Bridge |
| `fastboot` | Android fastboot tool |
| `ideviceinstaller` | Utility to manage installed applications on an iDevice |
| `ifuse` | FUSE module for iPhone and iPod Touch devices |
| `ipheth-utils` | USB tethering driver support utilities for the iPhone |
| `libimobiledevice-utils` | Utitilies for communicating with iPhone and other Apple devices |
| `libplist-utils` | Apple property list converter |
| `mtp-tools` | Media Transfer Protocol (MTP) library tools |
| `usbmuxd` | USB multiplexor daemon for iPhone and iPod Touch devices |

### OSINT & reconnaissance (more via hook) - `config/package-lists/2100-forensics-osint.list.chroot`

| Package | Description |
|---|---|
| `altdns` | Subdomain discovery through alterations and permutations |
| `assetfinder` | Find domains and subdomains related to a given domain |
| `dmitry` | Deepmagic Information Gathering Tool |
| `dnsenum` | tool to enumerate domain DNS information |
| `dnsrecon` | Powerful DNS enumeration script |
| `exiflooter` | finds geolocation on all image urls and directories |
| `fierce` | Domain DNS scanner |
| `lynis` | security auditing tool for Unix based systems |
| `recon-ng` | Web Reconnaissance framework written in Python |
| `sherlock` | Find usernames across social networks |
| `ssh-audit` | tool for ssh server & client auditing |
| `sublist3r` | Fast subdomains enumeration tool for penetration testers |
| `waymore` | Tool to discover extensive data from online archives |
| `whatweb` | Next generation web scanner |

### Incident response & sandboxing - `config/package-lists/2200-forensics-ir.list.chroot`

| Package | Description |
|---|---|
| `acct` | GNU Accounting utilities for process and login accounting |
| `aide` | Advanced Intrusion Detection Environment - dynamic binary |
| `chkrootkit` | rootkit detector |
| `firejail` | sandbox to restrict the application environment |
| `inetsim` | Software suite for simulating common internet services |
| `qemu-system-x86` | QEMU full system emulation binaries (x86) |
| `rkhunter` | rootkit, backdoor, sniffer and exploit scanner |
| `suricata` | Next Generation Intrusion Detection and Prevention Tool |
| `tripwire` | file and directory integrity checker |
| `unhide` | forensic tool to find hidden processes and ports |

### Secure deletion & anti-forensics testing - `config/package-lists/2300-forensics-wipe.list.chroot`

| Package | Description |
|---|---|
| `bleachbit` | delete unnecessary files from the system |
| `nwipe` | Utility to securely erase disks |
| `scrub` | writes patterns on magnetic media to thwart data recovery |
| `secure-delete` | tools to wipe files, free disk space, swap and memory |
| `wipe` | secure file deletion |

### System & recovery utilities - `config/package-lists/3000-system.list.chroot`

| Package | Description |
|---|---|
| `aria2` | High speed download utility |
| `bash-completion` | programmable completion for the bash shell |
| `btop` | Modern and colorful command line resource monitor that shows usage and stats |
| `ca-certificates` | Common CA certificates |
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
| `tmux` | terminal multiplexer |
| `tree` | displays an indented directory tree, in color |
| `unrar-free` | Unarchiver for .rar files |
| `usbutils` | Linux USB utilities |
| `vim` | Vi IMproved - enhanced vi editor |
| `xz-utils` | XZ-format compression utilities |
| `zip` | Archiver for .zip files |
| `zstd` | fast lossless compression algorithm -- CLI tool |

## Installed from upstream during the build

These tools are not (or no longer) in Debian trixie, so the build hooks fetch them from their official upstream sources. Results are logged to `/var/log/cfl-forensics/third-party-tools.log` in the image.

| Tool | Description | Source |
|---|---|---|
| **Ghidra** | NSA software reverse-engineering suite (GUI) | GitHub release zip -> /opt/ghidra |
| **Volatility 3** | Advanced memory forensics framework | pipx |
| **mitmproxy** | Interactive HTTPS interception proxy | pipx |
| **oletools** | MS Office / OLE malware analysis (olevba, mraptor) | pipx |
| **theHarvester** | OSINT: e-mails, hosts, subdomains | pipx |
| **pySim** | SIM / smartcard analysis | pipx |
| **SpiderFoot** | OSINT automation engine | pipx (best effort) |
| **OSRFramework** | OSINT username / domain checks | pipx (best effort) |
| **Amass** | In-depth attack surface mapping & DNS enumeration | GitHub release -> /opt/tools |
| **JADX** | Android DEX-to-Java decompiler (CLI + GUI) | GitHub release -> /opt/jadx |
| **hashcat-utils** | Small hashcat companion utilities | source build |
| **bulk_extractor** | Bulk artifact scanner (e-mail, credit cards, URLs) | source build (best effort) |
| **pipal** | Password pattern / statistics analyser | git clone -> /opt/tools |
| **metagoofil** | Document metadata OSINT extractor | git clone (best effort) |
| **zsteg** | PNG/BMP steganography detector | ruby gem |
| **URLCrazy** | Typosquatting domain generator | git clone -> /opt/tools (ruby wrapper) |
| **pdfid** / **pdf-parser** | DidierStevens PDF triage | git clone -> /opt/tools/didierstevens (python3 wrappers) |
| **mdbtools** | MS Access database reader (mdb-tables …) | source build (best effort; not in trixie) |

## Deliberately not included

| Tool | Purpose | Why / alternative |
|---|---|---|
| Zeek (Bro) | network security monitor | Not in trixie; install from Zeek's own APT repo - see docs/POST-INSTALL.md |
| sysdig | system call tracer | Removed from trixie (present in bookworm/forky) |
| Kismet | wireless sniffer | Not packaged in trixie; build from upstream or use aircrack-ng/horst |
| tcpxtract | stream carving from pcaps | Removed from trixie; use foremost/scalpel on tcpflow output |
| hfsutils | classic Mac HFS tools | Removed from trixie; hfsprogs/hfsplus are included instead |
| dmraid | legacy RAID | Deprecated upstream; mdadm covers modern RAID |
| scrcpy | Android screen mirror | Not in trixie |
| bless | hex editor | Removed from trixie; ghex/okteta/wxHexEditor included |
| VeraCrypt | encrypted containers | Licence prevents Debian redistribution; dislocker/cryptsetup cover BitLocker/LUKS |
| Maltego | link analysis | Proprietary - out of scope for an all-open-source build |

## Added for CSI Linux parity

Cross-checked against CSI Linux's installer inventory (July 2026) - see
**[CSI-COMPARISON.md](CSI-COMPARISON.md)** for the full analysis and the
deliberate exclusions.

Debian packages:

| Area | Packages |
|---|---|
| Case workflow | `zenity` `wmctrl` `xterm` `pandoc` `cherrytree` `keepassxc` `gtkhash` |
| File systems | `apfsprogs` `gfs2-utils` `ocfs2-tools` `reiserfsprogs` |
| Acquisition | `can-utils` |
| Network | `mtr` `lft` |
| Documents/media | `pdfresurrect` `ocrmypdf` `audacity` `vokoscreen-ng` |
| Mobile | `aapt` |
| OSINT & anonymity | `knockpy` `cutycapt` `httrack` `tor` `obfs4proxy` `i2pd` `macchanger` |
| Incident response | `clamtk` `inotify-tools` `hashdeep` |
| Steganography | `stegosuite` |
| Signals (SDR) | `rtl-sdr` `rtl-433` `gqrx-sdr` `soapysdr-tools` `hackrf` `bladerf` `airspy` `airspyhf` |

From upstream via build hooks (best effort):

| Tool | Purpose |
|---|---|
| **iLEAPP / ALEAPP / RLEAPP / VLEAPP / WLEAPP / cLEAPP** | iOS / Android / app / vehicle / Windows / ChromeOS artefact parsers |
| **OnionSearch** | Dark-web (.onion) search |
| **GHunt** | Google-account OSINT |
| **Photon** | OSINT web crawler |
| **Blackbird** | Username search |
| **email2phonenumber** | Email → phone OSINT |
| **RecuperaBit** | Damaged NTFS reconstruction |
| **AutoTimeliner** | plaso super-timeline automation |
| **Carbon14** | USB/artefact timelines |
| **DumpsterDiver** | Secret/credential finder |


## Added for Kali Linux & Parrot OS parity

Cross-checked against Kali's `kali-tools-*` and Parrot's `parrot-tools-*`
metapackages (July 2026) - see
**[KALI-PARROT-COMPARISON.md](KALI-PARROT-COMPARISON.md)** for the full
analysis and exclusions (offensive/pentest categories are out of scope).

Debian packages:

| Area | Packages |
|---|---|
| Acquisition | `scantool` `ow-shell` `ow-tools` |
| Network | `tcpreplay` `zenmap` `darkstat` `etherape` |
| Malware/RE | `python3-distorm3` `libsmali-java` |
| Passwords | `patator` |
| Timeline/registry | `python3-dfwinreg` |
| OSINT | `gobuster` `instaloader` `wafw00f` |
| SDR | `gnuradio` `inspectrum` `multimon-ng` `gr-osmosdr` `gr-iqbal` `gr-air-modes` `uhd-host` `chirp` `rfdump` |

From upstream via build hooks: **SSLyze** (TLS analysis), **Maryam**
(OSINT framework), **URLCrazy** (typosquatting), **pdfid** and
**pdf-parser** (DidierStevens PDF triage), **mdbtools** (MS Access
reader, built from source).

### Imaging focus (Sumuri PALADIN parity)

PALADIN's imaging core - **DC3DD** (RAW), **LibEWF/ewfacquire** (E01),
**DDRescue** and **Guymager** - is fully shipped, together with the rest
of the libewf suite (`ewfverify`, `ewfinfo`, `ewfexport`, `ewfmount`),
`xmount`, `qemu-img` and `dislocker` (PALADIN Logical-Imager BitLocker
parity). On top of them sits **CFL Imaging Wizard** (`cfl-image`), a
PALADIN-Toolbox-style guided acquisition: pick a drive, pick a format
(RAW via dc3dd or E01 via ewfacquire), and it hashes (SHA-256), verifies
and writes an acquisition log - while refusing the live system disk and
refusing to image a drive onto itself.

All CLI launchers run inside **mate-terminal** (the terminal engine
Parrot Security ships) with the Parrot green-on-black profile, via the
`cfl-run` keep-alive wrapper.

### Removed launchers (cannot run cleanly on Debian 13)

| Launcher | Why removed | Alternative shipped |
|---|---|---|
| `radare2` / `rahash2` / `rasm2` | not in trixie; the upstream Ubuntu-built .deb pulls mismatched libraries and the tools died with "Status 255" | **ghidra**, `capstone-tool` (cstool), **readpe** |
| `pwdump` / `cachedump` / `lsadump` | creddump is Python 2 and unpackaged on trixie | **impacket** (`secretsdump.py`) - same capability |
| `osrframework` launcher | the pipx package's real entry point is `osrf` | launcher now calls `osrf` |
