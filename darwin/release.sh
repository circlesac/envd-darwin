#!/bin/sh
set -eu
ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
[ "$(git branch --show-current)" = main ] || { echo 'Release must run from main' >&2; exit 1; }
[ -z "$(git status --porcelain)" ] || { echo 'Release requires a clean checkout' >&2; exit 1; }
git fetch origin main --tags
[ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ] || { echo 'Release requires current origin/main' >&2; exit 1; }
"$ROOT/darwin/test.sh"
mkdir -p darwin/dist/version
printf '{"name":"@circlesac/envd-darwin"}\n' > darwin/dist/version/package.json
version_output=$(npx --yes @circlesac/oneup version --source git --target darwin/dist/version/package.json)
VERSION=$(printf '%s\n' "$version_output" | tail -1)
printf '%s\n' "$VERSION" | grep -Eq '^[0-9]{2}\.[0-9]{1,2}\.[0-9]+$' || { echo 'Invalid release version' >&2; exit 1; }
for arch in arm64 amd64; do
    mkdir -p "darwin/dist/$arch"
    cp "darwin/dist/envd-darwin-$arch" "darwin/dist/$arch/envd"
    cp LICENSE "darwin/dist/$arch/LICENSE"
    tar -czf "darwin/dist/envd-darwin-$arch.tar.gz" -C "darwin/dist/$arch" envd LICENSE
    (cd darwin/dist && shasum -a 256 "envd-darwin-$arch.tar.gz" > "envd-darwin-$arch.tar.gz.sha256")
done
gh release create "v$VERSION" darwin/dist/*.tar.gz darwin/dist/*.tar.gz.sha256 \
    --repo circlesac/envd-darwin --target "$(git rev-parse HEAD)" \
    --title "envd-darwin v$VERSION" --generate-notes
