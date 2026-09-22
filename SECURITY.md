# Security policy

## Reporting a vulnerability

CFL Forensics is used to handle evidence, so we treat security reports seriously.
Please **do not** open a public issue for a vulnerability. E-mail
**security@cflab.uk** (or use GitHub's private vulnerability reporting on this
repository) with:

- the image version (`cat /etc/cfl-forensics-release`) or the commit hash,
- what the issue is and how to reproduce it,
- whether it affects the live session, the installed system, or the build.

You will get an acknowledgement within 5 working days. We will coordinate a fix
and credit you in the changelog unless you prefer otherwise.

## What counts

Especially: anything that causes the live system to **write to an attached or
internal disk** without the examiner's explicit action; anything that weakens the
Secure Boot chain or the integrity checks; and supply-chain issues in what the
build fetches (Mozilla repo, extensions.gnome.org, GitHub/PyPI tools).

## Supported versions

| Version | Supported |
|---|---|
| 2.x (Ubuntu 24.04) | yes |
| 1.x (Debian) | no |

## Verifying an image

Every release ships `SHA256SUMS`. Verify before writing to USB:

```bash
sha256sum -c SHA256SUMS
```

The boot menu also offers a per-file integrity check of the medium.
