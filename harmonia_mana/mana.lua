local ManaSchema =
  yatm_core.MetaSchema:new("mana", "", {
    -- Mana Level dictates whether or not the object has mana or not
    -- For now it's either 0 or 1, but could change if I deem it necessary
    -- 0 means the entity has no mana, otherwise it does.
    -- Default: 0
    mana_level = {
      type = "integer",
    },
    -- This represents the entity's current mana amount
    -- Default: 0
    mana = {
      type = "float",
    },
    -- Maximum amount of mana the object can contain
    mana_max = {
      type = "float",
    },
    -- This is a built-in regeneration value, entity's and increase or decrease this value to change
    -- their mana behaviour
    -- Default: 0
    mana_regen = {
      type = "float",
    },
  }):compile("manasys")

local ManaSystem = yatm_core.Class:extends("ManaSystem")
local ic = assert(ManaSystem.instance_class)

function ic:initialize()
  --
  -- Systems are a list of modules that should be called on update
  -- Using the mana system entities
  self.systems = {}

  self.initialized = false
  self.terminated = false
end

function ic:init()
  --
  minetest.log("info", "harmonia bestows mana to the world")
  self.initialized = true
end

function ic:terminate()
  --
  minetest.log("info", "harmonia retracts mana from the world")
  self.terminated = true
end

function ic:update(delta)
  --
  if not self.initialized then
    -- the system hasn't been initialized yet, skip the update
    return
  end
  if self.terminated then
    -- the system has been terminated, skip the update
    return
  end
  local players = minetest.get_connected_players()

  for _, player in pairs(players) do
    local meta = player:get_meta()

    local level = ManaSchema:get_mana_level(meta)
    if level > 0 then
      -- this player has mana, do the usual fancy
    end
  end
end

function ic:on_player_join(player)
  hb.init_hudbar(player, 'mana', 10, 10, false)
end

harmonia_mana.ManaSystem = ManaSystem
harmonia_mana.ManaSchema = ManaSchema
