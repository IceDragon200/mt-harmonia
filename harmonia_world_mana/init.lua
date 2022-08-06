--[[

  Harmonia World Mana

  Combined with Harmonia Mana, adds mana related features to world.

]]
local mod = foundation.new_module("harmonia_world_mana", "0.1.0")

--mod:require("mana.lua")

mod:require("api.lua")

local block_data_service = assert(nokore.block_data_service, "missing block_data_service, did nokore_block_data load?")
--local reduce_blocks = assert(block_data_service.reduce_blocks)

local elapsed = 0

nokore_proxy.register_globalstep("hamornia_world_mana.update/1", function (delta)
  elapsed = elapsed + delta

  if elapsed > 1 do
    elapsed = elapsed - 1

    local mana
    local kv
    --reduce_blocks(block_data_service, 0, function (block_id, block, acc)
    -- this is an optimization specifically for harmonia, you should not assume
    -- that the block service's internal structure will remain the same.
    for _id,block in pairs(block_data_service.blocks) do
      kv = block.kv
      mana = kv:get("mana", 0)
      kv:put("mana", mana + 1)
      --return acc, false
    end
    --end)
  end
end)
