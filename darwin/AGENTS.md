# Darwin fork maintenance

Read `README.md` in this directory for builds, releases and Tart guest setup. These instructions govern the fork-specific work; retain upstream instructions for upstream components.

- Maintain only macOS envd. Retain upstream source/history and import paths; do not deploy other upstream services.
- Keep fork documentation here. Do not change the upstream root README, CLAUDE.md or architecture documentation merely to describe the fork.
- Keep upstream `/run/e2b` paths. Configure `/run` in the Tart guest via `synthetic.d`; do not add Darwin-specific temporary paths to Go code or change the host.
- Keep only `.github/workflows/test.yml` and `release.yml` when syncing upstream. Release only Darwin arm64/amd64 archives and SHA-256 files.
- Run `./darwin/test.sh` and the changed-code lint before pushing. A consumer pin is supported only after the released archive passes sandbox's Tart E2B suite.
- Release CalVer and the upstream envd protocol version are separate; do not hand-bump either for this fork.
