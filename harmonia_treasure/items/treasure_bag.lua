local treasure = assert(nokore.treasure)
local InventoryPacker = assert(foundation.com.InventoryPacker)
local fspec = assert(foundation.com.formspec.api)

local DEFAULT_TREASURE_LIST_NAME = "treasure_bag"
local TEMP_LIST_NAME = "tmp_treasure_bag"
local BAG_SIZE = 10
local MIN_LOOT = 3
local MAX_LOOT = BAG_SIZE

-- @spec render_formspec(Player, Table): String
local function render_formspec(user, assigns)
  local v2 = nokore_player_inv.player_inventory_size2(user)
  local cio = fspec.calc_inventory_offset

  local cols = math.max(v2.x, BAG_SIZE)
  local w = cio(cols)
  local tx = (w - cio(BAG_SIZE)) / 2
  local px = (w - cio(v2.x)) / 2
  local bag_rows = 1

  return fspec.formspec_version(4) ..
         fspec.size(0.5 + w, 0.5 + cio(v2.y + 1)) ..
         fspec.list("current_player", TEMP_LIST_NAME, 0.25 + tx, 0.25, BAG_SIZE, bag_rows) ..
         nokore_player_inv.player_inventory_lists_fragment(user, 0.25 + px, 0.25 + cio(1)) ..
         fspec.list_ring()
end

-- Callback when a treasure is opened, this will initialize the inventory
-- and fill it with treasure, the bag can have a specific list name to initialize from.
--
-- @spec initialize_treasure_bag(ItemStack, Player, PointedThing): void
local function initialize_treasure_bag(item_stack, _user, _pointed_thing)
  local meta = item_stack:get_meta()

  local treasure_list_name = meta:get("treasure_list_name")
  treasure_list_name = treasure_list_name or DEFAULT_TREASURE_LIST_NAME

  -- at least three items will be produced
  -- FIXME: this should be configurable
  local loot_count = MIN_LOOT + math.random(MAX_LOOT - MIN_LOOT)
  local list = treasure.sample_treasures(treasure_list_name, loot_count)
  local blob = InventoryPacker.ascii_pack_list(list)

  local new_item_stack = ItemStack(item_stack)
  new_item_stack:set_name("harmonia_treasure:bag")
  meta = new_item_stack:get_meta()
  meta:set_string("inv_blob", blob)

  return new_item_stack
end

-- Whenver the formspec quits this callback is executed
-- It performs the necessary cleanup and moving the inventory blob back unto
-- the bag.
--
-- @spec handle_bag_on_quit(Player, String, Table, Table): void
local function handle_bag_on_quit(player, form_name, fields, assigns)
  local player_meta = player:get_meta()
  local inv = player_meta:get_inventory()
  local list = inv:get_list(TEMP_LIST_NAME)
  local blob = InventoryPacker.ascii_pack_list(list)

  local item_stack = assigns.item_stack
  local meta = item_stack:get_meta()
  meta:set_string("inv_blob", blob)

  local leftover = inv:add_stack("main", item_stack)

  if not leftover:is_empty() then
    minetest.spawn_item(player:get_pos(), leftover)
  end

  -- wipe it out
  inv:set_list(TEMP_LIST_NAME, {})
  inv:set_size(TEMP_LIST_NAME, 0)
end

-- @spec on_open_bag(ItemStack, Player, PointedThing): ItemStack
local function on_open_bag(item_stack, user, pointed_thing)
  local meta = item_stack:get_meta()
  local blob = meta:get_string("inv_blob")
  -- now working with detached inventories is a pain in the ass, not to mention
  -- if something happens while the player is looking in the bag we can't account
  -- for the changes made either.
  -- So instead, we'll open the treasure on the player as a hidden inventory
  local player_meta = user:get_meta()
  local inv = player_meta:get_inventory()

  -- FIXME: treasure bag size should be configurable
  inv:set_size(TEMP_LIST_NAME, BAG_SIZE)
  local list = InventoryPacker.ascii_unpack_list(blob)
  inv:set_list(TEMP_LIST_NAME, list)

  local assigns = {
    state = {
      item_stack = item_stack,
    },
    on_quit = handle_bag_on_quit,
  }

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    "harmonia_treasure:bag",
    render_formspec(user, assigns),
    assigns
  )

  -- because the player could potentially put the bag in the bag and ... you know lose it
  -- we remove it from their inventory while it is open
  -- when the formspec is closed it will be returned to their inventory, or
  -- is dropped if their inventory is full.
  return ItemStack()
end

-- @spec on_open_treasure_bag(ItemStack, Player, PointedThing): ItemStack
local function on_open_treasure_bag(item_stack, user, pointed_thing)
  local new_item_stack = initialize_treasure_bag(item_stack, user, pointed_thing)

  return on_open_bag(new_item_stack, user, pointed_thing)
end

-- Opened treasure bags
minetest.register_tool("harmonia_treasure:bag", {
  description = "Bag",

  inventory_image = "harmonia_treasure_bags_open.png",

  on_place = on_open_bag,
})

-- When a treasure bag is used, it opens a formspec with some goodies inside, allowing the player
-- to retrieve the items in it, once empty it transitions to a regular bag, that can be used
-- to store items.
-- Note that treasure bags have their inventories randomized on the first open.
minetest.register_tool("harmonia_treasure:treasure_bag", {
  description = "Treasure Bag",

  inventory_image = "harmonia_treasure_bags_close.png",

  on_place = on_open_treasure_bag,
})
