if harmonia.config then
  if harmonia.config.enable_mana_hud_integration ~= nil then
    if harmonia.config.enable_mana_hud_integration then
      --- all is well
    else
      --- Skip the integration
      return
    end
  end
end

if rawget(_G, "hb") then
  nokore.player_service:register_on_player_join("harmonia_mana:init_hb", function (player)
    hb.init_hudbar(player, 'mana', 10, 10, false)
  end)

  hb.register_hudbar("mana",
                     0xFFFFFF,
                     "Mana",
                     { icon = "harmonia_hudbar_mana_icon.png",
                       bgicon = "harmonia_hudbar_mana_bgicon.png",
                       bar = "harmonia_hudbar_mana.png" },
                     0,
                     10, false)
end

if foundation.is_module_present("nokore_player_hud") then
  nokore.player_hud:register_hud_element("mana", {
    type = "statbar",
    position = {
      x = 0.5,
      y = 1,
    },
    text = "harmonia_mana_full.png",
    text2 = "harmonia_mana_empty.png",
    number = 20,
    item = 20,
    direction = nokore.player_hud.DIRECTION_LEFT_RIGHT,
    size = {x = 24, y = 24},
    offset = {
      x = 24,
      -- -(hotbar_height + icon_height + bottom_padding + margin + offset)
      y = -(48 + 24 + 16 + 8 + 32)
    },
  })

  nokore.player_hud:register_on_init_player_hud_element(
    "harmonia_mana:mana_init",
    "mana",
    function (player, _elem_name, hud_def)
      local mana_max = player_stats:get_player_stat(player, "mana_max")

      if mana_max > 0 then
        return hud_def
      end

      return nil
    end
  )
end
