# gen1recomp-ps-split

[中文](README.zh-CN.md)

A fork of [gen1recomp](https://github.com/bryanthaboi/gen1recomp) that adds
per-move physical/special to the Gen 3 battle engine.

## Download

[Latest release](https://github.com/klx1204/gen1recomp-ps-split/releases)

The `.love` needs LÖVE 11.x and a Gen 3 ROM you provide yourself.

## Run

```sh
love gen1recomp-ps-split-<tag>.love
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

## Upstream

- upstream: https://github.com/bryanthaboi/gen1recomp
- branch: `ps-split`
- daily `upstream-sync` merges `upstream/dev`

See `FORK.md` and `AGENTS.md` for the maintenance rules.
