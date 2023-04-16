local mod = assert(harmonia_spirits)

local ATTRIBUTES = {
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

for _i, entry in ipairs(ATTRIBUTES) do
  mod:register_craftitem("spirit_" .. entry.basename, {
    description = mod.S(entry.description .. " Spirit"),

    inventory_image = "harmonia_spirits_" .. entry.basename .. ".png",

    harmonia = {
      attribute = entry.basename,
    },

    -- Spirits are always unique
    stack_max = 1,

    groups = {
      harmonia_spirit = 1,
      ["harmonia_spirit_" .. entry.basename] = 1,
    },
  })
end
