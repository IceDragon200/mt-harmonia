local mod = assert(harmonia_spirits)

mod:register_craftitem("infused_coal_lump_ignis", {
  description = mod.S("Infused Coal Lump [Ignis]"),

  groups = {
    coal = 1,
    solid_fuel = 1,
  },

  inventory_image = "harmonia_infused_coal_lump.ignis.png",
})
