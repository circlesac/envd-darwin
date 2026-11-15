#!/bin/sh
set -eu
ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
ARCH=${GOARCH:-arm64}
OUTPUT=${OUTPUT:-"$ROOT/darwin/dist/envd-darwin-$ARCH"}
mkdir -p "$(dirname -- "$OUTPUT")"
cd "$ROOT/packages/envd"
GOWORK=off CGO_ENABLED=0 GOOS=darwin GOARCH="$ARCH" go build -trimpath -buildvcs=false -ldflags "-s -w" -o "$OUTPUT" .
