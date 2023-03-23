--
-- Owl Pillar
--
local Cuboid = assert(foundation.com.Cuboid)
local nb = Cuboid.new_fast_node_box

minetest.register_node("harmonia_totems:owl_pillar", {
  codex_entry_id = "harmonia_totems:animal_pillar",

  description = "Owl Pillar",

  groups = {
    cracky = nokore.dig_class("copper"),
    --
    animal_totem = 1,
    has_nyctophobia_multiplier = 1,
  },

  use_texture_alpha = "clip",
  tiles = {
    "harmonia_animal_pillars_owl.top.png",
    "harmonia_animal_pillars_owl.bottom.png",
    "harmonia_animal_pillars_owl.side.png",
    "harmonia_animal_pillars_owl.side.png",
    "harmonia_animal_pillars_owl.side.png",
    "harmonia_animal_pillars_owl.side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      nb(3, 0, 3, 10, 12, 10),
      -- base ears
      nb(3, 12, 3, 3, 1, 3),
      nb(10, 12, 3, 3, 1, 3),
      nb(3, 12, 10, 3, 1, 3),
      nb(10, 12, 10, 3, 1, 3),

      nb( 3, 13, 3, 2, 1, 2),
      nb(11, 13, 3, 2, 1, 2),
      nb( 3, 13, 11, 2, 1, 2),
      nb(11, 13, 11, 2, 1, 2),
    }
  },

  selection_box = {
    type = "fixed",
    fixed = {
      nb(3, 0, 3, 10, 14, 10),
    }
  },

  nyctophobia = {
    multiplier = 0.9,
  },
})
