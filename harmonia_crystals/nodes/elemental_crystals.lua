local crystal_sounds = foundation.com.node_sounds:build("crystal")

--local Cuboid = assert(foundation.com.Cuboid)
--local nb = Cuboid.new_fast_node_box

--[[local nodebox = {
  type = "fixed",
  fixed = {
    nb(2, 0, 2, 4, 14, 4),
    nb(4, 0, 4, 4, 10, 4),
    nb(5, 0, 3, 6, 12, 7),
    nb(12, 0, 2, 2, 15, 2),
    nb(10, 0, 7, 3, 15, 3),
    nb(7, 0, 9, 3, 9, 4),
  }
}]]

local nodebox = {
  type = "fixed",
  fixed = {
    {-6/16,-8/16,-6/16,6/16,8/16,6/16}
  }
}

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
  node_box = nodebox,

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

    element = variant_basename,

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
    node_box = nodebox,

    tiles = {
      "harmonia_crystal_" .. variant_basename .. ".top.png",
      "harmonia_crystal_" .. variant_basename .. ".top.png",
      "harmonia_crystal_" .. variant_basename .. ".side.png",
      "harmonia_crystal_" .. variant_basename .. ".side.png",
      "harmonia_crystal_" .. variant_basename .. ".side.png",
      "harmonia_crystal_" .. variant_basename .. ".side.png",
    }
  })
end
