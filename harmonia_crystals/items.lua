--
-- Crystals
--
minetest.register_craftitem("harmonia_crystals:crystal_carbon_steel", {
  basename = "harmonia_crystals:crystal",
  base_description = "Crystal",

  description = "Pure Crystal (Carbon Steel)",
  inventory_image = "harmonia_element_crystal.carbon_steel.png",

  groups = {
    crystal = 1,
    crystal_carbon_steel = 1
  },

  material_name = "crystal_carbon_steel",
})

local variants = {
  common = "Common",
  ignis = "Ignis",
  aqua = "Aqua",
  terra = "Terra",
  ventus = "Ventus",
  lux = "Lux",
  umbra = "Umbra",
}

for variant_basename,variant_description in pairs(variants) do
  minetest.register_craftitem("harmonia_crystals:crystal_shard_"..variant_basename, {
    basename = "harmonia_crystals:crystal_shard",
    base_description = "Crystal Shard",

    description = "Crystal Shard ["..variant_description.."]",
    inventory_image = "harmonia_crystal_shards_"..variant_basename..".png",

    groups = {
      crystal = 1,
      ["crystal_"..variant_basename] = 1
    },

    harmonia = {
      attribute = variant_basename,
    },
  })

  minetest.register_craftitem("harmonia_crystals:crystal_"..variant_basename, {
    basename = "harmonia_crystals:crystal",
    base_description = "Pure Crystal",

    description = "Pure Crystal ["..variant_description.."]",
    inventory_image = "harmonia_element_crystal."..variant_basename..".png",

    groups = {
      crystal = 1,
      ["crystal_"..variant_basename] = 1
    },

    harmonia = {
      attribute = variant_basename,
    },
  })
end
