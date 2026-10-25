-- Per-move physical/special support for the Gen 3 engine.
--
-- This module intentionally does not touch any engine file. Call sites use it
-- as the single source of truth for a move's damage class.
--
-- Contract (also in docs/phy-spc.md):
--   1. move.category == "physical" -> true
--   2. move.category == "special"  -> false
--   3. move.category == "status"   -> false
--   4. power == 0                  -> false
--   5. otherwise fall back to Types.isPhysical(move.type)

local PhySpc = {}

local function Types()
  return require("src.core.game3.battle.types")
end

function PhySpc.physical(move)
  if type(move) ~= "table" then
    return Types().isPhysical(move)
  end
  if move.category == "physical" then return true end
  if move.category == "special" or move.category == "status" then return false end
  if (tonumber(move.power) or 0) == 0 then return false end
  return Types().isPhysical(move.type)
end

function PhySpc.label(move)
  if type(move) == "table" then
    if move.category == "status" or (tonumber(move.power) or 0) == 0 then
      return "STA"
    end
  end
  return PhySpc.physical(move) and "PHY" or "SPE"
end

--- Effectiveness of `move` against `target`.
-- Returns the multiplier (0, 0.25, 0.5, 1, 2, 4) and a flags table.
function PhySpc.effectiveness(move, target)
  local typeId = type(move) == "table" and move.type or move
  local type1 = target and (target.type1 or target.type or target[1]) or 0
  local type2 = target and (target.type2 or target[2])
  if type2 == nil then type2 = type1 end

  local mult = Types().effectiveness(typeId, type1, type2)
  local flags = {
    multiplier = mult,
    immune = mult == 0,
    resist = mult > 0 and mult < 1,
    neutral = mult == 1,
    super = mult > 1,
  }
  return mult, flags
end

return PhySpc
