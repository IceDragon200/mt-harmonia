--[[

  Harmonia Crystals

  Adds elemental crystals

]]
harmonia_crystals = rawget(_G, "harmonia_crystals") or {}
harmonia_crystals.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(harmonia_crystals.modpath .. "/api.lua")

dofile(harmonia_crystals.modpath .. "/items.lua")
dofile(harmonia_crystals.modpath .. "/nodes.lua")
