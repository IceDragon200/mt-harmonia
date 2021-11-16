-- @namespace harmonia
harmonia = rawget(_G, "harmonia")

-- Creates a treasure bag given a treasure_list_name, if none is given it will
-- default to "treasure_bag"
--
-- @spec create_treasure_bag_item_stack(treasure_list_name?: String): ItemStack
function harmonia.create_treasure_bag_item_stack(treasure_list_name)
  local item_stack = ItemStack("harmonia_treasure:treasure_bag")
  local meta = item_stack:get_meta()

  meta:set_string("treasure_list_name", treasure_list_name or "treasure_bag")

  return item_stack
end
