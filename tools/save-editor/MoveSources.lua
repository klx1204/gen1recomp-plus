-- Legal provenance for the move picker (Gen 3 only).
--
-- The picker lists the whole catalog.  This module answers "where can this
-- species get that move" so each row can carry Lv / TM / HM / Egg / Tut / Pre
-- tags.  It is informational: Ops.setMove still writes whatever it is given.
--
-- Level tags keep the earliest learn level and ignore the current level, so a
-- Lv16 Charmander still shows Flamethrower as Lv46.  "Pre" means an earlier
-- evolution stage learns the move by level; that is the conservative reading
-- (no pre-evolution TMs, egg moves or tutors).
--
-- Data comes from the mounted Gen 3 cache:
--   Pokemon.learnset / eggMoves / evolutions   (pokemon/*.lua)
--   Pokemon.canLearnTmIndex / moveFromTmItem   (TM01-50, HM01-08)
--   MoveLearn.canLearnTutorMove / tutorMove    (pokemon/tutor.lua)

local Theme = require("Theme")
local PAL = Theme.PAL

local MoveSources = {}

local TM_FIRST_ITEM = 289
local TM_COUNT = 50
local HM_COUNT = 8

local ORDER = { "lv", "tm", "hm", "egg", "tut", "pre" }

local COLORS = {
  lv = PAL.green,
  tm = PAL.blue,
  hm = PAL.railCrystal,
  egg = PAL.yellow,
  tut = PAL.buttonPurple,
  pre = PAL.muted,
}

local function gen3(S)
  local ok, Gen = pcall(require, "Gen")
  return ok and Gen.ofState(S) == 3
end

local function add(map, move, field, level)
  move = tonumber(move)
  if not move or move <= 0 then return end
  local row = map[move]
  if not row then
    row = {}
    map[move] = row
  end
  if field == "lv" then
    local old = row.lv
    if not old or (level and level < old) then
      row.lv = tonumber(level) or 1
    end
  else
    row[field] = true
  end
end

local function addLearnset(map, Pokemon, species, field)
  local ok, learnset = pcall(Pokemon.learnset, species)
  if not ok or type(learnset) ~= "table" then return end
  for _, e in ipairs(learnset) do
    if type(e) == "table" then
      local move = tonumber(e[2] or e.move or e.id)
      local level = tonumber(e[1] or e.level)
      if move then add(map, move, field, level) end
    end
  end
end

-- Reverse evolution table: target species -> the species that evolve into it.
local function preMap(S)
  if S._moveSourcesPre then return S._moveSourcesPre end
  local map = {}
  local ok, Pokemon = pcall(require, "src.core.game3.pokemon")
  if not ok then
    S._moveSourcesPre = map
    return map
  end
  for key, def in pairs(S.data and S.data.pokemon or {}) do
    if type(def) == "table" then
      local from = tonumber(def.speciesId or def.id) or tonumber(key)
      if from then
        local okEvo, evolutions = pcall(Pokemon.evolutions, from)
        if okEvo and type(evolutions) == "table" then
          for _, evo in ipairs(evolutions) do
            local to = type(evo) == "table"
              and tonumber(evo.target or evo.to or evo[3]) or nil
            if to then
              map[to] = map[to] or {}
              map[to][#map[to] + 1] = from
            end
          end
        end
      end
    end
  end
  S._moveSourcesPre = map
  return map
end

-- Every species earlier in the evolution chain, nearest first.
local function ancestors(S, species)
  local pre = preMap(S)
  local out, seen = {}, { [species] = true }
  local queue, head = { species }, 1
  while head <= #queue do
    local cur = queue[head]
    head = head + 1
    for _, parent in ipairs(pre[cur] or {}) do
      if not seen[parent] then
        seen[parent] = true
        out[#out + 1] = parent
        queue[#queue + 1] = parent
      end
    end
  end
  return out
end

local function speciesOf(mon)
  if type(mon) ~= "table" then return nil end
  local ok, Pokemon = pcall(require, "src.core.game3.pokemon")
  if ok then
    local okS, sp = pcall(Pokemon.speciesOf, mon)
    if okS and tonumber(sp) then return tonumber(sp) end
  end
  return tonumber(mon.speciesId or mon.species)
end

--- Provenance map for one species: { [moveId] = { lv = 46, tm = true, ... } }.
--- Returns nil outside Gen 3.
function MoveSources.forSpecies(S, species)
  if not gen3(S) then return nil end
  species = tonumber(species)
  if not species or species <= 0 then return nil end
  S._moveSources = S._moveSources or {}
  local hit = S._moveSources[species]
  if hit ~= nil then return hit end

  local map = {}
  local ok, Pokemon = pcall(require, "src.core.game3.pokemon")
  if not ok then return nil end

  -- Level-up moves of the current form, any level.
  addLearnset(map, Pokemon, species, "lv")

  -- TM01-50 then HM01-08.
  for i = 0, TM_COUNT + HM_COUNT - 1 do
    local okCan, can = pcall(Pokemon.canLearnTmIndex, species, i)
    if okCan and can then
      local okMove, move = pcall(Pokemon.moveFromTmItem, TM_FIRST_ITEM + i)
      if okMove and move then
        add(map, move, i < TM_COUNT and "tm" or "hm")
      end
    end
  end

  -- Egg moves belong to the form that hatches, so walk the chain.
  for _, sp in ipairs(ancestors(S, species)) do
    local okEgg, eggs = pcall(Pokemon.eggMoves, sp)
    if okEgg and type(eggs) == "table" then
      for _, move in ipairs(eggs) do add(map, move, "egg") end
    end
  end
  local okEgg, eggs = pcall(Pokemon.eggMoves, species)
  if okEgg and type(eggs) == "table" then
    for _, move in ipairs(eggs) do add(map, move, "egg") end
  end

  -- Move tutors (Emerald / FRLG tutor table).
  local okL, MoveLearn = pcall(require, "src.core.game3.move_learn")
  if okL and MoveLearn then
    local okCount, count = pcall(MoveLearn.tutorMoveCount)
    count = okCount and tonumber(count) or 0
    for i = 0, count - 1 do
      local okCan, can = pcall(MoveLearn.canLearnTutorMove, species, i)
      if okCan and can then
        local okMove, move = pcall(MoveLearn.tutorMove, i)
        if okMove and move then add(map, move, "tut") end
      end
    end
  end

  -- Level-up moves kept from an earlier form.
  for _, sp in ipairs(ancestors(S, species)) do
    addLearnset(map, Pokemon, sp, "pre")
  end

  S._moveSources[species] = map
  return map
end

--- Convenience wrapper for a save-editor monster table.
function MoveSources.forMon(S, mon)
  local species = speciesOf(mon)
  if not species then return nil end
  return MoveSources.forSpecies(S, species)
end

--- Tag list for one provenance row, in display order.
function MoveSources.marks(row)
  if type(row) ~= "table" then return {} end
  local out = {}
  for _, field in ipairs(ORDER) do
    if row[field] then
      local text
      if field == "lv" then
        text = ("Lv%d"):format(tonumber(row.lv) or 1)
      elseif field == "egg" then
        text = "Egg"
      elseif field == "tut" then
        text = "Tut"
      elseif field == "pre" then
        text = "Pre"
      elseif field == "tm" then
        text = "TM"
      else
        text = "HM"
      end
      out[#out + 1] = { text = text, color = COLORS[field] }
    end
  end
  return out
end

--- Drop the per-save caches (called when the editor reloads a slot).
function MoveSources.reset(S)
  if type(S) == "table" then
    S._moveSources = nil
    S._moveSourcesPre = nil
  end
end

return MoveSources
