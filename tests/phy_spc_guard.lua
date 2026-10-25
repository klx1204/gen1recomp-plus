-- Guard the upstream seams this fork depends on. This is intentionally a
-- source-text check: it runs without generated data and fails loudly when an
-- upstream refactor renames or removes a seam.
local function read(path)
  local f = io.open(path, "rb")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end

local function contains(path, needle)
  local text = assert(read(path), "missing " .. path)
  assert(text:find(needle, 1, true), path .. " no longer contains " .. needle)
end

contains("src/core/game3/battle/types.lua", "function Types.isPhysical")
contains("src/core/game3/battle/damage.lua", "Types.isPhysical")
contains("src/core/game3/battle/engine.lua", "Types.isPhysical")
contains("src/core/game3/battle/effects/hit.lua", "Types.isPhysical")
contains("src/core/game3/battle/moves.lua", "from_rom")
contains("src/core/game3/battle/ui.lua", "draw_move_menu")

assert(read("src/core/game3/battle/phy_spc.lua"), "phy_spc.lua missing")
assert(read("src/core/game3/battle/phy_spc_menu.lua"), "phy_spc_menu.lua missing")

print("phy_spc_guard: ok")
