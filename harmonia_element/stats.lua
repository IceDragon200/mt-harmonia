-- Register the player's element stat, this is the amount of element stored
nokore.player_stats:register_stat("element", {
  cached = false,

  calc = function (_self, player)
    local meta = player:get_meta()
    return meta:get_int("element")
  end,

  set = function(_self, player, value)
    local meta = player:get_meta()
    meta:set_int("element", value)
  end,
})

nokore.player_stats:register_stat("element_regen", {
  cached = true,

  calc = function (self, player)
    -- the element regen affects how much element is recovered per second
    local meta = player:get_meta()
    local element_regen = meta:get_int("element_regen")

    return self:apply_modifiers(player, element_regen)
  end,
})

nokore.player_stats:register_stat("element_degen", {
  cached = true,

  calc = function (self, player)
    -- the element regen affects how much element is lost per second
    local meta = player:get_meta()
    local element_degen = meta:get_int("element_degen")

    return self:apply_modifiers(player, element_degen)
  end,
})

-- This is the player's maximum available element
nokore.player_stats:register_stat("element_max", {
  cached = true,

  calc = function (self, player)
    -- the element_max in the meta is a fixed amount that a player
    -- can receive, normally this would be affected by things like armour
    -- or abilities
    local meta = player:get_meta()
    local element_max = meta:get_int("element_max")

    return self:apply_modifiers(player, element_max)
  end,
})
