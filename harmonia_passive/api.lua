harmonia = rawget(_G, "harmonia") or {}
harmonia.passive = harmonia.passive or {}

local DATA_DOMAIN = "harmonia_passive"
local passive_system = PassiveSystem:new(DATA_DOMAIN)

minetest.register_on_mods_loaded(passive_system:method("init"))
minetest.register_on_shutdown(passive_system:method("terminate"))
nokore.player_service:register_update(
  "harmonia_passive:update_players",
  passive_system:method("update_players")
)

nokore.player_data_service:register_domain(DATA_DOMAIN, {
  save_method = "marshall"
})

harmonia.passive.system = passive_system
