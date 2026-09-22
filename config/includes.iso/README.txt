================================================================================
  CFL Forensics @CFL_VERSION@ "@CFL_CODENAME@" - Ubuntu @UBUNTU_VERSION@ LTS (@UBUNTU_SUITE@), @ARCH@
  Computer Forensics Lab Ltd - cflab.uk / e-discovery.uk   (build @BUILD_DATE@)
================================================================================

WHAT THIS IS
  A bootable digital-forensics and e-discovery workstation that runs entirely
  from this medium (DVD or USB) without touching the computer's internal disks,
  and can also be INSTALLED alongside an existing Windows or Linux system
  (dual-boot) using the "Install CFL Forensics" option in the boot menu.

BOOTING
  - BIOS (legacy) and UEFI are both supported. Secure Boot is supported via the
    Microsoft-signed shim -> Canonical-signed GRUB -> signed kernel chain.
  - At the boot menu:
      * Live (forensic mode)          - normal live session; software
                                        write-blocking is ON by default, so
                                        newly attached drives are treated as
                                        read-only by the desktop.
      * Live (write-blocking ON)      - same, made explicit.
      * Live (load entirely to RAM)   - copies the system to RAM; you may
                                        remove the medium once it is running.
      * Live (safe graphics)          - use if the screen is blank/garbled.
      * Install CFL Forensics         - launches the installer (dual-boot).
      * Utilities                     - medium self-check, memtest86+, UEFI
                                        firmware settings.

FIRST STEPS IN THE LIVE SESSION
  - The desktop auto-logs in as the unprivileged user "@LIVE_USER@".
  - Evidence handling:
      sudo forensics-mode on        treat newly attached drives as read-only
      sudo forensics-mode status    show the current state
      evidence-mount /dev/sdX1      mount a device strictly read-only under
                                    /evidence/  (ro,noexec,nodev,nosuid,noatime)
  - Automatic mounting of attached media is DISABLED on purpose. A hardware
    write-blocker remains the gold standard for acquiring evidence.
  - Tool inventory:   cfl-tools [keyword]
  - Case workspace:   /cases          Evidence mounts:  /evidence

INSTALLING ALONGSIDE WINDOWS (DUAL-BOOT)
  - Back up important data first. Installing changes the partition layout.
  - In Windows beforehand: disable "Fast startup" (Control Panel > Power
    Options) and, if BitLocker is enabled, suspend it or have your recovery
    key to hand, so the installer can safely resize the Windows partition.
  - The installer reserves at least @INSTALL_MIN_GIB@ GiB for CFL Forensics.
  - The clock is kept on UTC (forensic convention); if Windows shows the wrong
    time afterwards, that is the usual UTC-vs-localtime difference and can be
    adjusted in Windows.

INTEGRITY
  - Verify this image before writing it to a USB stick:
        sha256sum -c SHA256SUMS
  - md5sum.txt lists per-file checksums of the medium contents; the boot menu's
    "Check the boot medium for defects" entry verifies them at boot.

SUPPORT
  Computer Forensics Lab Ltd - @CFL_URL@
================================================================================
