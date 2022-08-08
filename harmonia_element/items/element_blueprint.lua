local mod = harmonia_element

-- A stock blueprint will not have any attached item and is therefore useless.
mod:register_tool("element_blueprint_blank", {
  description = mod.S("Element Blueprint (Blank)"),

  inventory_image = "harmonia_element_blueprint.blank.png",
})

mod:register_tool("element_blueprint", {
  description = mod.S("Element Blueprint"),

  inventory_image = "harmonia_element_blueprint.png",
})

mod:register_tool("element_blueprint_unidentified", {
  description = mod.S("Element Blueprint (Unidentified)"),

  inventory_image = "harmonia_element_blueprint.unidentified.png",
})
