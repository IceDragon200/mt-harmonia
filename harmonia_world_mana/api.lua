--- @namespace harmonia_world_mana
local mod = assert(harmonia_world_mana)

local block_data_service = assert(nokore.block_data_service)
local hash_node_position = assert(minetest.hash_node_position)
local hash_position = assert(nokore_block_data.hash_position)

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
