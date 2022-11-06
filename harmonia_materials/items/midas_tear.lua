--
-- Midas' Tear is an alchemical crafting material that coats a material in a
-- film of gold
--
local mod = harmonia_materials

mod:register_craftitem("midas_tear", {
  description = mod.S("Midas' Tear"),

  groups = {
    alchemical = 1,
  },
})
