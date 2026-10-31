-- Optional mod companion, independent of FireRed event-object IDs and scripts.
local function lazyReq(name)
  local m = package.loaded[name]
  if type(m) == "table" then return m end
  return require(name)
end

local Follower = {}
local ModRuntime = require("src.mods.Runtime")
local shouldSpawn = function() return false end
local npc, lastMap, trailX, trailY

function Follower.setShouldSpawn(fn)
  local previous = shouldSpawn
  shouldSpawn = fn or previous
  return previous
end

function Follower.reset()
  npc, lastMap, trailX, trailY = nil, nil, nil, nil
end

--- Hide the companion regardless of the mod's own rule (a script or another
--- mod's switch, the equivalent of pret's flag).
function Follower.setHidden(on) Follower.forcedHidden = on and true or false end

function Follower.current() return npc end
function Follower.talk() return false end
function Follower.starterInParty() return nil end
function Follower.setVisible(_, visible) if npc then npc.hidden = not visible end end
function Follower.at(_, x, y)
  if npc and not npc.moving and npc.cellX == x and npc.cellY == y then return npc end
end

function Follower.update(game)
  local Field = lazyReq("src.core.game3.field")
  local player = lazyReq("src.core.game3.player")
  local session = Field.getSession()
  local world = { player = player, map = { id = session and session.map } }
  if not Field.running or not session or Follower.forcedHidden
      or not ModRuntime.call("world.follower.spawn", shouldSpawn, game, world) then
    Follower.reset()
    return
  end
  local teleported = trailX and (math.abs(player.cellX - trailX) + math.abs(player.cellY - trailY) > 6)
  if not npc or lastMap ~= session.map or teleported then
    -- Appear on the tile behind the player (the door the player came out of),
    -- not on top of them: HGSS / pret move the follower out of the doorway.
    local bx, by = player.cellX, player.cellY
    local BEHIND = { down = { 0, -1 }, up = { 0, 1 }, left = { 1, 0 }, right = { -1, 0 } }
    local d = BEHIND[player.facing or "down"]
    if d then
      local Collision = package.loaded["src.core.game3.collision"]
        or lazyReq("src.core.game3.collision")
      if Collision and Collision.canEnter
          and Collision.canEnter(game, player.cellX + d[1], player.cellY + d[2],
            { fromX = player.cellX, fromY = player.cellY,
              dir = player.facing or "down", elevation = player.elevation }) then
        bx, by = player.cellX + d[1], player.cellY + d[2]
      end
    end
    npc = { cellX = bx, cellY = by, px = bx * 16, py = by * 16,
      facing = player.facing, passable = true, pikachuFollower = true, moving = false }
    lastMap, trailX, trailY = session.map, player.cellX, player.cellY
  end
  local tx = player.moving and player.targetX or player.cellX
  local ty = player.moving and player.targetY or player.cellY
  -- A ledge jump lands two cells away.  If the companion is right behind the
  -- player it jumps the same ledge at the same time (pret
  -- MOVEMENT_ACTION_JUMP_2_*), instead of skipping the cell and walking
  -- through the ledge later.
  local jumped = false
  if player.jumping and player.moving and not npc.moving then
    local jx, jy = tx - player.cellX, ty - player.cellY
    if math.abs(jx) + math.abs(jy) >= 2 then
      local sx = jx > 0 and 1 or (jx < 0 and -1 or 0)
      local sy = jy > 0 and 1 or (jy < 0 and -1 or 0)
      if npc.cellX == player.cellX - sx and npc.cellY == player.cellY - sy then
        npc.goalX, npc.goalY = npc.cellX + sx * 2, npc.cellY + sy * 2
        trailX, trailY = tx, ty
        jumped = true
      end
    end
  end
  if not jumped and (tx ~= trailX or ty ~= trailY) then
    npc.goalX, npc.goalY = trailX, trailY
    trailX, trailY = tx, ty
  end
  if not npc.moving and npc.goalX then
    local gx, gy = npc.goalX, npc.goalY
    local dx, dy = gx - npc.cellX, gy - npc.cellY
    local distance = math.abs(dx) + math.abs(dy)
    npc.goalX, npc.goalY = nil, nil
    if distance > 6 then
      npc.cellX, npc.cellY, npc.px, npc.py = gx, gy, gx * 16, gy * 16
    elseif distance > 0 then
      npc.facing = math.abs(dx) > math.abs(dy) and (dx > 0 and "right" or "left")
        or (dy > 0 and "down" or "up")
      npc.fromX, npc.fromY = npc.px, npc.py
      npc.targetX, npc.targetY, npc.progress = gx, gy, 0
      npc.stepFrames = math.max(1, math.floor((player.stepFrames or 16) / (distance > 1 and 2 or 1)))
      npc.moving = true
    end
  end
  if npc.moving then
    npc.progress = npc.progress + 1
    local t = math.min(1, npc.progress / npc.stepFrames)
    npc.px = npc.fromX + (npc.targetX * 16 - npc.fromX) * t
    npc.py = npc.fromY + (npc.targetY * 16 - npc.fromY) * t
    if t == 1 then
      npc.cellX, npc.cellY, npc.moving = npc.targetX, npc.targetY, false
    end
  end
  npc.elevation = player.elevation
end

function Follower.onMapEntered() Follower.reset() end

function Follower.actor()
  if not npc or not npc.sprite or npc.hidden then return nil end
  return { kind = "follower", i = -1, x = npc.px, y = npc.py,
    sortY = npc.py, elevation = npc.elevation, facing = npc.facing,
    walkPhase = npc.moving and 1 or 0, renderer = npc.sprite }
end

return Follower
