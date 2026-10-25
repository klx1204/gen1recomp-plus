# Fork note

This checkout is **`gen1recomp-ps-split`**, a minimal fork of
[gen1recomp](https://github.com/bryanthaboi/gen1recomp).

It exists for one feature:

- per-move physical/special categories for the Gen 3 engine;
- a later battle-menu line showing `PHY` / `SPE` / `STA` and type effectiveness.

Everything Gen 9-related lives in the companion mod:
https://github.com/klx1204/types-mod-gen1recomp

## Read first

1. `AGENTS.md` — hard rules, allowed files, upstream sync.
2. `docs/phy-spc.md` — the `PhySpc` contract and the exact call sites.
3. `tests/phy_spc_test.lua` — no ROM required.

## Branches

- `origin` = https://github.com/klx1204/gen1recomp-ps-split
- `upstream` = https://github.com/bryanthaboi/gen1recomp
- maintenance branch: `ps-split`

Never push to `upstream`.

## Tests

```bash
luajit tests/phy_spc_test.lua
luajit tests/phy_spc_guard.lua
```

`tests/run_tests.lua` needs a generated cache and is not the default fork test.

## Local paths

Do not commit a local absolute path. Use relative paths or explicit CLI
arguments. Tests must not require a local ROM.
