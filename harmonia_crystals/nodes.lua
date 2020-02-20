local crystal_sounds = default.node_sound_glass_defaults()

minetest.register_node("harmonia_crystals:rooted_crystal_common", {
  codex_entry_id = "harmonia_totems:rooted_crystal",

  base_description = "Rooted Crystal",
  basename = "harmonia_crystals:rooted_crystal",

  description = "Common Crystal",

  groups = {
    oddly_breakable_by_hand = 1,
    crystal = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  is_ground_content = true,
  sounds = crystal_sounds,

  sunlight_propagates = false,
  light_source = 8,

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      yatm_core.Cuboid:new(2, 0, 2, 4, 14, 4):fast_node_box(),
      yatm_core.Cuboid:new(4, 0, 4, 4, 10, 4):fast_node_box(),
      yatm_core.Cuboid:new(5, 0, 3, 6, 12, 7):fast_node_box(),
      yatm_core.Cuboid:new(12, 0, 2, 2, 15, 2):fast_node_box(),
      yatm_core.Cuboid:new(10, 0, 7, 3, 15, 3):fast_node_box(),
      yatm_core.Cuboid:new(7, 0, 9, 3, 9, 4):fast_node_box(),
    }
  },

  tiles = {
    "harmonia_crystal_top.png",
    "harmonia_crystal_top.png",
    "harmonia_crystal_base.png",
    "harmonia_crystal_base.png",
    "harmonia_crystal_base.png",
    "harmonia_crystal_base.png",
  }
})

local variants = {
  ignis = "Ignis",
  aqua = "Aqua",
  terra = "Terra",
  ventus = "Ventus",
  lux = "Lux",
  umbra = "Umbra",
}

for variant_basename, variant_name in pairs(variants) do
  minetest.register_node("harmonia_crystals:rooted_crystal_" .. variant_basename, {
    codex_entry_id = "harmonia_totems:rooted_crystal",

    base_description = "Rooted Crystal",
    basename = "harmonia_crystals:rooted_crystal",

    description = variant_name .. " Crystal",

    groups = {
      oddly_breakable_by_hand = 1,
      crystal = 1,
    },

    paramtype = "light",
    paramtype2 = "facedir",

    is_ground_content = true,
    sounds = crystal_sounds,

    sunlight_propagates = false,
    light_source = 8,

    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = {
        yatm_core.Cuboid:new(2, 0, 2, 4, 14, 4):fast_node_box(),
        yatm_core.Cuboid:new(4, 0, 4, 4, 10, 4):fast_node_box(),
        yatm_core.Cuboid:new(5, 0, 3, 6, 12, 7):fast_node_box(),
        yatm_core.Cuboid:new(12, 0, 2, 2, 15, 2):fast_node_box(),
        yatm_core.Cuboid:new(10, 0, 7, 3, 15, 3):fast_node_box(),
        yatm_core.Cuboid:new(7, 0, 9, 3, 9, 4):fast_node_box(),
      }
    },

    tiles = {
      "harmonia_crystal_" .. variant_basename .. ".top.png",
      "harmonia_crystal_" .. variant_basename .. ".side.png",
      "harmonia_crystal_" .. variant_basename .. ".side.png",
      "harmonia_crystal_" .. variant_basename .. ".side.png",
      "harmonia_crystal_" .. variant_basename .. ".side.png",
      "harmonia_crystal_" .. variant_basename .. ".side.png",
    }
  })
end
