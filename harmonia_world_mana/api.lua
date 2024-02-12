--- @namespace harmonia_world_mana
local mod = assert(harmonia_world_mana)

local Vector3 = assert(foundation.com.Vector3)
local Directions = assert(foundation.com.Directions)
local block_data_service = assert(nokore.block_data_service)
local hash_node_position = assert(minetest.hash_node_position)
local hash_position = assert(nokore_block_data.hash_position)
local block_data_service = assert(
  nokore.block_data_service,
  "missing block_data_service, did nokore_block_data load?"
)

--- @spec block_pos_to_block_id(block_pos: Vector3): Integer
function harmonia_world_mana.block_pos_to_block_id(block_pos)
  return hash_node_position(block_pos)
end

--- @spec node_pos_to_block_id(block_pos: Vector3): Integer
function harmonia_world_mana.node_pos_to_block_id(node_pos)
  local x = math.floor(node_pos.x / 16)
  local y = math.floor(node_pos.y / 16)
  local z = math.floor(node_pos.z / 16)

  return hash_position(x, y, z)
end

--- @spec get_mana_in_block(block_id: Integer): Number | nil
function harmonia_world_mana.get_mana_in_block(block_id)
  local block = block_data_service:get_block(block_id)

  if block then
    return block.kv:get("mana", 0)
  end

  return nil
end

--- @spec consume_mana_in_block(block_id: Integer, amount: Number): Number
function harmonia_world_mana.consume_mana_in_block(block_id, amount)
  local block = block_data_service:get_block(block_id)

  if block then
    local mana = block.kv:get("mana", 0)

    local leftover = math.max(mana - amount, 0)

    block.kv:put("mana", leftover)

    return mana - leftover
  end

  return 0
end

--- @spec add_mana_in_block(block_id: Integer, amount: Number): Number
function harmonia_world_mana.add_mana_in_block(block_id, amount)
  local block = block_data_service:get_block(block_id)

  if block then
    local mana = block.kv:get("mana", 0)

    mana = mana + amount

    block.kv:put("mana", mana)

    return amount
  end

  return 0
end

--- @spec get_corrupted_mana_in_block(block_id: Integer): Number | nil
function harmonia_world_mana.get_corrupted_mana_in_block(block_id)
  local block = block_data_service:get_block(block_id)

  if block then
    return block.kv:get("corrupted_mana", 0)
  end

  return nil
end

--- @spec consume_corrupted_mana_in_block(block_id: Integer, amount: Number): Number
function harmonia_world_mana.consume_corrupted_mana_in_block(block_id, amount)
  local block = block_data_service:get_block(block_id)

  if block then
    local mana = block.kv:get("corrupted_mana", 0)

    local leftover = math.max(mana - amount, 0)

    block.kv:put("corrupted_mana", leftover)

    return mana - leftover
  end

  return 0
end

--- @spec add_corrupted_mana_in_block(block_id: Integer, amount: Number): Number
function harmonia_world_mana.add_corrupted_mana_in_block(block_id, amount)
  local block = block_data_service:get_block(block_id)

  if block then
    local mana = block.kv:get("mana", 0)

    mana = mana + amount

    block.kv:put("mana", mana)

    return amount
  end

  return 0
end

--- @local elapsed: Float
local elapsed = 0

function harmonia_world_mana.update_block(delta, blocks, block_id, block, trace)
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
  local overflow_threshold = mod.config.MANA_OVERFLOW_THRESHOLD
  local dir6_to_vec3 = Directions.DIR6_TO_VEC3
  local dir = nil
  local vec3 = nil

  local mana_delta = 10 * delta

  kv = block.kv
  --- Do not do this in your code, the code here is making optimizations here to avoid
  --- the function call overhead
  mana = (kv.data.mana or 0) + mana_delta
  corrupted_mana = kv.data.corrupted_mana or 0

  if mana > overflow_threshold then
    --- The first thing a block will attempt to do is overflow its mana
    --- into other blocks to stabilize itself
    dir = nil
    dir, vec3 = next(dir6_to_vec3, dir)
    while dir do
      pos = Vector3.add(pos, block.pos, vec3)
      block_id = hash_node_position(pos)

      other_block = blocks[block_id]

      if other_block then
        other_kv = other_block.kv
        other_mana = other_kv.data["mana"] or 0

        -- we can overflow mana unless the target block has less mana
        -- than the donor
        if other_mana < mana then
          -- calculate the difference (and offset by 1)
          diff = mana - other_mana - 1
          if diff > 0 then
            -- add the excess mana to the other block
            other_kv.data.mana = other_mana + diff
            other_kv:mark_dirty()
            -- and remove it from donor block
            mana = mana - diff
          end
        end
      end

      if mana <= overflow_threshold then
        break
      end
      dir, vec3 = next(dir6_to_vec3, dir)
    end
  end

  if mana > overflow_threshold then
    --
    excess_mana = mana - overflow_threshold
    corrupted_mana = corrupted_mana + excess_mana
    mana = mana - excess_mana
  end

  kv.data.mana = mana
  kv.data.corrupted_mana = corrupted_mana
  kv:mark_dirty()
end

local STEP_INTERVAL = 1 / 20 -- 50ms

--- @spec update(delta: Float, trace: foundation.com.Trace): void
function harmonia_world_mana.update(delta, trace)
  elapsed = elapsed + delta

  if elapsed > STEP_INTERVAL then
    elapsed = elapsed - STEP_INTERVAL

    local span

    -- this is an optimization specifically for harmonia, you should not assume
    -- that the block service's internal structure will remain the same.
    local blocks = block_data_service.blocks

    for block_id,block in pairs(blocks) do
      -- if trace then
      --   span = trace:span_start("block:" .. block_id)
      -- end
      harmonia_world_mana.update_block(0.1, blocks, block_id, block, span)
      -- if span then
      --   span:span_end()
      -- end
      -- span = nil
    end
  end
end
