# Darwin envd

This repository is the `circlesac/envd-darwin` fork of [e2b-dev/runtime](https://github.com/e2b-dev/runtime). Circles maintains and releases only the macOS envd agent. The remaining upstream tree and history are retained to make upstream merges reviewable. Only `test.yml` and `release.yml` are retained; upstream infrastructure workflows are removed.

## Build and verify

Install the Go version in `packages/envd/go.mod`, then run:

```sh
./darwin/test.sh
GOARCH=arm64 ./darwin/build.sh
GOARCH=amd64 ./darwin/build.sh
```

The test script runs native race tests and vet on macOS and compile checks on Linux, then builds both Darwin architectures. `GOWORK=off` bounds dependencies to envd and its shared module. The format check uses gofmt; lint uses go vet and upstream golangci-lint v2.15.0 (rebuilt with this repository’s Go toolchain). `test.yml` runs the Darwin checks on pull requests and main pushes. Lint compares against the PR base or the previous main head.

## Release and consume

Dispatch `.github/workflows/release.yml` from `main`, or run `./darwin/release.sh` from a clean, current `main` with Go, Node and authenticated `gh`. It runs the same checks, computes CalVer using `@circlesac/oneup`, and publishes two archives plus matching `.tar.gz.sha256` files to this repository's GitHub Releases. Release scripts create tags only after successful builds. Each archive contains `envd` and the Apache-2.0 license.

The release CalVer is independent of the upstream envd protocol version in `packages/envd/pkg/version.go`; do not overwrite that protocol version with CalVer. `circlesac/sandbox` owns the Tart installer and pins a release tag. A release becomes the supported sandbox dependency only after its Tart E2B suite passes.

## Tart guest setup

Keep upstream's `/run/e2b` paths. In the dedicated Tart base guest, create a synthetic `/run` link to `/private/tmp` once, then reboot the guest:

```sh
sudo mkdir -p /etc/synthetic.d
printf 'run\tprivate/tmp\n' | sudo tee /etc/synthetic.d/envd
sudo reboot
```

Before adding the entry, check `/etc/synthetic.conf` and `/etc/synthetic.d/` for an existing `run` definition; reuse a compatible writable path instead of adding a duplicate. After reboot, verify `readlink /run` returns `private/tmp` and, as the envd login user, run `mkdir -p /run/e2b && test -w /run/e2b`. This is guest setup only; do not modify the host. `/run/e2b` then resolves to `/private/tmp/e2b` without platform-specific Go paths. The sandbox installer checks this prerequisite before replacing the daemon.

## Upstream maintenance

The initial Darwin patch was extracted from sandbox's vendored baseline `f2233c5e3f39e6b2be9d158138df898ea561ecf` and applied to upstream `c7bbb196b` without replacing newer upstream dependencies or tests.

```sh
git remote add upstream https://github.com/e2b-dev/runtime.git # once, if absent
git fetch upstream
git switch -c sync/upstream-main origin/main
git merge upstream/main
./darwin/test.sh
```

Review the upstream delta and resolve platform conflicts in a PR; do not replace the fork with an exported subtree. Keep only the fork’s `test.yml` and `release.yml` when resolving upstream workflow changes. After CI, release and run the consuming sandbox Tart suite before updating its pin. The small maintained platform delta is:

- Re-exec via `os.Executable()` on macOS, `/proc/self/exe` on Linux.
- Direct Darwin process spawning without the Linux `/proc` priority wrapper; inherit credentials for the current login user.

macOS guests use a login LaunchAgent with the same envd port (49983) and protocol. No control-plane or Linux infrastructure is deployed by this fork.
