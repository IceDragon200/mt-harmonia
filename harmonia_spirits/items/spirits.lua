local mod = assert(harmonia_spirits)

local ATTRS = {
  {
    basename = "corrupted",
    description = "Corrupted",
  },
  {
    basename = "ignis",
    description = "Ignis",
  },
  {
    basename = "aqua",
    description = "Aqua",
  },
  {
    basename = "terra",
    description = "Terra",
  },
  {
    basename = "ventus",
    description = "Ventus",
  },
  {
    basename = "lux",
    description = "Lux",
  },
  {
    basename = "umbra",
    description = "Umbra",
  },
}

for _i, entry in ipairs(ATTRS) do
  mod:register_craftitem("spirit_" .. entry.basename, {
    description = mod.S(entry.description .. " Spirit"),

    inventory_image = "harmonia_spirits_" .. entry.basename .. ".png",

    harmonia = {
      element = entry.basename,
    },

    -- Spirits are always unique
    stack_max = 1,

    groups = {
      spirit = 1,
      ["spirit_" .. entry.basename] = 1,
    },
  })
end
