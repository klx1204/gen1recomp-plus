-- Type name lookup for custom ids.  No ROM: the cases here must never read
-- gTypeNames, which is where the old code went wrong.
package.path = "./?.lua;./?/init.lua;" .. package.path
love = love or require("tests.love_stub")

local Types = require("src.core.game3.battle.types")

-- gTypeNames has 18 entries.  Emerald's next table starts with the contest
-- categories, so an out-of-range read returned "COOL" for type 18.
assert(Types.name(18) == "TYPE 18",
  "type 18 without an override must not read past gTypeNames: " .. tostring(Types.name(18)))
assert(Types.name(19) == "TYPE 19", "type 19 must use the same fallback")

-- Custom names outlive clearOverlay(), which is what keeps FAIRY readable
-- after a VANILLA switch or a link-battle rebuild.
Types.CUSTOM_NAMES[18] = "FAIRY"
assert(Types.name(18) == "FAIRY", "CUSTOM_NAMES must win")
Types.useOverlay({ table = { 18, 16, 20, -1, -1, 0 }, physical = {}, names = { [18] = "FAIRY" } })
assert(Types.name(18) == "FAIRY", "overlay name")
Types.clearOverlay()
assert(Types.name(18) == "FAIRY", "name must survive clearOverlay")

print("type_names_test: ok")
