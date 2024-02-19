minetest.register_abm({
  label = "Harmonia World Mana Producer",

  nodenames = {
    "group:harmonia_world_mana_producer",
  },

  interval = 3,
  chance = 1,

  action = function (pos, node)
    local nodedef = minetest.registered_nodes[node.name]
    -- local meta = minetest.get_meta(pos)

    -- local mana = meta:get_float("mana")
    local mana_regen = assert(nodedef.harmonia.mana_regen)

    local block_id = harmonia_world_mana.node_pos_to_block_id(pos)

    harmonia_world_mana.add_mana_in_block(block_id, mana_regen)
  end,
})
