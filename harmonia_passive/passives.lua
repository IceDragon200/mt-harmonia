local PassiveSystem = foundation.com.Class:extends("PassiveSystem")
local ic = PassiveSystem.instance_class

function ic:initialize()
  --
  -- Systems are a list of modules that should be called on update
  -- Using the mana system entities
  self.systems = {}

  -- Indexed by player name, this table contains a list of all the passives a player has
  self.player_passives = {}
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
  end
end

local passive_system = PassiveSystem:new()

minetest.register_on_mods_loaded(passive_system:method("init"))
minetest.register_globalstep(passive_system:method("update"))
minetest.register_on_shutdown(passive_system:method("terminate"))

harmonia_passive.passive_system = passive_system
