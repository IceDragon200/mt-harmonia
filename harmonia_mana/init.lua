--[[

  Harmonia Mana

  Establishes the magic system and services for said system.

  i.e. It adds MP to players and any other entities that need it.

]]
harmonia_mana = rawget(_G, "harmonia_mana") or {}
harmonia_mana.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(harmonia_mana.modpath .. "/mana.lua")

dofile(harmonia_mana.modpath .. "/api.lua")
