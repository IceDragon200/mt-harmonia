--
-- Spirit Lanterns are used to attract spirits by consuming mana in the block
-- Lanterns will always consume corrupted mana first and then any clean mana if available.
--
local mod = assert(harmonia_spirits)

local fspec = assert(foundation.com.formspec.api)
local Groups = assert(foundation.com.Groups)
local Cuboid = assert(foundation.com.Cuboid)
local table_merge = assert(foundation.com.table_merge)

local player_service = assert(nokore.player_service)
local nb = assert(Cuboid.new_fast_node_box)

-- The minimum required mana to lure a spirit
local MINIMUM_MANA_FOR_LURE = 100
-- The maximum amount of mana that can be contained.
-- (note this is shared between corrupted and clean mana)
local MAX_MANA = 300

local ELEMENT_TO_LANTERN = {
  corrupted = mod:make_name("spirit_lantern_core_corrupted"),
  ignis = mod:make_name("spirit_lantern_core_ignis"),
  aqua = mod:make_name("spirit_lantern_core_aqua"),
  terra = mod:make_name("spirit_lantern_core_terra"),
  ventus = mod:make_name("spirit_lantern_core_ventus"),
  lux = mod:make_name("spirit_lantern_core_lux"),
  umbra = mod:make_name("spirit_lantern_core_umbra"),
}

local ATTRS = {
  {
    basename = "default",
    description = "Default",
    light_source = 7,
  },
  {
    basename = "corrupted",
    description = "Corrupted",
    light_source = 3,
  },
  {
    basename = "ignis",
    description = "Ignis",
    light_source = 10,
  },
  {
    basename = "aqua",
    description = "Aqua",
    light_source = 5,
  },
  {
    basename = "terra",
    description = "Terra",
    light_source = 5,
  },
  {
    basename = "ventus",
    description = "Ventus",
    light_source = 5,
  },
  {
    basename = "lux",
    description = "Lux",
    light_source = 12,
  },
  {
    basename = "umbra",
    description = "Umbra",
    light_source = 5,
  },
}

local function on_construct(pos)
  local meta = minetest.get_meta(pos)

  meta:set_int("mana", 0)
  meta:set_int("corrupted_mana", 0)

  local inv = meta:get_inventory()

  inv:set_size("main", 1)
end

