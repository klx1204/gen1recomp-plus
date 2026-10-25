# AGENTS.md — gen1recomp-ps-split

## What this repo is

A minimal fork of [gen1recomp](https://github.com/bryanthaboi/gen1recomp) that
adds one capability:

- **per-move physical/special categories** for the Gen 3 engine;
- a battle move menu line showing `PHY` / `SPE` / `STA` and type effectiveness.

Everything else belongs in the companion mod repo:
https://github.com/klx1204/types-mod-gen1recomp

## Hard rules

1. Keep the fork small. The target is **two new files plus a handful of
   one-line call-site changes**, not a rewrite.
2. Never change the mod data schema to carry `category`:
   - do not edit `src/mods/UnifiedContent.lua`;
   - do not edit `src/mods/Schemas.lua`.
   The mod writes `move.category` into the runtime `Moves._rom` rows instead.
3. Do not touch:
   - `GameVersion`
   - `CacheContract` / `CACHE_VERSION`
   - the ROM importer
   - the save schema
   - the link protocol
4. Never commit a local absolute path (a home-directory path or a Windows
   drive path). Tests must not require a local ROM.
5. Do not add Gen 9 data, Fairy moves, species patches, options, or mod files
   here. Those belong to `types-mod-gen1recomp`.

## Allowed files

New files:

- `src/core/game3/battle/phy_spc.lua`
- `src/core/game3/battle/phy_spc_menu.lua`
- `tests/phy_spc_test.lua`
- `tests/phy_spc_guard.lua`
- `.github/workflows/upstream-sync.yml`
- `.github/workflows/phy-spc-release.yml`
- `docs/phy-spc.md`

Call-site wiring only (one line each unless noted):

- `src/core/game3/battle/moves.lua` — preserve `row.category`
- `src/core/game3/battle/damage.lua` — 4 physical checks
- `src/core/game3/battle/engine.lua` — 2 physical checks
- `src/core/game3/battle/effects/hit.lua` — 2 physical checks
- `src/core/game3/battle/ui.lua` — 3 menu draw calls
- type-icon frame fallback (optional, one line)

If a change does not fit this list, stop and discuss it first.

## Public interface for the mod

```lua
-- src/core/game3/battle/types.lua
Types.MOVE_CATEGORY = true

-- src/core/game3/battle/phy_spc.lua
PhySpc.physical(move)        -- true / false
PhySpc.label(move)           -- "PHY" / "SPE" / "STA"
PhySpc.effectiveness(move, target)
```

`Types.isPhysical(typeId)` stays for vanilla callers. New code uses
`PhySpc.physical(move)`.

## Upstream sync

- `origin` = https://github.com/klx1204/gen1recomp-ps-split
- `upstream` = https://github.com/bryanthaboi/gen1recomp
- maintenance branch: `ps-split`
- upstream branch: `upstream/dev`

Rules:

1. Never push to `upstream`.
2. `git config rerere.enabled true` and `git config rerere.autoupdate true`.
3. Prefer `git merge upstream/dev` over rebase, so `rerere` can reuse
   conflict resolutions.
4. The daily `upstream-sync` workflow:
   - fetches `upstream/dev`;
   - merges it into `ps-split`;
   - runs the test suite;
   - pushes only when the merge and tests pass;
   - opens an issue on conflict.
5. If a merge cannot be automated, resolve it by hand and keep the patch
   surface small. A `patches/` snapshot may be regenerated with
   `git format-patch upstream/dev..ps-split -o patches/`.
6. Tag releases as `ps-split-<upstream-short-sha>` and record the upstream
   commit in the release notes.

## Tests

```bash
luajit tests/run_tests.lua
luajit tests/phy_spc_test.lua
```

`tests/phy_spc_guard.lua` must fail with a clear message if upstream removes
or renames:

- `Types.isPhysical`
- `Moves.get`
- the battle move menu entry points
- the four call sites in `damage.lua`, `engine.lua` and `hit.lua`

## Compatibility

| Engine | Per-move category | Menu label/effectiveness |
| --- | --- | --- |
| This fork | yes | yes |
| Official gen1recomp | no | no |

The mod detects `Types.MOVE_CATEGORY` and degrades cleanly on the official
engine.

## Release checklist

- [ ] `luajit tests/run_tests.lua` passes.
- [ ] `luajit tests/phy_spc_test.lua` passes.
- [ ] No local absolute paths.
- [ ] `git diff upstream/dev..ps-split --stat` is still small.
- [ ] The mod repo's compatibility matrix matches this release.
