minetest.register_on_mods_loaded(harmonia.passive.system:method("init"))
minetest.register_on_shutdown(harmonia.passive.system:method("terminate"))
nokore.player_service:register_update(
  "harmonia_passive:update_players",
  harmonia.passive.system:method("update_players")
)
