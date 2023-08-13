local ElementSystem = assert(harmonia_element.ElementSystem)
local path_join = assert(foundation.com.path_join)

local case = foundation.com.Luna:new("harmonia_element.ElementSystem")

local BLUEPRINT_DATA_DOMAIN = "element_blueprints_test"
local CRAFTING_DATA_DOMAIN = "element_crafting_test"

case:setup_all(function (tags)
  local player_data_service = nokore.PlayerDataService:new{
    root_path = path_join(path_join(minetest.get_worldpath(), "nokore_test"), "players")
  }

  player_data_service:register_domain(BLUEPRINT_DATA_DOMAIN, {
    save_method = "marshall",
  })

  player_data_service:register_domain(CRAFTING_DATA_DOMAIN, {
    save_method = "marshall",
  })

  local player_stats = nokore.PlayerStatsService:new()

  harmonia_element.register_stats(player_stats)

  local es = ElementSystem:new{
    player_data_service = player_data_service,
    player_stats = player_stats,
    blueprint_data_domain = BLUEPRINT_DATA_DOMAIN,
    crafting_data_domain = CRAFTING_DATA_DOMAIN,
  }

  tags.player_data_service = player_data_service
  tags.player_stats = player_stats
  tags.element_system = es

  local player = foundation.com.headless.PlayerRef:new("test_player")

  local meta = player:get_meta()
  meta:set_int("element_max", 1000)

  tags.player_name = player:get_player_name()
  tags.player = player
  tags.player_assigns = {}

  tags.player_data_service:on_player_join(player)

  es:clear_blueprint_crafting_queue(tags.player_name)

  es.registered_element_blueprints["test:material"] = {
    id = "test:material",
    name = "test:material",
    cost = 10,
    duration = 3,
  }

  return tags
end)

case:describe("&new/1", function (t2)
  t2:test("can initialize a new element system", function (t3, tags)
    -- nothing to do here, setup_all tests this
  end)
end)

