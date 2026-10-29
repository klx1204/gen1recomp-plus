# gen1recomp-plus

[English](README.md)

[gen1recomp](https://github.com/bryanthaboi/gen1recomp) 的 fork，面向 Gen 3
五作：按招式的物理/特殊分家、带 Fairy 的 Gen 9 相克表、中文宝可梦名和招式名、
摘要页的个体值/努力值，以及 mod 自绘事件对象所需的接口。

## 下载

[最新 Release](https://github.com/klx1204/gen1recomp-plus/releases)

`.love` 需要 LÖVE 11.x，ROM 由玩家自己提供。

## 运行

```sh
love gen1recomp-plus-<tag>.love
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
- 摘要页能力页：按 A 在 能力值 / 个体值 / 努力值 之间切换
- 事件对象可以自带绘制函数（`eo.draw`），明雷 mod 用它画图标
- 带自绘函数的对象始终参与绘制，不受玩家是否移动影响

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

### 个体值和努力值

在能力页按 `A`，数字会在 能力值 → 个体值（0–31）→ 努力值（0–255）之间循环，
顶部标题会显示当前是 `IVs` 还是 `EVs`。换宝可梦或重新打开摘要页会回到能力值。

## 上游

- upstream: https://github.com/bryanthaboi/gen1recomp
- 分支：`plus`
- 每日 `upstream-sync` 合并 `upstream/dev`
- 版本基线：上游 tag `v0.3.97`，代码在 `upstream/dev` @ `2aec7650`

维护规则见 `FORK.md` 和 `AGENTS.md`。
