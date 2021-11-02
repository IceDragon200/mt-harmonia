local mod = harmonia_element

-- A stock blueprint will not have any attached item and is therefore useless.
mod:register_tool("element_blueprint", {
  description = mod.S("Element Blueprint"),

  inventory_image = "element_blueprint.png",
})
