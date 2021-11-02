-- @namespace harmonia.element
local mod = harmonia_element

local DATA_DOMAIN = "element_blueprints"

local player_data_service = assert(nokore.player_data_service)
--local player_service = assert(nokore.player_service)

player_data_service:register_domain(DATA_DOMAIN, {
  save_method = "marshall",
})

harmonia = rawget(_G, "harmonia") or {}

harmonia.element = harmonia_element.ElementSystem:new(DATA_DOMAIN)

mod:require("stats.lua")

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
    if name ~= "air" and name ~= "" then
      if item.element_blueprint_id == nil then
        minetest.override_item(name, {
          element_blueprint_id = name,
        })

        register_element_blueprint(name, name)
      elseif item.element_blueprint_id == false then
        -- skip it
      elseif item.element_blueprint_id then
        register_element_blueprint(item.element_blueprint_id, name)
      end
    end
  end
end

minetest.register_on_mods_loaded(function ()
  backfill_element_blueprint_ids()
end)

nokore.player_service:register_update("harmonia_element:update_players", harmonia.element:method("update_players"))
