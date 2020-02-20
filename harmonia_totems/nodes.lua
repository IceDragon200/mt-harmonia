minetest.register_node("harmonia_totems:dog_pillar", {
  description = "Dog Pillar",

  groups = {
    cracky = 1,
    animal_totem = 1,
  },

  tiles = {
    "harmonia_animal_pillars_dog.bottom.png",
    "harmonia_animal_pillars_dog.top.png",
    "harmonia_animal_pillars_dog.side.png",
    "harmonia_animal_pillars_dog.side.png",
    "harmonia_animal_pillars_dog.side.png",
    "harmonia_animal_pillars_dog.side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      yatm_core.Cuboid:new(3, 0, 3, 10, 12, 10):fast_node_box(),
      -- base ears
      yatm_core.Cuboid:new(3, 12, 3, 3, 1, 3):fast_node_box(),
      yatm_core.Cuboid:new(10, 12, 3, 3, 1, 3):fast_node_box(),
      yatm_core.Cuboid:new(3, 12, 10, 3, 1, 3):fast_node_box(),
      yatm_core.Cuboid:new(10, 12, 10, 3, 1, 3):fast_node_box(),

      yatm_core.Cuboid:new( 3, 13, 3, 2, 1, 2):fast_node_box(),
      yatm_core.Cuboid:new(11, 13, 3, 2, 1, 2):fast_node_box(),
      yatm_core.Cuboid:new( 3, 13, 11, 2, 1, 2):fast_node_box(),
      yatm_core.Cuboid:new(11, 13, 11, 2, 1, 2):fast_node_box(),
    }
  },

  selection_box = {
    type = "fixed",
    fixed = {
      yatm_core.Cuboid:new(3, 0, 3, 10, 14, 10):fast_node_box()
    }
  }
})
