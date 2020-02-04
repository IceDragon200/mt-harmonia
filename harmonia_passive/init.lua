--[[

  Harmonia Passive

  Adds passive abilities and effects to entities.

]]
harmonia_passive = rawget(_G, "harmonia_passive") or {}
harmonia_passive.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(harmonia_passive.modpath .. "/passives.lua")

dofile(harmonia_passive.modpath .. "/api.lua")
