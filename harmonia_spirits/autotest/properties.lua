local mod = assert(harmonia_spirits)
local fparser = assert(foundation.com.formspec.parser)

local function random_pos()
  return {
    x = math.random(0xFFFF) - 0x8000,
    y = math.random(0xFFFF) - 0x8000,
    z = math.random(0xFFFF) - 0x8000,
  }
end

mod.autotest_suite:define_property("is_mana_heater", {
  description = "Is Mana Heater",
  detail = [[
  Test behaviour of a mana heater
  ]],

  setup = function (suite, state)
    local player = assert(minetest.get_player_by_name("singleplayer"))

    state.player = player

    state.pos = random_pos()
    suite:clear_test_area(state.pos)
    minetest.set_node(state.pos, assert(state.node))

    return state
  end,

  tests = {
    ["Has a right-click formspec"] = function (suite, state)
      assert(trigger_rightclick_on_pos(state.pos, state.player))
    end,

    ["Can update a mana heater"] = function (suite, state)

    end,
  },

  teardown = function (suite, state)
    suite:clear_test_area(state.pos)
  end,
})
