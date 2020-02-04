--[[

  Harmonia EXP

  Adds a experience and level system

]]
harmonia_exp = rawget(_G, "harmonia_exp") or {}
harmonia_exp.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(harmonia_exp.modpath .. "/exp.lua")

dofile(harmonia_exp.modpath .. "/api.lua")
