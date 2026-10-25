-- Pure labels for the battle move menu. Drawing is wired in a later pass;
-- keeping the text here makes it testable without LÖVE.

local PhySpc = require("src.core.game3.battle.phy_spc")

local Menu = {}

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

return Menu
