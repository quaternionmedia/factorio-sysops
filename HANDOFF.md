# Local POC Handoff

## Status

- Branch: `demo/qm-factorio-verification-poc`
- Base: `da1e1d0c50fd30b082b4031b3ff835947b2246e0`
- Delivery state: local only; no commit, push, installed-mod change,
  game/server launch, or save change.
- Static acceptance: ready after `verify_mod.py` and its unit tests pass.
- Semantic and performance acceptance: **Pending** a human-owned Factorio
  2.0.77 run.
- Existing installed-copy comparison: **Not an acceptance artifact.** On this
  local machine the read-only byte manifest differs only in
  `scripts/indicators.lua` line endings (source LF, installed CRLF). It was
  not overwritten. A newly staged copy is the required input for a joined run.

## What is here

- `sysadmin-poc/scripts/verify_mod.py` reads `info.json`, resolves the current
  Lua asset-reference forms, and optionally compares a copied installed-mod
  tree by SHA-256 without writing it.
- `tests/test_verify_mod.py` provides a real-mod positive control and negative
  controls for missing metadata, direct assets, prefix-concatenated assets, and
  installed-copy drift.
- [docs/LOCAL-POC.md](docs/LOCAL-POC.md) contains the executable static gate,
  copy-only staging commands, and manual benchmark boundary.

## Next owner

Run the static commands, then follow the manual benchmark exactly as bounded in
[docs/LOCAL-POC.md](docs/LOCAL-POC.md). Preserve the existing graphics tree;
the verifier only reads it. Keep Factorio-server's whitelist and the optional
DataFactorio `script-output/datafactorio/` file seam with their owning projects.
