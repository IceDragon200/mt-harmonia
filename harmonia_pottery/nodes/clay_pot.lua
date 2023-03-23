--
-- Clay Pots have a 3x3 storage
--
local mod = assert(harmonia_pottery)

local fspec = assert(foundation.com.formspec.api)

if rawget(_G, "yatm_core") then
  --
  -- @spec get_formspec(Vector3, PlayerRef): String
  local function get_formspec(pos, player)
    local spos = pos.x .. "," .. pos.y .. "," .. pos.z

    local formspec = yatm.formspec_render_split_inv_panel(player, 3, 3, { bg = "default" }, function (loc, rect)
      if loc == "main_body" then
        return fspec.list("nodemeta:" .. spos, "main", rect.x, rect.y, 3, 3)
      elseif loc == "footer" then
        return fspec.list_ring()
      end
      return ""
    end)

    return formspec
  end
else
  --
  -- @spec get_formspec(Vector3, PlayerRef): String
  local function get_formspec(pos, player)
    local spos = pos.x .. "," .. pos.y .. "," .. pos.z

    local formspec =
      fspec.size(nokore_player_inv.player_hotbar_size, 9) ..
      fspec.list("nodemeta:" .. spos, "main", 0, 0.3, 3, 3) ..
      nokore_player_inv.player_inventory_lists_fragment(player, 0, 5.85) ..
      fspec.list_ring()

    return formspec
  end
end

--
-- @spec on_construct(Vector3): void
local function on_construct(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  inv:set_size("main", 3 * 3)
end

--
-- @spec can_dig(Vector3): Boolean
local function can_dig(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  return inv:is_empty("main")
end

local function on_rightclick(pos, _node, player, item_stack, _pointed_thing)
  local id = minetest.pos_to_string(pos)
  local options = {
    state = {
      pos = pos,
      id = id,
    },
  }
  nokore.formspec_bindings:show_formspec(
    player:get_player_name(),
    mod:make_name("clay_pot"),
    get_formspec(pos, player),
    options
  )
end

mod:register_node("clay_pot", {
  description = mod.S("Clay Pot"),

  groups = {
    cracky = nokore.dig_class("wme"),
    oddly_breakable_by_hand = nokore.dig_class("hand"),
  },

  paramtype = "light",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-6/16,-8/16,-6/16,6/16,-7/16,6/16}, -- bottom plate
      {-7/16,-7/16,-7/16,7/16,1/16,7/16}, -- vessel body
      {-6/16,1/16,-6/16,6/16,2/16,6/16}, -- top plate
      {-5/16,2/16,-5/16,5/16,3/16,5/16}, -- pre throat
      {-4/16,3/16,-4/16,4/16,5/16,4/16}, -- throat
      {-5/16,5/16,-5/16,5/16,6/16,5/16}, -- pre mouth
      {-6/16,6/16,-6/16,6/16,8/16,6/16} -- mouth
    }
  },

  use_texture_alpha = "clip",
  tiles = {
    "harmonia_clay_pot_top.png",
    "harmonia_clay_pot_bottom.png",
    "harmonia_clay_pot_side.png",
    "harmonia_clay_pot_side.png",
    "harmonia_clay_pot_side.png",
    "harmonia_clay_pot_side.png",
  },

  is_ground_content = false,

  on_construct = on_construct,
  on_rightclick = on_rightclick,

  can_dig = can_dig,
})
