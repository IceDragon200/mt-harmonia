harmonia = rawget(_G, "harmonia") or {}
harmonia.mana = harmonia.mana or {}

local mana_system = harmonia_mana.ManaSystem:new()

-- The Mana system's regen feature
mana_system:register_system("harmonia_mana:mana_regen", {
  init = function ()
    return {}
  end,

  update = function (delta, player, system, assigns)
    local regen = system:get_entity_mana_regen(player)
    if regen > 0 then
      local mana = system:get_entity_mana(player)
      system:set_entity_mana(player, mana + regen)
    end
  end,

  terminate = function (_reason, _assigns)
    --
  end,
})

minetest.register_on_mods_loaded(mana_system:method("init"))
minetest.register_globalstep(mana_system:method("update"))
minetest.register_on_shutdown(mana_system:method("terminate"))
minetest.register_on_joinplayer(mana_system:method("on_player_join"))

harmonia.mana.ManaSchema = harmonia_mana.ManaSchema
harmonia.mana.system = mana_system

if rawget(_G, "nokore_player_hud") then
  nokore_player_hud.register_hud_element("mana", {
    hud_elem_type = "statbar",
    position = {
      x = 0.5,
      y = 1,
    },
    text = "harmonia_mana_full.png",
    text2 = "harmonia_mana_empty.png",
    number = 20,
    item = 20,
    direction = 0,
    size = {x = 24, y = 24},
    offset = {
      x = 24,
      -- -(hotbar_height + icon_height + bottom_padding + margin + offset)
      y = -(48 + 24 + 16 + 8 + 32)
    },
  })
end

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
