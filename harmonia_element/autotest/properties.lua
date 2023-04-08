local mod = assert(harmonia_element)
local fparser = assert(foundation.com.formspec.parser)

mod.autotest_suite:define_property("test_element_crafting", {
  description = "Test Element Crafting",
  detail = [[
  Test functionality of element crafting
  ]],

  setup = function (suite, state)
    local player = assert(minetest.get_player_by_name("singleplayer"))

    state.player = player

    local player_name = state.player:get_player_name()

    harmonia.element:clear_blueprint_crafting_queue(player_name)
    local list = harmonia.element:all_blueprint_crafting_queue(player_name)
    assert(#list == 0, "expected queue to be empty")

    local meta = state.player:get_meta()
    meta:set_int("element_max", 200)
    nokore.player_stats:set_player_stat(state.player, "element", 200)

    return state
  end,

  tests = {
    ["Can processing element blueprint and add result to inventory"] = function (suite, state)
      local player_name = state.player:get_player_name()

      local blueprint_id = "hsw_materials:wme"

      assert(harmonia.element:add_blueprint_to_crafting_queue(player_name, blueprint_id))
      local list = harmonia.element:all_blueprint_crafting_queue(player_name)
      suite:yield()

      if #list > 0 then
        if #list > 1 then
          print(dump(list))
          error("multiple blueprints present")
        end
      else
        error("no blueprints present")
      end
      assert(list[1] == "hsw_materials:wme")

      local overview = harmonia.element:get_blueprint_crafting_queue_overview(player_name)

      assert(overview)
      assert(overview.state == harmonia_element.ElementSystem.States.CRAFTING, "expected state to be crafting")
      assert(overview.current_item == "hsw_materials:wme")
      assert(overview.time > 0)
      assert(overview.time_max > 0)

      local elapsed = 0

      while elapsed < 10 do
        if harmonia.element:is_blueprint_crafting_queue_empty(player_name) then
          break
        end
        suite:wait(1)
        elapsed = elapsed + 1
      end

      if elapsed < 10 then
        local list = harmonia.element:all_blueprint_crafting_queue(player_name)

        assert(#list == 0)

        --
        local inv = state.player:get_inventory()

        assert_and_remove_item_stack_in_inventory(
          inv,
          "main",
          ItemStack("hsw_materials:wme")
        )

        assert(inv:is_empty("main"))
      else
        error("timeout while waiting for blueprint crafting to complete")
      end
    end,
  },

  teardown = function (suite, state)
  end,
})
