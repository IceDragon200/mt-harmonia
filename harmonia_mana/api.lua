harmonia = rawget(_G, "harmonia") or {}
harmonia.mana = harmonia.mana or {}

local mana_system = harmonia_mana.ManaSystem:new()

minetest.register_on_mods_loaded(mana_system:method("init"))
minetest.register_globalstep(mana_system:method("update"))
minetest.register_on_shutdown(mana_system:method("terminate"))
minetest.register_on_joinplayer(mana_system:method("on_player_join"))

harmonia.mana.ManaSchema = harmonia_mana.ManaSchema
harmonia.mana.system = mana_system

if rawget(_G, "hb") then
  hb.register_hudbar("mana",
                     0xFFFFFF,
                     "Mana",
                     { icon = "harmonia_hudbar_mana_icon.png",
                       bgicon = "harmonia_hudbar_mana_bgicon.png",
                       bar = "harmonia_hudbar_mana.png" },
                     0,
                     10, false)
end
