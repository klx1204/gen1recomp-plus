# Per-move physical/special (phy-spc)

## Why this fork exists

FireRed/LeafGreen/Emerald decide physical vs special from the **move type**
(Gen 3 rule). Gen 4+ decides it from the **move's own category**. The companion
mod needs the second rule for Fairy moves such as Play Rough (physical) and
Moonblast (special).

This fork adds that rule without changing the mod data schema, the cache
format, the save format or the link protocol.

## Current state

Implemented and tested:

- `src/core/game3/battle/phy_spc.lua`
- `src/core/game3/battle/phy_spc_menu.lua`
- `tests/phy_spc_test.lua`
- `tests/phy_spc_guard.lua`

Not wired yet:

- the eight damage/engine/hit call sites still call `Types.isPhysical`;
- the battle move menu does not draw the new labels yet;
- `Types.MOVE_CATEGORY` is not set yet, so the mod stays in compat mode.

First task when continuing: wire the call sites, then set
`Types.MOVE_CATEGORY = true` in `src/core/game3/battle/types.lua`, then update
`tests/phy_spc_guard.lua` to assert the wiring instead of the old calls.

## Contract

```lua
PhySpc.physical(move)
-- 1. move.category == "physical" -> true
-- 2. move.category == "special"  -> false
-- 3. move.category == "status"   -> false
-- 4. move.power == 0             -> false
-- 5. fallback: Types.isPhysical(move.type)

PhySpc.label(move)
-- status or power 0 -> "STA"
-- physical          -> "PHY"
-- otherwise         -> "SPE"

PhySpc.effectiveness(move, target)
-- returns multiplier in 0 / 0.25 / 0.5 / 1 / 2 / 4
-- returns flags = { multiplier, immune, resist, neutral, super }
```

`Types.isPhysical(typeId)` stays unchanged for vanilla callers.

## Call sites to wire

| File | Function / area | Count |
| --- | --- | --- |
| `src/core/game3/battle/moves.lua` | `from_rom` category | 1 |
| `src/core/game3/battle/damage.lua` | type-boost item, physical/special split, Counter/Mirror Coat, main damage | 4 |
| `src/core/game3/battle/engine.lua` | Hustle accuracy, OHKO damage event | 2 |
| `src/core/game3/battle/effects/hit.lua` | substitute and faint physical flags | 2 |
| `src/core/game3/battle/ui.lua` | RS / RSE / FRLG move menus | 3 |

The guard test checks that these seams still exist before wiring.

## Menu display

`phy_spc_menu.lua` provides pure labels:

```lua
local Menu = require("src.core.game3.battle.phy_spc_menu")
local category, effectiveness, mult = Menu.info(move, target)
-- category: "PHY" / "SPE" / "STA"
-- effectiveness: "x0" / "x1/4" / "x1/2" / "x1" / "x2" / "x4"
```

Drawing is a later pass. Use the existing move-menu text origin and draw:

- category next to the move name or in the existing type row;
- effectiveness with a colour ramp (grey x0, red x1/4/x1/2, white x1, green x2/x4).

Do not add ability immunities (Levitate, Flash Fire, Water Absorb, Volt Absorb,
Wonder Guard, Soundproof) in the first pass. Type-only effectiveness is the
documented MVP.

## Type icon fallback

The ROM summary icon sheet has 18 frames. Fairy is type id 18, so the frame is
out of range. In the type-icon draw helper:

```lua
if frame >= count then
  -- draw Types.name(typeId) as text instead of a missing frame
end
```

Do not crash, and do not silently draw the last frame.

## Tests

```bash
luajit tests/phy_spc_test.lua
luajit tests/phy_spc_guard.lua
```

`tests/run_tests.lua` is the engine suite. It needs a generated cache
(`tools/reimport.sh` or a ROM import) and is not the default fork test.

## Upstream sync

- `origin`: https://github.com/klx1204/gen1recomp-ps-split
- `upstream`: https://github.com/bryanthaboi/gen1recomp
- branch: `ps-split`
- enable `rerere`; merge `upstream/dev` daily via `upstream-sync.yml`.

If the merge conflicts on the seams above, prefer adapting
`phy_spc.lua`/`phy_spc_menu.lua` over editing more engine files.

## Non-goals

- No mod data schema changes (`UnifiedContent` / `Schemas` stay untouched).
- No cache or save schema changes.
- No link protocol changes.
- No new abilities, TMs, or UI screens in this repo.
