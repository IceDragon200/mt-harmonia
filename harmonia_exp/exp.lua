--
-- EXP System
--
-- The system below, manages player and other entities experience points
-- The amount of accumulated exp is still stored on the entity, but changes are done through this module.
-- The system additionally allows defining any arbitary experience types.
--
-- Note this system ONLY handles experience, not levels or the like.
--
local ExpSystem = yatm_core.Class:extends("ExpSystem")
local ic = assert(ExpSystem.instance_class)

function ic:initialize()
  self.initialized = false
  self.terminated = false

  self.max_exp = 0xFFFF -- just something for now

  -- experience types allow the system to be recycled for other experience systems
  -- Still going through the same interface
  self.exp_types = {}

  -- similar to the hp callbacks
  self.loggers = {}
  self.modifiers = {}
end

function ic:init()
  self.initialized = true
end

function ic:terminate()
  self.terminated = true
end

function ic:_execute_modifiers(event, exp_type)
  local continue = true
  local reason
  if self.modifiers[exp_type] then
    for _, func in pairs(self.modifiers[exp_type]) do
      continue, reason = func(event)
      if not continue then
        break
      end
    end
  end
  return continue, reason
end

function ic:_execute_loggers(event, exp_type)
  if self.loggers[exp_type] then
    for _, func in pairs(self.loggers[exp_type]) do
      func(event)
    end
  end
end

function ic:register_exp_type(type, params)
  assert(self.exp_types[type] == nil, "expected experience type " .. type .. " to not be already registered")
  self.exp_types[type] = params
end

function ic:unregister_exp_type(type)
  self.exp_types[type] = nil
end

function ic:register_exp_modifier(exp_type, name, callback)
  assert(exp_type, 'expected an experience type')
  assert(name, 'expected a name')
  assert(self.exp_types[exp_type], "expected experience type " .. exp_type .. " to exist")
  if not self.modifiers[exp_type] then
    self.modifiers[exp_type] = {}
  end
  -- yes you need to name the damn thing, don't try to cheat your way out of this!
  self.modifiers[exp_type][name] = callback
end

function ic:unregister_exp_modifier(exp_type, name)
  assert(exp_type, 'expected an experience type')
  assert(name, 'expected a name')
  if self.modifiers[exp_type] then
    self.modifiers[exp_type][name] = nil
  end
end

function ic:register_on_exp_changed(exp_type, name, callback)
  assert(exp_type, 'expected an experience type')
  assert(name, 'expected a name')
  assert(self.exp_types[exp_type], "expected experience type " .. exp_type .. " to exist")
  if not self.loggers[exp_type] then
    self.loggers[exp_type] = {}
  end
  -- seriously, it needs to be named
  self.loggers[exp_type][name] = callback
end

function ic:unregister_on_exp_changed(exp_type, name)
  assert(exp_type, 'expected an experience type')
  assert(name, 'expected a name')
  if self.loggers[exp_type] then
    self.loggers[exp_type][name] = nil
  end
end

-- player functions just lazily set the exp as a meta value prefixed with `exp_value_`
local function player_get_exp(player, exp_type)
  local meta = player:get_meta()
  return meta:get_int("exp_value_" .. exp_type)
end

local function player_set_exp(player, exp_type, amount)
  local meta = player:get_meta()
  meta:set_int("exp_value_" .. exp_type, amount)
end

function ic:_get_exp_function(entity)
  local lua_entity = entity:get_luaentity()
  if lua_entity then
    if lua_entity.get_exp then
      return lua_entity.get_exp
    end
    -- the entity refuses to set experience
    return nil
  else
    if entity:get_player_name() then
      -- NOTE: honestly a entity:is_player() would have been so much nicer.
      return player_get_exp
    end
    -- not an entity we care about
    return nil
  end
end

function ic:_set_exp_function(entity)
  local lua_entity = entity:get_luaentity()
  if lua_entity then
    if lua_entity.set_exp then
      return lua_entity.set_exp
    end
    -- the entity refuses to set experience
    return nil
  else
    if entity:get_player_name() then
      -- NOTE: honestly a entity:is_player() would have been so much nicer.
      return player_set_exp
    end
    -- not an entity we care about
    return nil
  end
end

-- @type Reason :: {
--   origin = String,
--   params = Table, -- user specified params
--   -- below values are set by increase/decrease exp
--   old_exp = integer, -- the exp the user had before increase/decrease
--   exp = integer, -- the exp the user will have after increase/decrease
-- }
-- @spec set_exp(Entity, Integer, Reason)
function ic:set_exp(entity, exp_type, amount, reason)
  local amount = math.min(math.max(amount, 0), self.max_exp)
  local set_exp_func = self:_set_exp_function(entity)

  if set_exp_func then
    -- reason is a table containing information on why the exp has changed
    local modifier_event = {
      exp_type = exp_type,
      entity = entity,
      old_amount = amount,
      amount = amount,
      reason = reason,
    }
    local continue, error_reason = self:_execute_modifiers(modifier_event, exp_type)
    if not continue then
      return false, error_reason
    end
    set_exp_func(modifier_event.entity, exp_type, modifier_event.amount)
    self:_execute_loggers(modifier_event, exp_type)
    return true
  end
  return false, 'no set_exp'
end

function ic:get_exp(entity, exp_type)
  local get_exp_func = self:_get_exp_function(entity)
  if get_exp_func then
    return get_exp_func(entity, exp_type)
  end
  return nil, 'no get_exp'
end

function ic:increase_exp(entity, exp_type, amount, reason)
  reason = reason or {}
  local exp, error_reason = self:get_exp(entity, exp_type)
  if not exp then
    return false, error_reason
  end

  local new_exp = exp + amount

  reason.old_exp = exp
  reason.exp = new_exp

  return self:set_exp(entity, exp_type, new_exp, reason)
end

function ic:decrease_exp(entity, exp_type, amount, reason)
  return self:increase_exp(entity, exp_type, -amount, reason)
end

local exp_system = ExpSystem:new()

minetest.register_on_mods_loaded(exp_system:method("init"))
minetest.register_on_shutdown(exp_system:method("terminate"))

harmonia_exp.exp_system = exp_system
