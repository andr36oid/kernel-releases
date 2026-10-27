#!/bin/bash
# Package a kernel update zip for andr36oid/kernel-releases, matching the flasher's
# KernelManifest (internal/firmware/kernel.go) and index (internal/catalog/kernel.go).
# Usage: package-kernel.sh <version> <out-dir> <Image> [dtb ...]
# Writes <out-dir>/kernel-<version>.zip (manifest.json + Image + optional dtbs at root)
# and prints the zip size + sha256 for kernels.json.
set -eu
VER=$1; OUT=$2; shift 2
COMPAT='["v2026-10-24-release|eng.kenny.20261024.175043"]'
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
files_json=""
for src in "$@"; do
  name=$(basename "$src")
  cp "$src" "$work/$name"
  sz=$(stat -c %s "$work/$name"); sh=$(sha256sum "$work/$name" | cut -d' ' -f1)
  files_json="$files_json{\"name\":\"$name\",\"size\":$sz,\"sha256\":\"$sh\"},"
done
files_json="[${files_json%,}]"
cat > "$work/manifest.json" <<JSON
{"format":1,"version":"$VER","compatible_builds":$COMPAT,"files":$files_json}
JSON
mkdir -p "$OUT"
zip="$OUT/kernel-$VER.zip"
( cd "$work" && zip -q -X "$zip" manifest.json "$@" 2>/dev/null || zip -q -X "$zip" manifest.json $(for s in "$@"; do basename "$s"; done) )
zsz=$(stat -c %s "$zip"); zsh=$(sha256sum "$zip" | cut -d' ' -f1)
echo "ZIP=$zip"
echo "SIZE=$zsz"
echo "SHA256=$zsh"
echo "manifest: $(cat "$work/manifest.json")"
