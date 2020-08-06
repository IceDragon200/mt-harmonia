--[[

  Harmonia Nyctophobia

  Adds a passive system that damages players who are in areas with reduced light.

  To make it... less annoying, it only happens at night

]]
local mod = foundation.new_module("harmonia_nyctophobia", "0.0.1")

mod:require("nyctophobia.lua")

mod:require("api.lua")
