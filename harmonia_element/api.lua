-- @namespace harmonia.element
local DATA_DOMAIN = "element_blueprints"

local player_data_service = assert(nokore.player_data_service)
--local player_service = assert(nokore.player_service)

player_data_service:register_domain(DATA_DOMAIN, {
  save_method = "marshall",
})

harmonia = rawget(_G, "harmonia") or {}

harmonia.element = {}

-- @type registered_element_blueprints: {
--   [blueprint_id: String]: (item_name: String)
-- }
harmonia.element.registered_element_blueprints = {}

-- Toggles an element blueprint for a specific player
--
-- @spec #toggle_player_element_blueprint(
--         player_name: String,
--         blueprint_id: String,
--         value: Boolean | nil
--       ): Boolean
function harmonia.element:toggle_player_element_blueprint(player_name, blueprint_id, value)
  return player_data_service:with_player_domain_kv(player_name, DATA_DOMAIN, function (kv_store)
    kv_store:put(blueprint_id, value)
    return true
  end)
end

-- Unlocks an element blueprint for a specific player.
-- Returns true if the blueprint was unlocked, false if inaccessible.
--
-- @spec #unlock_player_element_blueprint(player_name: String, blueprint_id: String): Boolean
function harmonia.element:unlock_player_element_blueprint(player_name, blueprint_id)
  return self:toggle_player_element_blueprint(player_name, blueprint_id, true)
end

-- Locks a player's blueprint.
-- Returns true if the blueprint was locked, false if inaccesible.
--
-- @spec #lock_player_element_blueprint(player_name: String, blueprint_id: String): Boolean
function harmonia.element:lock_player_element_blueprint(player_name, blueprint_id)
  return self:toggle_player_element_blueprint(player_name, blueprint_id, nil)
end

-- Determines if a player has a specific blueprint.
--
-- @spec #player_has_element_blueprint(player_name: String, blueprint_id: String): Boolean
function harmonia.element:player_has_element_blueprint(player_name, blueprint_id)
  local kv = player_data_service:get_player_domain_kv(player_name, DATA_DOMAIN)

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
function harmonia.element:get_player_element_blueprints(player_name)
  local kv = player_data_service:get_player_domain_kv(player_name, DATA_DOMAIN)

  if kv then
    return kv.data
  end

  return nil
end

--
-- private sauce
--

local function register_element_blueprint(blueprint_id, name)
  if harmonia.element.registered_element_blueprints[blueprint_id] then
    minetest.log("warn", "blueprint_id=" .. blueprint_id .. " already registered as name=" .. name)
  end
  harmonia.element.registered_element_blueprints[blueprint_id] = name
end

local function backfill_element_blueprint_ids()
  for name, item in pairs(minetest.registered_items) do
    if item.element_blueprint_id == nil then
      item.element_blueprint_id = name
      minetest.override_item(name, item)

      register_element_blueprint(item.element_blueprint_id, name)
    elseif item.element_blueprint_id == false then
      -- skip it
    elseif item.element_blueprint_id then
      register_element_blueprint(item.element_blueprint_id, name)
    end
  end
end

minetest.register_on_mods_loaded(function ()
  backfill_element_blueprint_ids()
end)
