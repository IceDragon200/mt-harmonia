--[[

  Harmonia World Mana

  Combined with Harmonia Mana, adds mana related features to world.

]]
local mod = foundation.new_module("harmonia_world_mana", "0.2.0")

local Vector3 = assert(foundation.com.Vector3)
local Directions = assert(foundation.com.Directions)

local hash_node_position = assert(minetest.hash_node_position)

--mod:require("mana.lua")

mod:require("config.lua")
mod:require("api.lua")

local block_data_service = assert(
  nokore.block_data_service,
  "missing block_data_service, did nokore_block_data load?"
)
--local reduce_blocks = assert(block_data_service.reduce_blocks)

local elapsed = 0

nokore_proxy.register_globalstep("hamornia_world_mana:update_blocks/1", function (delta)
  elapsed = elapsed + delta

  while elapsed > 0.1 do
    elapsed = elapsed - 0.1

    local mana
    local corrupted_mana
    local excess_mana
    local kv
    local block_id
    local pos = Vector3.new(0, 0, 0)
    local other_block
    local other_kv
    local other_mana
    local diff

    -- this is an optimization specifically for harmonia, you should not assume
    -- that the block service's internal structure will remain the same.
    local blocks = block_data_service.blocks
    for _id,block in pairs(blocks) do
      kv = block.kv
      mana = kv:get("mana", 0)
      mana = mana + 1
      corrupted_mana = kv:get("corrupted_mana", 0)

      if mana > mod.config.MANA_OVERFLOW_THRESHOLD then
        --- The first thing a block will attempt to do is overflow its mana
        --- into other blocks to stabilize itself
        for _dir, vec3 in pairs(Directions.DIR6_TO_VEC3) do
          pos = Vector3.add(pos, block.pos, vec3)
          block_id = hash_node_position(pos)

          other_block = blocks[block_id]

          if other_block then
            other_kv = other_block.kv
            other_mana = other_kv:get("mana", 0)

            -- we can overflow mana unless the target block has less mana
            -- than the donor
            if other_mana < mana then
              -- calculate the difference (and offset by 1)
              diff = mana - other_mana - 1
              if diff > 0 then
                -- add the excess mana to the other block
                other_kv:increment("mana", diff)
                -- and remove it from donor block
                mana = mana - diff
              end
            end
          end

          if mana <= mod.config.MANA_OVERFLOW_THRESHOLD then
            break
          end
        end
      end

      if mana > mod.config.MANA_CORRUPTION_THRESHOLD then
        --
        excess_mana = mana - mod.config.MANA_CORRUPTION_THRESHOLD
        corrupted_mana = corrupted_mana + excess_mana
        mana = mana - excess_mana
      end

      kv:put("mana", mana)
      kv:put("corrupted_mana", corrupted_mana)
    end
  end
end)
