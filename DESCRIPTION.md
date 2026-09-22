# CFL Forensics - project description

Three versions for different places: the one-liner (GitHub "About" field,
package metadata, social cards), the short paragraph (listings, directories,
press), and the full description (website "About" page, repository, release
notes).

---

## One-liner

**CFL Forensics** - a digital forensics and e-discovery workstation on Ubuntu 24.04 LTS: boot it live from USB or install it alongside Windows; 590+ tools, Secure Boot, and evidence-safe defaults built in.

---

## Short description

CFL Forensics is a complete Linux workstation for digital forensics, incident response, e-discovery and OSINT, built on Ubuntu 24.04 LTS by Computer Forensics Lab Ltd, a London forensics practice whose examiners give expert evidence in the civil and criminal courts. One image runs entirely from a USB stick without touching the host machine, or installs alongside an existing Windows or Linux system as a dual-boot. It boots on BIOS and UEFI with Secure Boot left on, and is designed around not altering evidence: software write-blocking is on from the moment the desktop starts, nothing is mounted automatically, swap is never activated and file-system journals are never replayed. It ships over 590 tools - from Guymager, The Sleuth Kit and Volatility 3 to Ghidra, plaso, the xLEAPP mobile parsers and a full OSINT suite - organised into a fourteen-category Apps menu, with every tool a native package and no snaps. The build system is open, reproducible and verifiable.

---

## Full description

### What it is

CFL Forensics is a bootable and installable Linux distribution for digital forensic examiners, incident responders, e-discovery practitioners and investigators. It is built on **Ubuntu 24.04 LTS** ("Noble Numbat") with the hardware-enablement kernel, so it boots on current hardware, and it is the working environment used in Computer Forensics Lab's own casework - released so any examiner can use it, audit it and rebuild it.

### Who makes it

Computer Forensics Lab Ltd (CFL) is a digital forensics and e-discovery practice based in London, founded in 2007. Its examiners undertake expert-witness work in civil (CPR Part 35) and criminal (CrimPR Part 19) matters, which shapes the design of this image: the priority is defensible evidence handling, not just tool count.

### Evidence-safe by default

Most live distributions will quietly write to a disk they should not touch. CFL Forensics is configured so that it does not:

- **Software write-blocking is enabled at boot.** Any drive attached after the desktop starts is treated as read-only.
- **No automatic mounting.** Attached media are not mounted or opened until the examiner chooses to, and `evidence-mount` mounts strictly read-only (`ro,noexec,nodev,nosuid,noatime`, with journal replay disabled).
- **No swap activation** on internal disks, and **no journal replay** while the live system searches for its own boot medium - two writes that the underlying live system would otherwise make silently.
- **No persistence partition** is ever created on the boot USB, so the medium's own hash stays constant.
- **The clock stays on UTC**, following forensic convention.

A hardware write-blocker remains the gold standard for acquisition; these defaults reduce the risk when one is not available.

### One image, two ways to run

- **Live** from USB or DVD - nothing on the machine is modified. A "load to RAM" option lets the medium be removed once running.
- **Install alongside Windows or Linux** - a guided installer (Calamares) sets up a dual-boot, keeping the existing system intact and reserving at least 128 GB for CFL Forensics.

Both paths boot on **BIOS and UEFI**, including machines with **Secure Boot enabled**, using the Microsoft-signed shim, Canonical-signed GRUB and signed kernel chain.

### The desktop and the tools

A GNOME desktop styled after macOS, with an **Apps** menu (bearing the CFL logo) that organises everything into fourteen forensic categories: Acquisition & Imaging · Disk & File Systems · Memory · Network · Malware & Reverse Engineering · Passwords · Steganography · Timeline & Artefacts · Documents & E-Discovery · Mobile · OSINT · Incident Response · Secure Wiping · SDR. Command-line tools open in a terminal with their usage on screen and a prompt ready for the real command.

The image contains **over 590 tools**, including Guymager, dc3dd, ewfacquire and ddrescue for acquisition; The Sleuth Kit, Autopsy, TestDisk/PhotoRec, foremost, scalpel and bulk_extractor for file-system work; Volatility 3 and LiME for memory; plaso/log2timeline, RegRipper and Hindsight for timelines and artefacts; PST/OST extraction, oletools, the Didier Stevens suite and ExifTool for documents and e-discovery; the iLEAPP/ALEAPP family, the Mobile Verification Toolkit and Andriller for mobile; Wireshark and tcpdump for network; Ghidra, radare2, JADX, binwalk, YARA and ClamAV for malware analysis; recon-ng, SpiderFoot, theHarvester, Sherlock, Maigret, Holehe, GHunt and Amass for OSINT; John the Ripper and hashcat for passwords; GNU Radio and gqrx for SDR; and nwipe for secure wiping. Every tool is a native `.deb`, an isolated `pipx` environment or an upstream build - **no snaps**. The complete, generated inventory is in `docs/TOOL-LIST.md`.

### Open, reproducible, verifiable

The entire build system is published under the MIT licence: a from-scratch `debootstrap` pipeline in eleven resumable stages, with every package list, hook and configuration file in the open. A static test suite of over a hundred checks guards the build, and each release ships SHA-256 checksums plus a per-file integrity check available from the boot menu. Anyone can rebuild the image from source and confirm it matches.

### Links

- Website: https://cflab.uk/ · https://computerforensicslab.co.uk/ · https://e-discovery.uk/
- Source and documentation: the project repository (`README.md`, `docs/`)
- Licence: MIT (build system); each bundled package retains its own licence
