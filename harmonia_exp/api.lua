harmonia = rawget(_G, "harmonia") or {}
harmonia.exp = harmonia.exp or {}

local exp_system = harmonia_exp.ExpSystem:new()

minetest.register_on_mods_loaded(exp_system:method("init"))
minetest.register_on_shutdown(exp_system:method("terminate"))

if foundation.is_module_present("nokore_player_service") then
  nokore.player_service:register_on_player_join(
    "harmonia_exp:on_player_join",
    exp_system:method("on_player_join")
  )
else
  minetest.register_on_joinplayer(exp_system:method("on_player_join"))
end
harmonia.exp.system = exp_system

if rawget(_G, "hb") then
  hb.register_hudbar("exp",
                     0xFFFFFF,
                     "EXP",
                     { icon = "harmonia_hudbar_exp_icon.png",
                       bgicon = "harmonia_hudbar_exp_bgicon.png",
                       bar = "harmonia_hudbar_exp.png" },
                     0,
                     10, false)
end
