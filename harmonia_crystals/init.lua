--[[

  Harmonia Crystals

  Adds elemental crystals

]]
local mod = foundation.new_module("harmonia_crystals", "0.0.1")

if not foundation.com.node_sounds:is_registered("crystal") then
  foundation.com.node_sounds:register("crystal", {})
end

mod:require("api.lua")

mod:require("items.lua")
mod:require("nodes.lua")
