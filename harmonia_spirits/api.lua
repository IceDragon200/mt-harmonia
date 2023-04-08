local mod = assert(harmonia_spirits)

-- TODO: just leaving these as is, this really should be exposed through
-- a proper interface, but for now, to get a MVP, raw values!
mod.weighted_corrupted_spirits = foundation.com.WeightedList:new()
mod.weighted_spirits = foundation.com.WeightedList:new()

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
