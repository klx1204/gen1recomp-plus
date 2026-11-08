-- MoveSources: legal provenance tags behind the Gen 3 move picker.
-- Runs with plain luajit; the Gen 3 data functions are stubbed so no ROM
-- cache is required.

package.path = "./?.lua;./?/init.lua;" .. package.path
  .. ";./tools/save-editor/?.lua;./tools/save-editor/panels/?.lua"

love = require("tests.love_stub")

local Pokemon = require("src.core.game3.pokemon")
local MoveLearn = require("src.core.game3.move_learn")
local MoveSources = require("MoveSources")

local passed, failed = 0, 0
local function check(cond, msg)
  if cond then
    passed = passed + 1
  else
    failed = failed + 1
    print("FAIL: " .. tostring(msg))
  end
end
local function eq(actual, expected, msg)
  check(actual == expected, ("%s (got %s, want %s)"):format(
    tostring(msg), tostring(actual), tostring(expected)))
end

-- Species 4/5/6 = Charmander/Charmeleon/Charizard.
Pokemon.learnset = function(sp)
  if sp == 6 then return { { 1, 10 }, { 34, 53 }, { 46, 126 } } end
  if sp == 5 then return { { 1, 10 }, { 30, 53 } } end
  if sp == 4 then return { { 1, 10 }, { 7, 52 } } end
  return {}
end
Pokemon.evolutions = function(sp)
  if sp == 4 then return { { method = 4, param = 16, target = 5 } } end
  if sp == 5 then return { { method = 4, param = 36, target = 6 } } end
  return {}
end
Pokemon.eggMoves = function(sp)
  if sp == 4 then return { 187 } end
  return nil
end
-- TM35 is move 53, HM01 is move 15.
Pokemon.canLearnTmIndex = function(sp, i)
  return sp == 6 and (i == 34 or i == 50)
end
Pokemon.moveFromTmItem = function(item)
  if item == 289 + 34 then return 53 end
  if item == 289 + 50 then return 15 end
  return nil
end
MoveLearn.tutorMoveCount = function() return 2 end
MoveLearn.tutorMove = function(i) return ({ 7, 8 })[i + 1] end
MoveLearn.canLearnTutorMove = function(sp, i) return sp == 6 and i == 0 end

local S = {
  version = "emerald",
  save = { version = "emerald", engine = "game3", generation = 3 },
  data = { pokemon = {} },
}
for sp = 1, 411 do S.data.pokemon[sp] = { speciesId = sp } end

local map = assert(MoveSources.forSpecies(S, 6), "Charizard provenance map")

eq(map[53].lv, 34, "Flamethrower keeps the earliest learn level")
check(map[53].tm, "Flamethrower is TM35")
check(map[15].hm, "Cut is HM01")
check(map[187].egg, "Belly Drum is an egg move of Charmander")
check(map[7].tut, "Fire Punch is a tutor move")
check(map[52].pre, "Ember comes from an earlier form")
check(map[126].lv == 46, "high-level moves are tagged even above the current level")
check(map[999] == nil, "unknown moves carry no tag")

local marks = MoveSources.marks(map[53])
eq(#marks, 3, "Flamethrower shows Lv, TM and Pre")
eq(marks[1].text, "Lv34", "level tag first")
eq(marks[2].text, "TM", "TM tag second")
eq(marks[3].text, "Pre", "Pre tag last")

-- Cached: a second lookup returns the same table.
check(rawequal(MoveSources.forSpecies(S, 6), map), "provenance is cached per species")

-- Gen 1 / Gen 2 stay untagged.
local S1 = { version = "red", save = { version = "red", generation = 1 }, data = { pokemon = {} } }
check(MoveSources.forSpecies(S1, 6) == nil, "Gen 1 has no provenance tags")
local S2 = { version = "gold", save = { version = "gold", generation = 2 }, data = { pokemon = {} } }
check(MoveSources.forSpecies(S2, 6) == nil, "Gen 2 has no provenance tags")

-- reset() drops the caches so a reload picks up a different catalog.
MoveSources.reset(S)
check(S._moveSources == nil, "reset clears the per-species cache")

print(("save_editor_move_sources: %d passed, %d failed"):format(passed, failed))
os.exit(failed == 0 and 0 or 1)
