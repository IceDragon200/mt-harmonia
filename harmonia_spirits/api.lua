local mod = assert(harmonia_spirits)

local Groups = assert(foundation.com.Groups)

--- @namespace harmonia_spirits

-- TODO: just leaving these as is, this really should be exposed through
-- a proper interface, but for now, to get a MVP, raw values!
mod.weighted_corrupted_spirits = foundation.com.WeightedList:new()
mod.weighted_spirits = foundation.com.WeightedList:new()

--- Determines if the given item is a spirit.
---
--- @spec is_item_spirit(ItemStack): Boolean
function mod.is_item_spirit(item_stack)
  if item_stack and not item_stack:is_empty() then
    local itemdef = item_stack:get_definition()

    return Groups.has_group(itemdef, "harmonia_spirit")
  end

  return false
end

--- Retrieves item's primary harmonia.element, note that some items may represent multiple elements
---
--- @spec get_item_primary_element(ItemStack): String | nil
function mod.get_item_primary_element(item_stack)
  if item_stack and not item_stack:is_empty() then
    local itemdef = item_stack:get_definition()

    if itemdef and itemdef.harmonia then
      return itemdef.harmonia.element
    end
  end

  return nil
end

--
-- ABM for any node that consumes mana from the world
--
minetest.register_abm({
  label = "Harmonia World Mana Consumer",

  nodenames = {
    "group:harmonia_world_mana_consumer",
  },

  interval = 3,
  chance = 1,

  action = function (pos, node)
    local meta = minetest.get_meta(pos)
    local nodedef = minetest.registered_nodes[node.name]

    local mana = meta:get_float("mana")
    local corrupted_mana = meta:get_float("corrupted_mana")

    local max_mana = assert(nodedef.harmonia.max_mana)

    local available_mana = mana + corrupted_mana

    local block_id = harmonia_world_mana.node_pos_to_block_id(pos)

    if available_mana < max_mana then
      local mana_requestable = math.min(max_mana - available_mana, 50)
      local consumed = harmonia_world_mana.consume_corrupted_mana_in_block(
        block_id,
        mana_requestable
      )

      if consumed > 0 then
        corrupted_mana = corrupted_mana + consumed

        available_mana = mana + corrupted_mana
      end
    end

    if available_mana < max_mana then
      local mana_requestable = math.min(max_mana - available_mana, 50)
      local consumed = harmonia_world_mana.consume_mana_in_block(
        block_id,
        mana_requestable
      )

      if consumed > 0 then
        mana = mana + consumed

        available_mana = mana + corrupted_mana
      end
    end

    meta:set_float("mana", mana)
    meta:set_float("corrupted_mana", corrupted_mana)
  end,
})
