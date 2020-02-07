--[[

  Harmonia Nyctophobia

  Adds a passive system that damages players who are in areas with reduced light.

  To make it... less annoying, it only happens at night

]]
harmonia_nyctophobia = rawget(_G, "harmonia_nyctophobia") or {}
harmonia_nyctophobia.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(harmonia_nyctophobia.modpath .. "/nyctophobia.lua")

dofile(harmonia_nyctophobia.modpath .. "/api.lua")
