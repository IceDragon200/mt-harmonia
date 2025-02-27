---
--- Harmonia Passive
---
---   Adds passive abilities and effects to entities.
---
local mod = foundation.new_module("harmonia_passive", "0.2.0")

local player_data_service = assert(nokore.player_data_service)

--- @namespace harmonia
harmonia = rawget(_G, "harmonia") or {}
--- @namespace harmonia.passive
harmonia.passive = harmonia.passive or {}

local DATA_DOMAIN = "harmonia_passive"
nokore.player_data_service:register_domain(DATA_DOMAIN, {
  save_method = "marshall"
})

mod:require("passive_registry.lua")
--- @const passive_registry: harmonia_passive.PassiveRegistry
harmonia.passive.registry = harmonia_passive.PassiveRegistry:new()

mod:require("passive_system.lua")
local passive_system = harmonia_passive.PassiveSystem:new{
  data_domain = DATA_DOMAIN,
  passive_registry = harmonia.passive.registry,
  player_data_service = player_data_service,
}
--- @const system: harmonia_passive.PassiveSystem
harmonia.passive.system = passive_system

mod:require("api.lua")
mod:require("hooks.lua")

if foundation.com.Luna then
  mod:require("test.lua")
end
