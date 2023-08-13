--- @namespace harmonia.element
local mod = assert(harmonia_element)

local BLUEPRINT_DATA_DOMAIN = "element_blueprints"
local CRAFTING_DATA_DOMAIN = "element_crafting"

local player_data_service = assert(nokore.player_data_service)
local player_stats = assert(nokore.player_stats)

player_data_service:register_domain(BLUEPRINT_DATA_DOMAIN, {
  save_method = "marshall",
})

player_data_service:register_domain(CRAFTING_DATA_DOMAIN, {
  save_method = "marshall",
})

harmonia = rawget(_G, "harmonia") or {}

harmonia.element = harmonia_element.ElementSystem:new{
  player_data_service = player_data_service,
  player_stats = player_stats,
  blueprint_data_domain = BLUEPRINT_DATA_DOMAIN,
  crafting_data_domain = CRAFTING_DATA_DOMAIN,
}

mod:require("stats.lua")

--
-- private sauce
--

local function register_element_blueprint(blueprint, name)
  assert(type(blueprint) == "table", "expected a blueprint table")
  if harmonia.element.registered_element_blueprints[blueprint.id] then
    minetest.log("warn", "blueprint_id=" .. blueprint.id .. " already registered as name=" .. name)
  end
  harmonia.element.registered_element_blueprints[blueprint.id] = {
    id = assert(blueprint.id),
    name = name,
    cost = assert(blueprint.cost, "expected blueprint to have a cost"),
    duration = assert(blueprint.duration, "expected blueprint to have a duration"),
  }
end

local function backfill_element_blueprints()
  minetest.log("info", "backfilling items with element_blueprint")
  for name, item in pairs(minetest.registered_items) do
    if name ~= "air" and name ~= "" then
      if item.element_blueprint == nil then
        local element_blueprint = {
          id = name,
          cost = 20,
          duration = 30,
        }

        minetest.override_item(name, {
          element_blueprint = element_blueprint,
        })

        register_element_blueprint(element_blueprint, name)
      elseif item.element_blueprint == false then
        -- skip it
      elseif item.element_blueprint then
        register_element_blueprint(item.element_blueprint, name)
      end
    end
  end
  minetest.log("info", "backfilled items with element_blueprint_id")
end

minetest.register_on_mods_loaded(function ()
  backfill_element_blueprints()
end)

nokore.player_service:register_update(
  "harmonia_element:update_players",
  harmonia.element:method("update_players")
)
