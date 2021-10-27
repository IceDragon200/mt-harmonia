--[[

  Harmonia Mana

  Establishes the magic system and services for said system.

  i.e. It adds MP to players and any other entities that need it.

]]
local mod = foundation.new_module("harmonia_mana", "0.2.0")

mod:require("mana.lua")

mod:require("api.lua")
