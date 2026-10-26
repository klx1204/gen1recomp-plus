# gen1recomp-ps-split

[English](README.md)

[gen1recomp](https://github.com/bryanthaboi/gen1recomp) 的 fork，
为 Gen 3 战斗引擎加入按招式的物理/特殊分家。

## 下载

[最新 Release](https://github.com/klx1204/gen1recomp-ps-split/releases)

`.love` 需要 LÖVE 11.x，ROM 由玩家自己提供。

## 运行

```sh
love gen1recomp-ps-split-<tag>.love
```

从源码运行：

```sh
love .
```

在启动器里导入 Gen 3 ROM。

## 配套数据 mod

[types-mod-gen1recomp](https://github.com/klx1204/types-mod-gen1recomp)
加入 Fairy、Gen 9 相克表、18 只物种、18 个招式和按招式分类。

## 这个 fork 改了什么

- `PhySpc.physical(move)` 和 `Types.MOVE_CATEGORY`
- 伤害、Hustle、Counter/Mirror Coat、替身都按招式分类
- 战斗菜单招式名按效果染色
- `TYPE` 按物理/特殊/变化染色
- 摘要页招式名按物理/特殊/变化染色
- 给 mod 提供自定义类型名称和图标（Fairy）
- 双打目标选择时实时更新染色

## 颜色说明

### 战斗招式菜单

招式名颜色表示对当前目标的相性：

| 颜色 | 含义 |
| --- | --- |
| 绿色 | 效果拔群 |
| 默认色 | 正常 |
| 黄色 | 效果不佳 |
| 灰色 | 没有效果 |

`TYPE` 的颜色表示伤害分类：

| 颜色 | 含义 |
| --- | --- |
| 红色 | 物理 |
| 蓝色 | 特殊 |
| 灰色 | 变化 |

双打时移动目标光标，两种颜色都会实时更新。

### 摘要页

招式名颜色表示伤害分类：

| 颜色 | 含义 |
| --- | --- |
| 暗红 | 物理 |
| 蓝色 | 特殊 |
| 灰色 | 变化 |

华丽大赛页面保持原版分类图标。

## 上游

- upstream: https://github.com/bryanthaboi/gen1recomp
- 分支：`ps-split`
- 每日 `upstream-sync` 合并 `upstream/dev`

维护规则见 `FORK.md` 和 `AGENTS.md`。
