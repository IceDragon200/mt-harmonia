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
end

function ic:init()
  --
end

function ic:terminate()
  --
end

function ic:update(delta)
  --
  local players = minetest.get_connected_players()

  for _, player in pairs(players) do
    local meta = player:get_meta()

    local level = ManaSchema:get_mana_level(meta)
    if level > 0 then
      -- this player has mana, do the usual fancy
    end
  end
end

local mana_system = ManaSystem:new()

minetest.register_on_mods_loaded(mana_system:method("init"))
minetest.register_globalstep(mana_system:method("update"))
minetest.register_on_shutdown(mana_system:method("terminate"))

harmonia_mana.mana_system = mana_system
