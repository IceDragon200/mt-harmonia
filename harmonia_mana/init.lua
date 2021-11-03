--[[

  Harmonia Mana

  Establishes the magic system and services for said system.

  i.e. It adds MP to players and any other entities that need it.

]]
local mod = foundation.new_module("harmonia_mana", "0.3.0")

mod:require("stats.lua")

mod:require("api.lua")
