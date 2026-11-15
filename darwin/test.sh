#!/bin/sh
set -eu
ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT/packages/envd"
export GOWORK=off
if [ -n "$(gofmt -l internal pkg main.go)" ]; then
    echo "Run gofmt on envd source" >&2
    exit 1
fi
if [ "$(uname -s)" = Darwin ]; then
    go vet ./...
    go test -race ./...
else
    CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go vet ./...
    CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go test -exec /bin/true -run '^$' ./...
fi
for arch in arm64 amd64; do
    GOARCH=$arch "$ROOT/darwin/build.sh"
done
