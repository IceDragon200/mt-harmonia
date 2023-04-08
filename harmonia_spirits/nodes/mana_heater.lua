local mod = assert(harmonia_spirits)

local cluster_thermal = yatm.cluster.thermal

if not cluster_thermal then
  minetest.log("warning", "cluster thermal not available skipping mana heater")
  return
end

local ItemInterface = assert(yatm.items.ItemInterface)
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

local function on_metadata_inventory_take(pos, listname, index, item_stack, _player)
  local node = minetest.get_node_or_nil(pos)
end

local function on_metadata_inventory_put(pos, _listname, _index, _item_stack, _player)
  local node = minetest.get_node_or_nil(pos)
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
  item_interface_in = 1,
  item_interface_out = 1,
  heater_device = 1,
  yatm_cluster_thermal = 1,
  mana_heater = 1,
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
  thermal_interface = assert(thermal_interface),

  on_construct = on_construct,
  on_rightclick = on_rightclick,

  on_metadata_inventory_take = on_metadata_inventory_take,
  on_metadata_inventory_put = on_metadata_inventory_put,
}, {
  off = {
    description = mod.S("Mana Heater [OFF]"),

    tiles = {
      "yatm_solid_fuel_heater_top.off.png",
      "yatm_solid_fuel_heater_bottom.off.png",
      "yatm_solid_fuel_heater_side.off.png",
      "yatm_solid_fuel_heater_side.off.png^[transformFX",
      "yatm_solid_fuel_heater_side.off.png",
      "yatm_solid_fuel_heater_front.off.png"
    },
  },

  heating = {
    description = mod.S("Mana Heater [Heating]"),

    tiles = {
      "yatm_solid_fuel_heater_top.heating.png",
      "yatm_solid_fuel_heater_bottom.heating.png",
      "yatm_solid_fuel_heater_side.heating.png",
      "yatm_solid_fuel_heater_side.heating.png^[transformFX",
      "yatm_solid_fuel_heater_side.heating.png",
      "yatm_solid_fuel_heater_front.heating.png"
    },
  },

  cooling = {
    description = mod.S("Mana Heater [Cooling]"),

    tiles = {
      "yatm_solid_fuel_heater_top.cooling.png",
      "yatm_solid_fuel_heater_bottom.cooling.png",
      "yatm_solid_fuel_heater_side.cooling.png",
      "yatm_solid_fuel_heater_side.cooling.png^[transformFX",
      "yatm_solid_fuel_heater_side.cooling.png",
      "yatm_solid_fuel_heater_front.cooling.png"
    },
  },
})
