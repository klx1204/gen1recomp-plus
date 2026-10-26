-- Pure labels for the battle move menu. Drawing is wired in a later pass;
-- keeping the text here makes it testable without LÖVE.

local PhySpc = require("src.core.game3.battle.phy_spc")

local Menu = {}

-- Effectiveness tints.  `neutral` is absent on purpose: the battle menus
-- keep their own default text colour for a 1x matchup.
Menu.COLORS = {
  immune = { 0.68, 0.68, 0.68 },
  resist = { 0.78, 0.62, 0.05 },
  super = { 0.10, 0.58, 0.16 },
}

-- Physical/special bar drawn beside the effectiveness label.
Menu.CATEGORY_COLORS = {
  physical = { 0.85, 0.20, 0.20 },
  special = { 0.20, 0.35, 0.85 },
  status = { 0.50, 0.50, 0.50 },
}

function Menu.categoryLabel(move)
  return PhySpc.label(move)
end

function Menu.effectivenessLabel(mult)
  mult = tonumber(mult)
  if mult == nil or mult == 1 then return nil end
  if mult == 0 then return "x0" end
  if mult == 0.25 then return "x.25" end
  if mult == 0.5 then return "x.5" end
  if mult == 2 then return "x2" end
  if mult == 4 then return "x4" end
  return string.format("x%.2f", mult)
end

function Menu.info(move, target)
  local mult = PhySpc.effectiveness(move, target)
  return PhySpc.label(move), Menu.effectivenessLabel(mult), mult
end

function Menu.colorFor(mult)
  mult = tonumber(mult) or 1
  if mult == 0 then return Menu.COLORS.immune end
  if mult < 1 then return Menu.COLORS.resist end
  if mult > 1 then return Menu.COLORS.super end
  return nil
end

local CATEGORY_ALIAS = { PHY = "physical", SPE = "special", STA = "status" }

function Menu.categoryColor(category)
  return Menu.CATEGORY_COLORS[CATEGORY_ALIAS[category] or category]
end

--- Draw the category and effectiveness labels through a caller-supplied
-- text callback: draw(text, x, y, color). The battle UI owns the font and
-- canvas; this module owns only the values and relative layout.
-- Category is at (x, y), effectiveness at (x + gap, y).
function Menu.draw(draw, move, target, x, y, opts)
  opts = opts or {}
  local category, effectiveness, mult = Menu.info(move, target)
  local gap = tonumber(opts.gap) or 24
  draw(category, x, y, opts.categoryColor or opts.neutralColor)
  if effectiveness then
    draw(effectiveness, x + gap, y, Menu.colorFor(mult))
  end
  return category, effectiveness, mult
end

return Menu
