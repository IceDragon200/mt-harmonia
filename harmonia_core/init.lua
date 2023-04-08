--
-- Harmonia Core
--
local mod = foundation.new_module("harmonia_core", "1.0.0")

--- @namespace harmonia
harmonia = rawget(_G, "harmonia") or {}
--- @namespace harmonia.config
harmonia.config = harmonia.config or {}

mod:require("config.lua")
mod:require("formspec.lua")
