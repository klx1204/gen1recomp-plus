-- Contract tests for phy_spc.lua. No engine checkout, ROM or LÖVE needed.
local Types = {
  isPhysical = function(typeId)
    return typeId == 0 or typeId == 1 or typeId == 2
  end,
  effectiveness = function(atk, def1, def2)
    if atk == 18 and def1 == 16 then return 2 end   -- Fairy vs Dragon
    if atk == 7 and def1 == 0 then return 0 end     -- Ghost vs Normal
    if atk == 10 and def1 == 11 then return 0.5 end -- Fire vs Water
    return 1
  end,
}
package.loaded["src.core.game3.battle.types"] = nil
package.preload["src.core.game3.battle.types"] = function() return Types end

local PhySpc = assert(loadfile("src/core/game3/battle/phy_spc.lua"))()

assert(PhySpc.physical({ category = "physical", power = 90, type = 18 }) == true,
  "explicit physical category")
assert(PhySpc.physical({ category = "special", power = 95, type = 18 }) == false,
  "explicit special category")
assert(PhySpc.physical({ category = "status", power = 0, type = 18 }) == false,
  "status is not physical")
assert(PhySpc.physical({ power = 0, type = 0 }) == false,
  "power 0 without category is not physical")
assert(PhySpc.physical({ power = 40, type = 0 }) == true,
  "fallback to physical type")
assert(PhySpc.physical({ power = 40, type = 10 }) == false,
  "fallback to special type")
assert(PhySpc.physical(0) == true, "raw type fallback")

assert(PhySpc.label({ category = "physical", power = 90 }) == "PHY")
assert(PhySpc.label({ category = "special", power = 95 }) == "SPE")
assert(PhySpc.label({ category = "status", power = 0 }) == "STA")
assert(PhySpc.label({ power = 0 }) == "STA")

local mult, flags = PhySpc.effectiveness({ type = 18 }, { type1 = 16 })
assert(mult == 2 and flags.super and not flags.immune, "Fairy vs Dragon")

mult, flags = PhySpc.effectiveness({ type = 7 }, { type1 = 0 })
assert(mult == 0 and flags.immune, "Ghost vs Normal")

mult, flags = PhySpc.effectiveness({ type = 10 }, { type1 = 11 })
assert(mult == 0.5 and flags.resist, "Fire vs Water")

local Menu = assert(loadfile("src/core/game3/battle/phy_spc_menu.lua"))()
assert(Menu.categoryLabel({ category = "physical", power = 90 }) == "PHY")
assert(Menu.effectivenessLabel(0) == "x0")
assert(Menu.effectivenessLabel(0.25) == "x.25")
assert(Menu.effectivenessLabel(0.5) == "x.5")
assert(Menu.effectivenessLabel(1) == nil, "neutral keeps the menu default and shows no label")
assert(Menu.effectivenessLabel(2) == "x2")
assert(Menu.effectivenessLabel(4) == "x4")
assert(Menu.effectivenessLabel(nil) == nil)
assert(Menu.colorFor(1) == nil, "neutral has no tint")
assert(Menu.colorFor(0) == Menu.COLORS.immune)
assert(Menu.colorFor(0.5) == Menu.COLORS.resist)
assert(Menu.colorFor(2) == Menu.COLORS.super)
assert(Menu.categoryColor("PHY") == Menu.CATEGORY_COLORS.physical)
assert(Menu.categoryColor("SPE") == Menu.CATEGORY_COLORS.special)
assert(Menu.categoryColor("STA") == Menu.CATEGORY_COLORS.status)

local calls = {}
Menu.draw(function(text, x, y, color)
  calls[#calls + 1] = { text = text, x = x, y = y, color = color }
end, { category = "physical", power = 90, type = 18 }, { type1 = 16 }, 10, 20)
assert(#calls == 2, "draw must emit category and effectiveness")
assert(calls[1].text == "PHY" and calls[1].x == 10 and calls[1].y == 20)
assert(calls[2].text == "x2" and calls[2].x == 34 and calls[2].y == 20)
assert(calls[2].color == Menu.COLORS.super)

calls = {}
Menu.draw(function(text, x, y, color)
  calls[#calls + 1] = { text = text, x = x, y = y, color = color }
end, { category = "special", power = 80, type = 11 }, { type1 = 11 }, 10, 20)
assert(#calls == 1, "1x emits no effectiveness label")
assert(calls[1].text == "SPE")

print("phy_spc_test: ok")
