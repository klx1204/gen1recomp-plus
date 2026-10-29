# gen1recomp-plus

[中文](README.zh-CN.md)

A fork of [gen1recomp](https://github.com/bryanthaboi/gen1recomp) for the Gen 3
games: per-move physical/special, a Gen 9 type chart with Fairy, Chinese
species and move names, IV/EV on the summary screen, and hooks a mod needs to
draw its own event objects.

## Download

[Latest release](https://github.com/klx1204/gen1recomp-plus/releases)

The `.love` needs LÖVE 11.x and a Gen 3 ROM you provide yourself.

## Run

```sh
love gen1recomp-plus-<tag>.love
```

From source:

```sh
love .
```

Import a Gen 3 ROM from the launcher.

## Companion mod

[types-mod-gen1recomp](https://github.com/klx1204/types-mod-gen1recomp)
adds Fairy, the Gen 9 chart, 18 species, 18 moves and per-move categories.

## What this fork adds

- `PhySpc.physical(move)` and `Types.MOVE_CATEGORY`
- damage, Hustle, Counter/Mirror Coat and Substitute use the move category
- battle move names tinted by matchup
- `TYPE` tinted by damage class
- summary move names tinted by damage class
- custom type names and icons for mods (Fairy)
- doubles target selection updates the tint live
- summary SKILLS page: A cycles STATS / IVs / EVs
- event objects may carry their own painter (`eo.draw`), used by the visible wild mod
- such an object is always in the draw list, even before the player moves

## Colour legend

### Battle move menu

Move names show the matchup against the current target:

| Colour | Meaning |
| --- | --- |
| Green | Super effective |
| Default | Neutral |
| Yellow | Resisted |
| Grey | No effect |

`TYPE` shows the damage class:

| Colour | Meaning |
| --- | --- |
| Red | Physical |
| Blue | Special |
| Grey | Status |

In doubles, moving the target cursor updates both tints live.

### Summary screen

Move names use the damage-class colours:

| Colour | Meaning |
| --- | --- |
| Dark red | Physical |
| Blue | Special |
| Grey | Status |

Contest pages keep the native contest categories.

### IVs and EVs

On the SKILLS page, `A` cycles the numbers between the battle stats, the IVs
(0–31) and the EVs (0–255). The label in the top bar names the current mode.
Changing Pokémon or reopening the summary goes back to the battle stats.

## Upstream

- upstream: https://github.com/bryanthaboi/gen1recomp
- branch: `plus`
- daily `upstream-sync` merges `upstream/dev`
- release baseline: upstream tag `v0.3.97`, code at `upstream/dev` @ `2aec7650`

See `FORK.md` and `AGENTS.md` for the maintenance rules.
