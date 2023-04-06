--
-- Harmonia Element
--
--   Element entails a secondary crafting system that can effectively make
--   any item from nothing.
--   However a blueprint must be registered for the player to craft the item.
--
--
local mod = foundation.new_module("harmonia_element", "0.1.0")

mod:require("element_system.lua")

mod:require("api.lua")

mod:require("chat_commands.lua")

mod:require("items.lua")

mod:require("stats.lua")
