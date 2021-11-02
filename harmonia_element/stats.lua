-- Register the player's element stat, this is the amount of element stored
nokore.player_stats:register_stat("element", {
  cached = false,

  calc = function (_self, player)
    local meta = player:get_meta()
    return meta:get_int("element")
  end,
})

nokore.player_stats:register_stat("element_regen", {
  cached = true,

  calc = function (_self, player)
    -- TODO: element regen can be affected by other sources as well

    -- the element regen affects how much element is recovered per second
    local meta = player:get_meta()
    return meta:get_int("element_regen")
  end,
})

-- This is the player's maximum available element
nokore.player_stats:register_stat("element_max", {
  cached = true,

  calc = function (_self, player)
    -- TODO: element_max can be affected by other sources as well

    -- the element_max in the meta is a fixed amount that a player
    -- can receive, normally this would be affected by things like armour
    -- or abilities
    local meta = player:get_meta()
    return meta:get_int("element_max")
  end,
})
