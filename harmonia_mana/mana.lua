local ManaSchema =
  foundation.com.MetaSchema:new("mana", "", {
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
    -- This is a built-in regeneration value, entity's can increase or decrease this value to change
    -- their mana behaviour
    -- Default: 0
    mana_regen = {
      type = "float",
    },
  }):compile("manasys")

local ManaSystem = foundation.com.Class:extends("ManaSystem")
local ic = assert(ManaSystem.instance_class)

-- @type SystemDefinition :: {
--   init = () :: term,
--   update = (delta::Float, Entity, ManaSchema, MetaRef, assigns::term) :: void,
--   terminate = (reason::String, assigns::term) :: void,
-- }

function ic:initialize()
  --
  -- Systems are a list of modules that should be called on update
  -- Using the mana system entities
  -- @type {String => SystemDefinition}
  self.systems = {}

  -- @type {String => term}
  self.system_assigns = {}

  self.initialized = false
  self.terminated = false
end

function ic:register_system(name, def)
  if self.initialized then
    error("ManaSystem is initialized, no additional systems can be registered")
  end

  if self.systems[name] then
    error("a system is already registered for name=" .. name)
  end

  assert(type(def) == "table", "expected a definition table")
  assert(type(def.init) == "function", "expected an init function")
  assert(type(def.update) == "function", "expected an update function")
  assert(type(def.terminate) == "function", "expected a terminate function")

  self.systems[name] = def
end

function ic:unregister_system(name)
  if self.initialized then
    error("ManaSystem is initialized, no systems can be unregistered")
  end

  self.systems[name] = nil
end

function ic:init()
  --
  minetest.log("info", "harmonia bestows mana to the world")
  self.initialized = true

  for name, system in pairs(self.systems) do
    self.system_assigns[name] = system.init()
  end
end

function ic:terminate(reason)
  --
  minetest.log("info", "harmonia retracts mana from the world")
  reason = reason or "normal"
  self.terminated = true

  for name, system in pairs(self.systems) do
    local assigns = self.system_assigns[name]
    system.terminate(reason, assigns)
  end
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
      for name, system in pairs(self.systems) do
        local assigns = self.system_assigns[name]
        system.update(delta, player, self, assigns)
      end
    end
  end
end

function ic:get_entity_mana(entity)
  if minetest.is_player(entity) then
    local meta = entity:get_meta()

    local level = ManaSchema:get_mana_level(meta)
    return ManaSchema:get_mana(meta)
  else
    -- TODO: support mana on non-player entities
    return 0
  end
end

function ic:set_entity_mana(entity, value)
  if minetest.is_player(entity) then
    local meta = entity:get_meta()

    local level = ManaSchema:get_mana_level(meta)
    local max = self:get_entity_mana_max(entity)
    ManaSchema:set_mana(meta, math.max(math.min(value, max), 0))
  else
    -- TODO: support mana on non-player entities
  end
end

function ic:get_entity_mana_max(entity)
  if minetest.is_player(entity) then
    local meta = entity:get_meta()

    local level = ManaSchema:get_mana_level(meta)
    return ManaSchema:get_mana_max(meta)
  else
    -- TODO: support mana on non-player entities
    return 0
  end
end

function ic:set_entity_mana_max(entity, value)
  if minetest.is_player(entity) then
    local meta = entity:get_meta()

    local level = ManaSchema:get_mana_level(meta)
    ManaSchema:set_mana_max(meta, math.max(value, 0))
  else
    -- TODO: support mana on non-player entities
  end
end

function ic:get_entity_mana_level(entity)
  if minetest.is_player(entity) then
    local meta = entity:get_meta()

    return ManaSchema:get_mana_level(meta)
  else
    -- TODO: support mana on non-player entities
    return 0
  end
end

function ic:set_entity_mana_level(entity, value)
  if minetest.is_player(entity) then
    local meta = entity:get_meta()

    ManaSchema:set_mana_level(meta, math.max(value, 0))
  else
    -- TODO: support mana on non-player entities
  end
end

function ic:get_entity_mana_regen(entity)
  if minetest.is_player(entity) then
    local meta = entity:get_meta()

    return ManaSchema:get_mana_regen(meta)
  else
    -- TODO: support mana on non-player entities
    return 0
  end
end

function ic:set_entity_mana_regen(entity, value)
  if minetest.is_player(entity) then
    local meta = entity:get_meta()

    ManaSchema:set_mana_regen(meta, value)
  else
    -- TODO: support mana on non-player entities
  end
end

function ic:on_player_join(player)
  if rawget(_G, "hb") then
    hb.init_hudbar(player, 'mana', 10, 10, false)
  end
end

harmonia_mana.ManaSystem = ManaSystem
harmonia_mana.ManaSchema = ManaSchema
