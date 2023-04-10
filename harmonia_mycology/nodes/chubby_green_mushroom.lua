--
-- Chubby Green Mushrooms
--
--   Chubby green mushrooms are natural mana generators and purifiers
local mod = assert(harmonia_mycology)

local Cuboid = assert(foundation.com.Cuboid)
local ng = assert(Cuboid.new_fast_node_box)

mod:register_node("chubby_mushroom_large", {
  description = mod.S("Large Chubby Green Mushroom"),

  groups = {
    oddly_breakable_by_hand = nokore.dig_class("hand"),
    harmonia_world_mana_producer = 1,
  },

  harmonia = {
    mana_regen = 3,
  },

  paramtype = "none",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(7, 0, 7, 2, 6, 2),
      -- ng(6, 0, 6, 4, 2, 4),
      -- ng(7, 2, 7, 2, 4, 2),
      ng(6, 6, 6, 4, 1, 4),
      ng(1, 7, 1, 14, 7, 14),
    }
  },

  use_texture_alpha = "clip",
  tiles = {
    "harmonia_chubby_green_mushroom_top.png",
    "harmonia_chubby_green_mushroom_bottom.png",
    "harmonia_chubby_green_mushroom_side.png",
    "harmonia_chubby_green_mushroom_side.png",
    "harmonia_chubby_green_mushroom_side.png",
    "harmonia_chubby_green_mushroom_side.png",
  },
})