local function render_formspec(pos, player, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local cio = fspec.calc_inventory_offset
  local meta = minetest.get_meta(pos)

  local mana = meta:get_float("mana")
  local corrupted_mana = meta:get_float("corrupted_mana")
  local nodedef = minetest.registered_nodes[state.node.name]
  local max_mana = assert(nodedef.harmonia.max_mana)

  local formspec = yatm.formspec_render_split_inv_panel(player, 4, 4, { bg = "default" }, function (loc, rect)
    if loc == "main_body" then
      return fspec.list("nodemeta:" .. spos, "main", rect.x, rect.y, 1, 1) ..
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

local function on_refresh_timer(player_name, form_name, state)
  local player = player_service:get_player_by_name(player_name)
  local node = minetest.get_node(state.pos)
  local meta = minetest.get_meta(state.pos)

  state.node = node
  state.time = meta:get_float("time")

  return {
    {
      type = "refresh_formspec",
      value = render_formspec(state.pos, player, state),
    }
  }
end

local function on_rightclick(pos, node, player, _itemstack, _pointed_thing)
  local assigns = {
    pos = pos,
    node = node,
  }

  local options = {
    state = assigns,
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
    mod:make_name("spirit_lantern"),
    render_formspec(pos, player),
    options
  )
end

--- @private.spec refresh_spirit_lantern(pos: Vector3, node: NodeRef): void
local function refresh_spirit_lantern(pos, node)
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()
  local stack = inv:get_stack("main", 1)

  local new_name = node.name

  if stack and not stack:is_empty() then
    local itemdef = stack:get_definition()

    if Groups.has_group(itemdef, "spirit") then
      if itemdef.harmonia then
        local lantern_name = ELEMENT_TO_LANTERN[itemdef.harmonia.element]
        if lantern_name then
          new_name = lantern_name
        end
      end
    end
  else
    new_name = mod:make_name("spirit_lantern_core_empty")
  end

  if node.name ~= new_name then
    minetest.swap_node(pos, {
      name = new_name,
      param1 = node.param1,
      param2 = node.param2,
    })
  end
end

local function on_metadata_inventory_take(pos, _listname, _index, _item_stack, _player)
  local node = minetest.get_node_or_nil(pos)

  refresh_spirit_lantern(pos, node)
end

local function on_metadata_inventory_put(pos, _listname, _index, _item_stack, _player)
  local node = minetest.get_node_or_nil(pos)

  refresh_spirit_lantern(pos, node)
end

local empty_node_box =
  {
    type = "fixed",
    fixed = {
      -- base
      nb(0, 0, 0, 16, 2, 16),
      -- legs
      nb(1, 2, 1, 2, 10, 2),
      nb(13, 2, 1, 2, 10, 2),
      nb(1, 2, 13, 2, 10, 2),
      nb(13, 2, 13, 2, 10, 2),
      -- core
      -- nb(5, 2, 5, 6, 10, 6),
      -- cap
      nb(0, 12, 0, 16, 2, 16),
      --
      nb(5, 14, 5,  6, 1,  6),
    }
  }

local core_node_box =
  {
    type = "fixed",
    fixed = {
      -- base
      nb(0, 0, 0, 16, 2, 16),
      -- legs
      nb(1, 2, 1, 2, 10, 2),
      nb(13, 2, 1, 2, 10, 2),
      nb(1, 2, 13, 2, 10, 2),
      nb(13, 2, 13, 2, 10, 2),
      -- core
      nb(5, 2, 5, 6, 10, 6),
      -- cap
      nb(0, 12, 0, 16, 2, 16),
      --
      nb(5, 14, 5,  6, 1,  6),
    }
  }

local base_groups =  {
  choppy = nokore.dig_class("wme"),
  spirit_lantern = 1,
}

mod:register_node("spirit_lantern_empty", {
  description = mod.S("Spirit Lantern"),

  codex_entry_id = mod:make_name("spirit_lantern_empty"),

  groups = table_merge(base_groups, {}),

  harmonia = {
    max_mana = MAX_MANA,
    refresh_spirit_lantern = refresh_spirit_lantern,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = empty_node_box,

  use_texture_alpha = "clip",
  tiles = {
    "harmonia_spirit_lantern_top.png",
    "harmonia_spirit_lantern_bottom.png",
    "harmonia_spirit_lantern_side.empty.png",
    "harmonia_spirit_lantern_side.empty.png",
    "harmonia_spirit_lantern_side.empty.png",
    "harmonia_spirit_lantern_side.empty.png",
  },

  is_ground_content = false,

  on_construct = on_construct,
  on_rightclick = on_rightclick,

  on_metadata_inventory_take = on_metadata_inventory_take,
  on_metadata_inventory_put = on_metadata_inventory_put,
})

mod:register_node("spirit_lantern_core_empty", {
  description = mod.S("Spirit Lantern [Core:Empty]"),

  codex_entry_id = mod:make_name("spirit_lantern_core_empty"),

  groups = table_merge(base_groups, {
    harmonia_world_mana_consumer = 1,
    spirit_lantern_with_core = 1,
    spirit_lantern_with_core_empty = 1,
  }),

  harmonia = {
    max_mana = MAX_MANA,
    refresh_spirit_lantern = refresh_spirit_lantern,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = core_node_box,

  use_texture_alpha = "clip",
  tiles = {
    "harmonia_spirit_lantern_top.png",
    "harmonia_spirit_lantern_bottom.png",
    "harmonia_spirit_lantern_side.core.empty.png",
    "harmonia_spirit_lantern_side.core.empty.png",
    "harmonia_spirit_lantern_side.core.empty.png",
    "harmonia_spirit_lantern_side.core.empty.png",
  },

  is_ground_content = false,

  on_construct = on_construct,
  on_rightclick = on_rightclick,

  on_metadata_inventory_take = on_metadata_inventory_take,
  on_metadata_inventory_put = on_metadata_inventory_put,
})

for _i, entry in ipairs(ATTRS) do
  local core_tile = {
    name = "harmonia_spirit_lantern_side.core."..entry.basename..".png",
    animation = {
      type = "vertical_frames",
      aspect_w = 16,
      aspect_h = 16,
      length = 0.5
    },
  }

  mod:register_node("spirit_lantern_core_" .. entry.basename, {
    base_description = mod.S("Spirit Lantern [Core]"),

    description = mod.S("Spirit Lantern [Core:"..entry.description.."]"),

    codex_entry_id = mod:make_name("spirit_lantern_core"),

    drop = mod:make_name("spirit_lantern_core_empty"),

    groups = table_merge(base_groups, {
      harmonia_world_mana_consumer = 1,
      spirit_lantern_with_core = 1,
      spirit_lantern_with_core_spirit = 1,
      not_in_creative_inventory = 1,
    }),

    harmonia = {
      max_mana = MAX_MANA,
      element = entry.basename,
      refresh_spirit_lantern = refresh_spirit_lantern,
    },

    paramtype = "light",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = core_node_box,

    use_texture_alpha = "clip",
    tiles = {
      "harmonia_spirit_lantern_top.png",
      "harmonia_spirit_lantern_bottom.png",
      core_tile,
      core_tile,
      core_tile,
      core_tile,
    },

    is_ground_content = false,

    light_source = entry.light_source or 0,

    on_construct = on_construct,
    on_rightclick = on_rightclick,

    on_metadata_inventory_take = on_metadata_inventory_take,
    on_metadata_inventory_put = on_metadata_inventory_put,
  })
end

--
--
minetest.register_abm({
  label = "Spirit Lantern Luring",

  nodenames = {
    "group:spirit_lantern_with_core",
  },

  interval = 10,
  chance = 1,

  action = function (pos, node)
    local meta = minetest.get_meta(pos)
    local nodedef = minetest.registered_nodes[node.name]

    local mana = meta:get_float("mana")
    local corrupted_mana = meta:get_float("corrupted_mana")

    local max_mana = mana + corrupted_mana

    if max_mana > MINIMUM_MANA_FOR_LURE then
      local rand = math.random(nodedef.harmonia.max_mana)

      local spirit_name
      local is_corrupted = false

      if rand > 0 and rand < corrupted_mana then
        -- Run corrupted branch
        spirit_name = mod.weighted_corrupted_spirits:random()
        is_corrupted = true
      elseif rand > corrupted_mana and rand <= max_mana then
        -- Run clean mana branch
        spirit_name = mod.weighted_spirits:random()
      else
        -- skip
      end

      if spirit_name then
        local inv = meta:get_inventory()

        local stack = ItemStack(spirit_name)
        -- Spirits actively consume mana, whether or not they are captured by the lantern
        local spirit_consumes = MINIMUM_MANA_FOR_LURE
        local leftover_mana
        local used
        if is_corrupted then
          -- if the spirit was corrupted, then use as much corrupted mana as possible
          -- first
          leftover_mana = math.max(corrupted_mana - spirit_consumes, 0)
          spirit_consumes = spirit_consumes - (corrupted_mana - leftover_mana)
          corrupted_mana = leftover_mana

          -- then use the clean mana
          leftover_mana = math.max(mana - spirit_consumes, 0)
          spirit_consumes = spirit_consumes - (mana - leftover_mana)
          mana = leftover_mana
        else
          -- otherwise use as much clean mana first
          leftover_mana = math.max(mana - spirit_consumes, 0)
          spirit_consumes = spirit_consumes - (mana - leftover_mana)
          mana = leftover_mana

          -- then use as much corrupted mana to finish off
          leftover_mana = math.max(corrupted_mana - spirit_consumes, 0)
          spirit_consumes = spirit_consumes - (corrupted_mana - leftover_mana)
          corrupted_mana = leftover_mana
        end

        local leftover = inv:add_item("main", stack)

        if leftover:is_empty() then
          -- meaning it was placed into the inventory
        else
          -- TODO: maybe release the spirit into the block's inventory temporarily
        end
      end
    end

    meta:set_float("mana", mana)
    meta:set_float("corrupted_mana", corrupted_mana)

    if nodedef.harmonia then
      if nodedef.harmonia.refresh_spirit_lantern then
        nodedef.harmonia.refresh_spirit_lantern(pos, node)
      end
    end
  end,
})
