--[[

  Harmonia Totems

  Random little statues

]]
harmonia_totems = rawget(_G, "harmonia_totems") or {}
harmonia_totems.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(harmonia_totems.modpath .. "/nodes.lua")
