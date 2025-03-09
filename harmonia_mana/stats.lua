local player_stats = assert(nokore.player_stats)

player_stats:register_stat("mana", {
  cached = false,

  calc = function (_self, player)
    local meta = player:get_meta()

    return meta:get_int("mana")
  end,

  set = function (_self, player, value)
    --- player_stats should be the only one that calls this function
    harmonia.mana:set_player_mana(player, value)
    return true
  end
})

player_stats:register_stat("mana_max", {
  cached = true,

  calc = function (self, player)
    local meta = player:get_meta()

    return self:apply_modifiers(player, meta:get_int("mana_max"))
  end,
})

player_stats:register_stat("mana_regen", {
  cached = true,

  calc = function (self, player)
    local meta = player:get_meta()

    return self:apply_modifiers(player, meta:get_int("mana_regen"))
  end,
})

player_stats:register_stat("mana_degen", {
  cached = true,

  calc = function (self, player)
    local meta = player:get_meta()

    return self:apply_modifiers(player, meta:get_int("mana_degen"))
  end,
})
