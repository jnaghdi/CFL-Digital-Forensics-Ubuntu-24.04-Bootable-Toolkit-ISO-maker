# Post-install notes & optional extras

## What the third-party hooks did

Upstream installs are logged inside the image at
`/var/log/cfl-forensics/third-party-tools.log` (`OK` / `WARN` per tool).
Anything marked WARN can be retried manually on the booted system.

## Keeping upstream tools fresh

```console
$ pipx upgrade-all                 # volatility3, mitmproxy, oletools, theHarvester, ...
$ sudo /opt/ghidra/support/...     # or simply re-download the latest Ghidra zip to /opt
```

## ClamAV

Signatures are fetched with `sudo freshclam` (needs network). The daemon is
installed but not required for on-demand scans: `clamscan -r /evidence/...`.

## LiME memory acquisition

The LiME kernel module is built by DKMS during the ISO build for the shipped
kernel - no setup required:

```console
$ sudo modprobe lime "path=/cases/mem-$(date +%Y%m%d-%H%M).lime format=lime"
```

Verify with `sudo modinfo lime`. If you later install to disk and upgrade the
kernel, DKMS rebuilds the module automatically (matching kernel headers must be
installed; rebuild manually with `sudo dkms autoinstall` if ever needed).

## Hashcat on CPU/GPU

For OpenCL on CPU: `sudo apt install pocl-opencl-icd`. For GPUs, install the
vendor driver stack (non-free repo is enabled).

## Volatility 3 symbol tables

First run downloads symbol packs as needed; to work offline, pre-fetch the
Windows/Linux/Mac symbol zips from the Volatility Foundation into
`~/.local/lib/python3*/site-packages/volatility3/symbols/`.

## Tools that could not be baked in

| Tool | How to add it on the booted system |
|---|---|
| **Zeek** | Use Zeek's own repo: `echo 'deb http://download.opensuse.org/repositories/security:/zeek/Debian_13/ /' | sudo tee /etc/apt/sources.list.d/zeek.list`, add its GPG key, then `apt install zeek` |
| **Kismet** | Build from source: https://www.kismetwireless.net/docs/readme/packages/ |
| **sysdig** | `apt install sysdig` exists in bookworm/forky, not trixie - build from GitHub |
| **tcpxtract** | Port from sid (`apt download tcpxtract` on a sid system) or use `foremost` on `tcpflow` output |
| **VeraCrypt** | Download from veracrypt.fr (licence prevents redistribution) |

## Changing the password / hardening

The live session runs as **root** by design - it is a forensics appliance,
not a daily driver. After installing to disk with Calamares you get a
normal account (sudo for elevation); consider enabling full-disk
encryption and re-enabling the screen lock (`Settings -> Privacy`).
