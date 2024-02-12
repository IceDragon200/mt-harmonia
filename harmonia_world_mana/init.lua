--[[

  Harmonia World Mana

  Combined with Harmonia Mana, adds mana related features to world.

]]
local mod = foundation.new_module("harmonia_world_mana", "0.2.0")

mod:require("config.lua")
mod:require("api.lua")

nokore_proxy.register_globalstep(
  "hamornia_world_mana:update/2",
  harmonia_world_mana.update
)
