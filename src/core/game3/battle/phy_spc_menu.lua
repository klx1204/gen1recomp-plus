-- Pure labels for the battle move menu. Drawing is wired in a later pass;
-- keeping the text here makes it testable without LÖVE.

local PhySpc = require("src.core.game3.battle.phy_spc")

local Menu = {}

Menu.COLORS = {
  immune = { 0.60, 0.60, 0.60 },
  resist = { 0.85, 0.35, 0.35 },
  neutral = { 1.00, 1.00, 1.00 },
  super = { 0.35, 0.85, 0.45 },
}

function Menu.categoryLabel(move)
  return PhySpc.label(move)
end

function Menu.effectivenessLabel(mult)
  mult = tonumber(mult)
  if mult == nil then return "x1" end
  if mult == 0 then return "x0" end
  if mult == 0.25 then return "x1/4" end
  if mult == 0.5 then return "x1/2" end
  if mult == 1 then return "x1" end
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
  return Menu.COLORS.neutral
end

--- Draw the category and effectiveness labels through a caller-supplied
-- text callback: draw(text, x, y, color). The battle UI owns the font and
-- canvas; this module owns only the values and relative layout.
-- Category is at (x, y), effectiveness at (x + gap, y).
function Menu.draw(draw, move, target, x, y, opts)
  opts = opts or {}
  local category, effectiveness, mult = Menu.info(move, target)
  local gap = tonumber(opts.gap) or 24
  draw(category, x, y, opts.categoryColor or Menu.COLORS.neutral)
  draw(effectiveness, x + gap, y, Menu.colorFor(mult))
  return category, effectiveness, mult
end

return Menu
