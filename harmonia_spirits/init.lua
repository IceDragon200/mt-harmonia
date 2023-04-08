--
-- Harmonia Spirits
--
--   Adds spirits (as in invisible beings, not liquor).
--
local mod = foundation.new_module("harmonia_spirits", "0.1.0")

mod:require("api.lua")

mod:require("items.lua")
mod:require("nodes.lua")

mod:require("registration.lua")

if foundation.is_module_present("yatm_autotest") then
  mod:require("autotest.lua")
end
