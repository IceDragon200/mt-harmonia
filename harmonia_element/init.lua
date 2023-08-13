--
-- Harmonia Element
--
--   Element entails a secondary crafting system that can effectively make
--   any item from nothing.
--   However a blueprint must be registered for the player to craft the item.
--
--
local mod = foundation.new_module("harmonia_element", "0.2.0")

mod:require("element_system.lua")

mod:require("api.lua")

mod:require("chat_commands.lua")

mod:require("items.lua")

mod:require("stats.lua")

mod.register_stats(nokore.player_stats)

if foundation.is_module_present("yatm_autotest") then
  mod:require("autotest.lua")
end

if foundation.is_module_present("foundation_unit_test") then
  mod:require("tests.lua")
end
