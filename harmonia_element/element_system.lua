local player_data_service = assert(nokore.player_data_service)
local player_stats = assert(nokore.player_stats)

local ElementSystem = foundation.com.Class:extends("harmonia_element.ElementSystem")
local ic = ElementSystem.instance_class

-- @spec #initialize(): void
function ic:initialize(data_domain)
  self.m_data_domain = data_domain
  -- @type registered_element_blueprints: {
  --   [blueprint_id: String]: (item_name: String)
  -- }
  self.registered_element_blueprints = {}
end

-- Toggles an element blueprint for a specific player
--
-- @spec #toggle_player_element_blueprint(
--         player_name: String,
--         blueprint_id: String,
--         value: Boolean | nil
--       ): Boolean
function ic:toggle_player_element_blueprint(player_name, blueprint_id, value)
  return player_data_service:with_player_domain_kv(player_name, self.m_data_domain, function (kv_store)
    kv_store:put(blueprint_id, value)
    return true
  end)
end

-- Unlocks an element blueprint for a specific player.
-- Returns true if the blueprint was unlocked, false if inaccessible.
--
-- @spec #unlock_player_element_blueprint(player_name: String, blueprint_id: String): Boolean
function ic:unlock_player_element_blueprint(player_name, blueprint_id)
  return self:toggle_player_element_blueprint(player_name, blueprint_id, true)
end

-- Locks a player's blueprint.
-- Returns true if the blueprint was locked, false if inaccesible.
--
-- @spec #lock_player_element_blueprint(player_name: String, blueprint_id: String): Boolean
function ic:lock_player_element_blueprint(player_name, blueprint_id)
  return self:toggle_player_element_blueprint(player_name, blueprint_id, nil)
end

-- Determines if a player has a specific blueprint.
--
-- @spec #player_has_element_blueprint(player_name: String, blueprint_id: String): Boolean
function ic:player_has_element_blueprint(player_name, blueprint_id)
  local kv = player_data_service:get_player_domain_kv(player_name, self.m_data_domain)

  if kv then
    return kv:get(blueprint_id) == true
  end

  return false
end

-- Retrieves the blueprint unlock map for the specified player
-- Note that the table returned is the raw underlying key-value map.
-- Under no circumstance should the caller try to modify this table as it can
-- compromise the integrity of the key-value store.
--
-- @spec #get_player_element_blueprints(player_name: String): Table | nil
function ic:get_player_element_blueprints(player_name)
  local kv = player_data_service:get_player_domain_kv(player_name, self.m_data_domain)

  if kv then
    return kv.data
  end

  return nil
end

function ic:update_players(players, dt, assigns)
  local player_assigns
  local element_regen_time
  local element_regen
  local meta
  local element
  local element_max

  for player_name, player in pairs(players) do
    meta = player:get_meta()
    player_assigns = assigns[player_name]

    element_regen_time = player_assigns["element_regen_time"] or 0
    element_regen_time = element_regen_time + dt

    if element_regen_time > 1 then
      element_regen_time = element_regen_time - 1

      element_regen = player_stats:get_player_stat(player, "element_regen")

      if element_regen > 0 then
        element_max = player_stats:get_player_stat(player, "element_max")
        element = meta:get_int("element")
        -- this allows element to overflow
        if element < element_max then
          -- but if it's under it will cap it at the maximum
          element = math.min(element + element_regen, element_max)
        end
      end
    end

    player_assigns["element_regen_time"] = element_regen_time
  end
end

harmonia_element.ElementSystem = ElementSystem
