-- Register the element blueprint registry for players
-- Each player may have different blueprints unlocked
nokore.player_data_service:register_domain("element_blueprints", {
  save_method = "marshall",
})

harmonia = rawget(_G, "harmonia") or {}

harmonia.registered_element_blueprints = {}

-- Unlocks an element blueprint for a specific player
--
-- @spec #unlock_player_element_blueprint(player_name: String, blueprint_id: String): void
function harmonia:unlock_player_element_blueprint(player_name, blueprint_id)
  nokore.player_data_service:with_player_domain_kv(player_name, "element_blueprints", function (kv_store)
    kv_store:put(blueprint_id, true)
  end)
end

local function register_element_blueprint(blueprint_id, name)
  if harmonia.registered_element_blueprints[blueprint_id] then
    minetest.log("warn", "blueprint_id=" .. blueprint_id .. " already registered as name=" .. name)
  end
  harmonia.registered_element_blueprints[blueprint_id] = name
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
