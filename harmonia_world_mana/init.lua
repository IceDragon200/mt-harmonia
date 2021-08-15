--[[

  Harmonia World Mana

  Combined with Harmonia Mana, adds mana related features to world.

]]
local mod = foundation.new_module("harmonia_world_mana", "0.1.0")

--mod:require("mana.lua")

mod:require("api.lua")

assert(nokore.block_data_service, "missing block_data_service, did nokore_block_data load?")
minetest.register_globalstep(function (delta)
  nokore.block_data_service:reduce_blocks(0, function (block_id, block, acc)
    local mana = block.kv:get("mana", 0)
    block.kv:put("mana", mana + 1)
    return acc, false
  end)
end)
