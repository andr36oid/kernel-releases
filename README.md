# andr36oid kernel releases

Kernel updates for the andr36oid SD flasher. The flasher reads `kernels.json` here and,
when a console's build has a newer compatible kernel listed, offers to write just the new
kernel into the card's BOOT partition (no full reflash). Assets are GitHub release downloads
in this repo. No GitHub credentials are needed to read the index.

`kernels.json` starts empty, so the flasher finds no update and does nothing. Publishing a
kernel is a deliberate step (see below), because the kernel has to keep the exact vendor
module ABI and device trees of the builds it targets.

## Publishing a kernel update

1. Build the kernel you want to ship. For an update aimed at an already shipped build (for
   example the 2026-10-24 GA release), build from that build's own kernel source with only
   the needed config change added, so the kernel version and module ABI stay identical and
   the card's existing vendor modules still load. Do not ship a kernel from a diverged branch
   to an old build without checking that.
2. Package it: `package-kernel.sh <version> <out-dir> <Image> [dtb ...]`. Only `Image` is
   required; include DTBs or a `boot.ini` only if they changed, and a `boot.ini` must keep the
   card's DTB selection. The script prints the zip size and sha256.
3. Create a release and upload the zip as an asset:
   `gh release create kernel-updates <out-dir>/kernel-<version>.zip -R andr36oid/kernel-releases`
   (reuse the `kernel-updates` tag for later kernels; one tag can hold several assets).
4. Add an entry to `kernels.json` with the version, title, description, file name, the size
   and sha256 the script printed, and the exact `compatible_builds` identities
   (`ro.andr36oid.version|ro.product.build.version.incremental`) this kernel is safe for.
   Commit and push.

`SCHEMA.md` documents the index and bundle format the flasher enforces.