case:describe("#add_blueprint_to_crafting_queue/2", function (t2)
  t2:setup(function (tags)
    tags.player_stats:set_player_stat(tags.player, "element", 0)
    --- tags.player:get_inventory():clear() -- there is no clear function, makes sense I guess

    return tags
  end)

  t2:test("can add a blueprint to a player's queue", function (t3, tags)
    local es = tags.element_system
    local player_stats = tags.player_stats
    local player_name = tags.player_name
    local player = tags.player
    local player_assigns = tags.player_assigns

    local added, err = es:add_blueprint_to_crafting_queue(player_name, "test:material")

    t3:assert_eq(err, ElementSystem.CraftingErrors.OK)
    t3:assert(added, "blueprint should be added to queue")

    --- At this point nothing should be active (yet)
    local item = es:peek_blueprint_crafting_queue(player_name)
    t3:assert_eq(item, nil)

    --- However it should be in the queue
    local queue = es:all_blueprint_crafting_queue(player_name)
    t3:assert_table_eq(queue, { "test:material" })

    t3:refute(es:is_blueprint_crafting_queue_empty(player_name))

    --- Test the crafting process

    --- have no element initially
    player_stats:set_player_stat(player, "element", 0)

    es:update_player_element_crafting(player, 0.1, player_assigns, nil)

    local overview = es:get_blueprint_crafting_queue_overview(player_name)

    t3:assert_eq(overview.craft_error, ElementSystem.CraftingErrors.NOT_ENOUGH_ELEMENT)

    --- gain some element and try again
    player_stats:set_player_stat(player, "element", 1000)

    es:update_player_element_crafting(player, 0.1, player_assigns, nil)

    overview = es:get_blueprint_crafting_queue_overview(player_name)

    -- Should be okay now
    t3:assert_eq(overview.craft_error, ElementSystem.CraftingErrors.OK)

    --- And should have begun crafting
    t3:assert_eq(overview.time, 2.9)
    t3:assert_eq(overview.craft_error, ElementSystem.CraftingErrors.OK)
    t3:assert_eq(overview.state, ElementSystem.States.CRAFTING)

    --- Complete the crafting process in steps
    es:update_player_element_crafting(player, 1.9, player_assigns, nil)
    overview = es:get_blueprint_crafting_queue_overview(player_name)

    --- Should still be crafting
    t3:assert_eq(overview.craft_error, ElementSystem.CraftingErrors.OK)
    t3:assert_eq(overview.state, ElementSystem.States.CRAFTING)
    t3:assert_eq(overview.time, 1.0)

    --- This should complete the crafting process
    es:update_player_element_crafting(player, 1.0, player_assigns, nil)

    --- the overview should no longer be available as there is nothing left to do
    overview = es:get_blueprint_crafting_queue_overview(player_name)
    t3:assert_table_eq(overview, {
      state = 0,
      craft_error = 0,
      time = 0.0,
      time_max = 0.0,
      size = 0,
    })

    --- the queue should be empty as well
    t3:assert(es:is_blueprint_crafting_queue_empty(player_name))

    --- Should have consumed element
    local element = player_stats:get_player_stat(player, "element")
    t3:assert_eq(990, element)

    local inv = player:get_inventory()
    t3:assert(inv:contains_item("main", ItemStack("test:material")))
    t3:refute(inv:is_empty("main"))

    inv:remove_item("main", ItemStack("test:material"))

    t3:assert(inv:is_empty("main"))
  end)

  t2:test("can handle multiple queued items", function (t3, tags)
    local es = tags.element_system
    local player_stats = tags.player_stats
    local player_name = tags.player_name
    local player = tags.player
    local player_assigns = tags.player_assigns

    local inv = player:get_inventory()

    local added, err = es:add_blueprint_to_crafting_queue(player_name, "test:material")
    t3:assert_eq(err, ElementSystem.CraftingErrors.OK)
    t3:assert(added, "blueprint should be added to queue")

    local added, err = es:add_blueprint_to_crafting_queue(player_name, "test:material")
    t3:assert_eq(err, ElementSystem.CraftingErrors.OK)
    t3:assert(added, "blueprint should be added to queue")

    local added, err = es:add_blueprint_to_crafting_queue(player_name, "test:material")
    t3:assert_eq(err, ElementSystem.CraftingErrors.OK)
    t3:assert(added, "blueprint should be added to queue")

    --- At this point nothing should be active (yet)
    local item = es:peek_blueprint_crafting_queue(player_name)
    t3:assert_eq(item, nil)

    local overview = es:get_blueprint_crafting_queue_overview(player_name)

    t3:assert_eq(overview.size, 3)

    --- However it should be in the queue
    local queue = es:all_blueprint_crafting_queue(player_name)
    t3:assert_table_eq(queue, { "test:material", "test:material", "test:material" })

    t3:refute(es:is_blueprint_crafting_queue_empty(player_name))

    player_stats:set_player_stat(player, "element", 1000)

    for i = 1,3 do
      es:update_player_element_crafting(player, 3.0, player_assigns, nil)

      t3:assert(inv:contains_item("main", ItemStack({ name = "test:material", count = i })))
    end

    --- the overview should no longer be available as there is nothing left to do
    overview = es:get_blueprint_crafting_queue_overview(player_name)
    t3:assert_table_eq(overview, {
      state = 0,
      craft_error = 0,
      time = 0.0,
      time_max = 0.0,
      size = 0,
    })

    --- the queue should be empty as well
    t3:assert(es:is_blueprint_crafting_queue_empty(player_name))

    --- Should have consumed element
    local element = player_stats:get_player_stat(player, "element")
    t3:assert_eq(970, element)

    t3:assert(inv:contains_item("main", ItemStack("test:material 3")))
    t3:refute(inv:is_empty("main"))

    inv:remove_item("main", ItemStack("test:material 3"))

    t3:assert(inv:is_empty("main"))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
