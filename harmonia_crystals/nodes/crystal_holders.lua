local crystal_sounds = foundation.com.node_sounds:build("crystal")

local variants = {
  ignis = "Ignis",
  aqua = "Aqua",
  terra = "Terra",
  ventus = "Ventus",
  lux = "Lux",
  umbra = "Umbra",
}

local nodebox = {
  type = "fixed",
  fixed = {
    {-6/16,-8/16,-6/16,6/16,-4/16,6/16},
    {-5/16,-4/16,-5/16,5/16,8/16,5/16},
  }
}

minetest.register_node("harmonia_crystals:crystal_holder_empty", {
  codex_entry_id = "harmonia_totems:crystal_holder_empty",

  description = "Crystal Holder (Empty)",

  groups = {
    oddly_breakable_by_hand = 1,
    crystal_holder = 1,
    empty = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  is_ground_content = true,
  sounds = crystal_sounds,

  sunlight_propagates = true,

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-6/16,-8/16,-6/16,6/16,-4/16,-5/16},
      {-6/16,-8/16, 5/16,6/16,-4/16, 6/16},

      {-6/16,-8/16,-5/16,-5/16,-4/16, 5/16},
      {5/16,-8/16,-5/16,6/16,-4/16, 5/16},
    },
  },

  tiles = {
    "harmonia_crystal_holder_base.top.png",
    "harmonia_crystal_holder_base.bottom.png",
    "harmonia_crystal_holder_base.side.png",
    "harmonia_crystal_holder_base.side.png",
    "harmonia_crystal_holder_base.side.png",
    "harmonia_crystal_holder_base.side.png",
  },
})

for variant_basename, variant_name in pairs(variants) do
  minetest.register_node("harmonia_crystals:crystal_holder_" .. variant_basename, {
    codex_entry_id = "harmonia_totems:crystal_holder",

    base_description = "Crystal Holder",
    basename = "harmonia_crystals:crystal_holder",

    description = "Crystal Holder (" .. variant_name .. ")",

    element = variant_basename,

    groups = {
      oddly_breakable_by_hand = 1,
      crystal_holder = 1,
      ["crystal_holder_"..variant_basename] = 1,
    },

    paramtype = "light",
    paramtype2 = "facedir",

    is_ground_content = true,
    sounds = crystal_sounds,

    sunlight_propagates = false,
    light_source = 12,

    drawtype = "nodebox",
    node_box = nodebox,

    tiles = {
      "harmonia_crystal_holder_" .. variant_basename .. ".top.png^harmonia_crystal_holder_base.top.png",
      "harmonia_crystal_holder_" .. variant_basename .. ".top.png^harmonia_crystal_holder_base.bottom.png",
      "harmonia_crystal_holder_" .. variant_basename .. ".side.png^harmonia_crystal_holder_base.side.png",
      "harmonia_crystal_holder_" .. variant_basename .. ".side.png^harmonia_crystal_holder_base.side.png",
      "harmonia_crystal_holder_" .. variant_basename .. ".side.png^harmonia_crystal_holder_base.side.png",
      "harmonia_crystal_holder_" .. variant_basename .. ".side.png^harmonia_crystal_holder_base.side.png",
    }
  })
end
