# What to upload to GitHub - checklist

## 1. Upload the whole source tree (everything in the zip)

Push the project directory as-is. This is what the repository should contain:

| Path | What it is | Upload? |
|---|---|---|
| `README.md` | GitHub landing page | ✅ |
| `LICENSE` | MIT | ✅ |
| `CONTRIBUTING.md`, `CHANGELOG.md`, `SECURITY.md` | community + release docs | ✅ |
| `.github/workflows/ci.yml` | runs the static test suite on every push/PR | ✅ |
| `.github/ISSUE_TEMPLATE/`, `.github/PULL_REQUEST_TEMPLATE.md` | issue & PR templates | ✅ |
| `.gitignore` | keeps build output out of git | ✅ |
| `build.sh` | the build pipeline | ✅ |
| `cfl-build.conf` | all tunables | ✅ |
| `config/package-lists/*.list` (21 files) | packages, by purpose | ✅ |
| `config/hooks/*.hook` (10 files) | build-time steps | ✅ |
| `config/includes.chroot/` | launchers (317), dconf, live-session units, wallpaper, helpers | ✅ |
| `config/includes.iso/README.txt` | text at the root of the ISO | ✅ |
| `config/calamares/` | installer config + branding images | ✅ |
| `config/bootloaders/grub/` | boot menu, theme, splash, loopback | ✅ |
| `config/preseed/build.preseed` | debconf answers | ✅ |
| `scripts/` (8 scripts) | test-release, verify-packages, check-undefined-functions, fetch-ubuntu-keyring, test-iso-qemu, write-usb, make-tool-list, make-hashset | ✅ |
| `docs/` (12 files) | installing, build guide, building, customising, port notes, tool list, catalogue, parity, comparisons, upload checklist | ✅ |
| `DESCRIPTION.md` | project description (one-liner / short / full) | ✅ |
| `hashes/` | hash set of the source tree (regenerate with `scripts/make-hashset.sh` before each release) | ✅ |

The tree is ~9 MB (the largest items are the 4K wallpaper and GRUB splash,
~7 MB together) - well within normal git limits; **Git LFS is not needed**.

Before the first push, run these two once more from the project directory:

```bash
./scripts/test-release.sh      # 108 static checks - must show FAIL=0
./scripts/verify-packages.sh   # every package name resolves in the Ubuntu archive
```

Then:

```bash
git init
git add .
git commit -m "CFL Forensics 2.0 - Ubuntu 24.04 LTS rebuild"
git branch -M main
git remote add origin https://github.com/jnaghdi/CFL-Digital-Forensics-Ubuntu-24.04-Bootable-Toolkit-ISO-maker.git
git push -u origin main
```

The clone URLs in `README.md` and `docs/BUILD-GUIDE.md` already point at
`jnaghdi/CFL-Digital-Forensics-Ubuntu-24.04-Bootable-Toolkit-ISO-maker`; update them if the repository is renamed.

## 2. Do NOT upload

These are build outputs or scratch - `.gitignore` already excludes them, so
`git add .` will skip them, but do not force-add them:

| Path | Why not |
|---|---|
| `work/` | the chroot + scratch - tens of GB |
| `cache/` | downloaded `.deb` files |
| `iso/` and any `*.iso` | the finished image - see §3 for how to publish it |
| `*.log`, `build.log` | build logs (attach to an issue if needed, don't commit) |
| `SHA256SUMS`, `MD5SUMS` | belong on the Release, not in the source tree |

Also keep out anything from your own casework, any private signing keys, and
any customer data. (I scanned the tree: it contains none of these.)

## 3. Publishing a release

GitHub Releases are for the checksums and small artefacts; the ISO itself is
too large for a GitHub release asset (the per-file limit is 2 GB and the
image is larger), so host it on your own download server.

For each release:

1. Tag it: `git tag -a v2.0 -m "CFL Forensics 2.0" && git push origin v2.0`.
2. On GitHub, *Releases → Draft a new release*, choose the tag, paste the
   matching section of `CHANGELOG.md` as the notes.
3. Attach from your `iso/` folder:
   - `SHA256SUMS` and `MD5SUMS`
   - `cfl-forensics-2.0-noble-amd64.manifest` (package list of the image)
   - `cfl-forensics-2.0-noble-amd64.tool-health.txt`
   - `cfl-forensics-2.0-noble-amd64.packages-skipped.txt` (if present)
4. Upload the ISO to the CFL download server and put its URL (plus the SHA-256)
   in the release notes and in the README's *Download* line.

## 4. Repository settings worth switching on

- **Branch protection on `main`**: require the `static-checks` CI job to pass before merging.
- **Private vulnerability reporting** (Settings → Security) - `SECURITY.md` points people to it.
- **Discussions** (optional) for examiner Q&A, keeping Issues for bugs and tool requests.
- Add topics: `digital-forensics`, `dfir`, `e-discovery`, `ubuntu`, `live-iso`, `calamares`, `incident-response`, `osint`.
- Add a short description: *"Digital forensics & e-discovery workstation on Ubuntu 24.04 LTS - live USB or dual-boot install, 500+ tools, Secure Boot."*

## 5. Nice to have (later)

- **Screenshots** in a `docs/screenshots/` folder (boot menu, Apps menu, a tool
  running in the terminal, the installer) and link them from the README - the
  single most effective thing for a project page.
- A `docs/screenshots/` reference in the website promo.
- A `CODE_OF_CONDUCT.md` if you expect outside contributors.
