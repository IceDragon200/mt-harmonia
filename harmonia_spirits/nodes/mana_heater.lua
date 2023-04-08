local mod = assert(harmonia_spirits)

local cluster_thermal = yatm.cluster.thermal

if not cluster_thermal then
  minetest.log("warning", "cluster thermal not available skipping mana heater")
  return
end

local ItemInterface = assert(yatm.items.ItemInterface)
local player_service = assert(nokore.player_service)
local maybe_start_node_timer = assert(foundation.com.maybe_start_node_timer)
local fspec = assert(foundation.com.formspec.api)
local Groups = assert(foundation.com.Groups)
local table_merge = assert(foundation.com.table_merge)

-- The maximum amount of mana that can be contained.
-- (note this is shared between corrupted and clean mana)
local MAX_MANA = 200

local function render_formspec(pos, player, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local cio = fspec.calc_inventory_offset
  local meta = minetest.get_meta(pos)

  local mana = meta:get_float("mana")
  local corrupted_mana = meta:get_float("corrupted_mana")

  local nodedef = minetest.registered_nodes[state.node.name]
  local max_mana = nodedef.harmonia.max_mana

  local formspec = yatm.formspec_render_split_inv_panel(player, 4, 4, { bg = "default" }, function (loc, rect)
    if loc == "main_body" then
      return fspec.list("nodemeta:" .. spos, "spirits", rect.x, rect.y, 1, 1) ..
        -- Mana
        harmonia.formspec.render_mana_gauge{
          x = rect.x + cio(2),
          y = rect.y,
          w = 1,
          h = rect.h,
          amount = mana,
          max = max_mana,
        } ..
        -- Corrupted Mana
        harmonia.formspec.render_corrupted_mana_gauge{
          x = rect.x + cio(3),
          y = rect.y,
          w = 1,
          h = rect.h,
          amount = corrupted_mana,
          max = max_mana,
        }
    elseif loc == "footer" then
      return fspec.list_ring()
    end
    return ""
  end)

  return formspec
end

local function on_construct(pos)
  local node = minetest.get_node_or_nil(pos)
  local meta = minetest.get_meta(pos)
  meta:get_float("mana", 0)
  meta:get_float("corrupted_mana", 0)

  local inv = meta:get_inventory()
  inv:set_size("spirits", 1)

  cluster_thermal:schedule_add_node(pos, node)
end

local function after_destruct(pos, old_node)
  cluster_thermal:schedule_remove_node(pos, old_node)
end

local function on_refresh_timer(player_name, form_name, state)
  local player = player_service:get_player_by_name(player_name)
  local meta = minetest.get_meta(state.pos)
  state.time = meta:get_float("time")

  return {
    {
      type = "refresh_formspec",
      value = render_formspec(state.pos, player, state),
    }
  }
end

local function on_rightclick(pos, node, player)
  local state = {
    pos = pos,
    node = node,
  }

  local options = {
    state = state,
    timers = {
      -- routinely update the formspec
      refresh = {
        every = 1,
        action = on_refresh_timer,
      },
    },
  }

  nokore.formspec_bindings:show_formspec(
    player:get_player_name(),
    mod:make_name("mana_heater"),
    render_formspec(pos, player, state),
    options
  )
end

--- @spec maybe_swap_node(pos: Vector3, node: NodeRef, new_name: String): void
local function maybe_swap_node(pos, node, new_name)
  if node.name ~= new_name then
    local new_node = {
      name = new_name,
      param1 = node.param1,
      param2 = node.param2,
    }

    minetest.swap_node(pos, new_node)
  end
end

--- @spec on_timer(pos: Vector3, dt: Float): Boolean
local function on_timer(pos, dt)
  local node = minetest.get_node_or_nil(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local stack = inv:get_stack("spirits", 1)
  local heat = meta:get_float("heat") or 0
  local mana = meta:get_float("mana")
  local corrupted_mana = meta:get_float("corrupted_mana")

  local available_mana = mana + corrupted_mana
  local mana_used = 0
  local nodedef = minetest.registered_nodes[node.name]
  local max_mana = nodedef.harmonia.max_mana

  local should_loop = true

  if mod.is_item_spirit(stack) then
    -- We have a spirit!
    local element = mod.get_item_primary_element(stack)

    --- 5 mana per second is consumed generally
    local mana_consumable = math.min(available_mana, dt * 5)

    if element == "ignis" then
      -- Ignis spirits consume mana to produce a heating effect

      --- heat generated is equal to the amount of mana consumable
      local heat_generated = mana_consumable
      heat = math.min(heat + heat_generated, 3600)
      mana_used = mana_used + mana_consumable
    elseif element == "aqua" then
      -- Aqua spirits consume mana to produce a cooling effect

      -- cooling works in the reverse, it attempts to drop the heat to a
      -- negative value
      local heat_degenerated = mana_consumable

      heat = math.max(heat - heat_degenerated, -3600)
      mana_used = mana_used + mana_consumable
    else
      -- Other spirits do nothing currently
    end

    if mana_used > 0 then
      local leftover
      leftover = math.max(corrupted_mana - mana_used, 0)
      mana_used = mana_used - corrupted_mana - leftover
      meta:set_float("corrupted_mana", corrupted_mana)
    end

    if mana_used > 0 then
      local leftover = math.max(mana - mana_used, 0)
      mana_used = mana_used - mana - leftover
      meta:set_float("mana", mana)
    end

    -- always loop as long as there is a spirit
    should_loop = true
  else
    -- if there is no spirit, then the heat should gradually drift back to zero

    local heat_drift = dt * 3

    if heat < 0 then
      -- cooled currently, we need to return to nat-zero by increasing the heat
      heat = math.min(heat + heat_drift, 0)
    elseif heat > 0 then
      -- currently heated, we need to decrease the heat to return to nat-zero
      heat = math.max(heat - heat_drift, 0)
    end
  end

  if heat < 0 then
    maybe_swap_node(pos, node, "harmonia_spirits:mana_heater_cooling")
  elseif heat > 0 then
    maybe_swap_node(pos, node, "harmonia_spirits:mana_heater_heating")
  else
    maybe_swap_node(pos, node, "harmonia_spirits:mana_heater_off")
  end

  meta:set_float("heat", heat)

  yatm.queue_refresh_infotext(pos, node)

  -- if there is still heat available, we need to continue this loop until it doesn't.
  -- Of if the should_loop has been explictly set
  return heat ~= 0 or should_loop
end

local function maybe_run_timer(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local stack = inv:get_stack("spirits", 1)

  if mod.is_item_spirit(stack) then
    maybe_start_node_timer(pos, 1.0)
  end
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
  if listname == "spirits" then
    if mod.is_item_spirit(stack) then
      return 1
    end
    return false
  end

  return stack:get_count()
end

local function allow_metadata_inventory_take(pos, _listname, _index, stack, player)
  return stack:get_count()
end

local function on_metadata_inventory_take(pos, listname, _index, _item_stack, _player)
  local node = minetest.get_node_or_nil(pos)

  if listname == "spirits" then
    maybe_run_timer(pos)
  end
end

local function on_metadata_inventory_put(pos, listname, _index, _item_stack, _player)
  local node = minetest.get_node_or_nil(pos)

  if listname == "spirits" then
    maybe_run_timer(pos)
  end
end

--- @spec refresh_infotext(Vector3): void
local function refresh_infotext(pos)
  local node = minetest.get_node_or_nil(pos)
  if node then
    local nodedef = minetest.registered_nodes[node.name]
    local meta = minetest.get_meta(pos)

    local mana = meta:get_float("mana")
    local mana_max = nodedef.harmonia.max_mana

    local heat = math.floor(meta:get_float("heat"))
    local heat_max = 3600
    if heat < 0 then
      -- TODO: this should likely change based on the predicted trajectory rather
      -- than the current heat
      heat_max = -heat_max
    end

    meta:set_string("infotext",
      cluster_thermal:get_node_infotext(pos) .. "\n" ..
      "Heat: " .. heat .. " / " .. heat_max .. "\n" ..
      "Mana: " .. mana .. " / " .. mana_max
    )
  end
end

local item_interface = ItemInterface.new_simple("spirits")

--- @spec #on_insert_item(Vector3, dir: Direction, item_stack: ItemStack): void
function item_interface:on_insert_item(pos, dir, item_stack)
  maybe_run_timer(pos)
end

--- @spec #allow_insert_item(Vector3, dir: Direction, item_stack: ItemStack): Boolean
function item_interface:allow_insert_item(pos, dir, item_stack)
  if mod.is_item_spirit(item_stack) then
    return true
  else
    return false, "item is not a spirit"
  end
end

local thermal_interface = {
  groups = {
    heater = 1,
    thermal_producer = 1,
  },

  get_heat = function (self, pos, node)
    local meta = minetest.get_meta(pos)
    return meta:get_float("heat")
  end,
}

local node_box = {
  type = "fixed",
  fixed = {
    {-0.5, (4 / 16) - 0.5, -0.5, 0.5, 0.5, 0.5},
    {(1 / 16) - 0.5, -0.5, (1 / 16) -0.5, (15 / 16) - 0.5, (4 / 16) - 0.5, (15 / 16) - 0.5},
  }
}

local base_groups = {
  cracky = nokore.dig_class("copper"),
  -- item interface
  item_interface_in = 1,
  item_interface_out = 1,
  heater_device = 1,
  -- to join thermal cluster
  yatm_cluster_thermal = 1,
  mana_heater = 1,
  harmonia_world_mana_consumer = 1,
}

yatm.register_stateful_node(mod:make_name("mana_heater"), {
  basename = mod:make_name("mana_heater"),
  base_description = mod.S("Mana Heater"),

  groups = table_merge(base_groups, {}),

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "none",
  paramtype2 = "facedir",

  is_ground_content = false,

  harmonia = {
    max_mana = MAX_MANA,
  },
  item_interface = assert(item_interface),
  thermal_interface = assert(thermal_interface),

  on_construct = assert(on_construct),
  after_destruct = assert(after_destruct),
  on_rightclick = assert(on_rightclick),
  on_timer = assert(on_timer),

  refresh_infotext = refresh_infotext,

  allow_metadata_inventory_put = assert(allow_metadata_inventory_put),
  allow_metadata_inventory_take = assert(allow_metadata_inventory_take),

  on_metadata_inventory_take = assert(on_metadata_inventory_take),
  on_metadata_inventory_put = assert(on_metadata_inventory_put),
}, {
  off = {
    description = mod.S("Mana Heater [OFF]"),

    tiles = {
      "harmonia_mana_heater_top.off.png",
      "harmonia_mana_heater_bottom.off.png",
      "harmonia_mana_heater_side.off.png",
      "harmonia_mana_heater_side.off.png^[transformFX",
      "harmonia_mana_heater_side.off.png",
      "harmonia_mana_heater_front.off.png"
    },
  },

  heating = {
    description = mod.S("Mana Heater [Heating]"),

    tiles = {
      "harmonia_mana_heater_top.heating.png",
      "harmonia_mana_heater_bottom.heating.png",
      "harmonia_mana_heater_side.heating.png",
      "harmonia_mana_heater_side.heating.png^[transformFX",
      "harmonia_mana_heater_side.heating.png",
      "harmonia_mana_heater_front.heating.png"
    },
  },

  cooling = {
    description = mod.S("Mana Heater [Cooling]"),

    tiles = {
      "harmonia_mana_heater_top.cooling.png",
      "harmonia_mana_heater_bottom.cooling.png",
      "harmonia_mana_heater_side.cooling.png",
      "harmonia_mana_heater_side.cooling.png^[transformFX",
      "harmonia_mana_heater_side.cooling.png",
      "harmonia_mana_heater_front.cooling.png"
    },
  },
})
