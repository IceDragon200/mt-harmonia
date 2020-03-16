harmonia = rawget(_G, "harmonia") or {}
harmonia.nyctophobia = harmonia.nyctophobia or harmonia_nyctophobia.nyctophobia_system

-- Nyctophobia's default node multiplier
-- Define a node with the has_nyctophobia_multiplier group (doesn't matter what value you set at currently)
-- The node should have a 'nyctophobia' table with a 'multiplier' field.
harmonia.nyctophobia.register_multiplier("harmonia_nyctophobia:node_multiplier", function (player, scale, delta)
  local center_pos = vector.floor(player:get_pos())
  local pos1 = vector.subtract(center_pos, 16)
  local pos2 = vector.add(center_pos, 16)
  local node_positions = minetest.find_nodes_in_area(pos1, pos2, {"group:has_nyctophobia_multiplier"})
  for _, pos in ipairs(node_positions) do
    local node = minetest.get_node_or_nil(pos)
    if node then
      local nodedef = minetest.registered_nodes[node.name]

      if not nodedef.nyctophobia then
        error("expected node=" .. node.name .. " to have nyctophobia table")
      end
      scale = scale * nodedef.nyctophobia.multiplier or 1.0
    end
  end
  return scale
end)
