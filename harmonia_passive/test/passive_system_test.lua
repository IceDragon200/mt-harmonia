local mod = assert(harmonia_passive)

local PlayerDataService = assert(nokore.PlayerDataService)
local PassiveRegistry = assert(harmonia_passive.PassiveRegistry)

local subject = mod.PassiveSystem
local case = foundation.com.Luna:new("harmonia_passive.PassiveSystem")

case:setup_all(function (tags)
  local pds = PlayerDataService:new()
  tags.player_data_service = pds
  return tags
end)

case:setup_all(function (tags)
  local pr = PassiveRegistry:new()
  tags.passive_registry = pr
  return tags
end)

case:describe("&new/1", function (t2)
  t2:test("can initialize a new passive system", function (t3, tags)
    local inst = subject:new{
      data_domain = "harmonia_passive_test",
      player_data_service = tags.player_data_service,
      passive_registry = tags.passive_registry,
    }
  end)
end)

case:describe("with instance", function (case2)
  case2:setup(function (tags)
    local inst = subject:new{
      data_domain = "harmonia_passive_test",
      player_data_service = tags.player_data_service,
      passive_registry = tags.passive_registry,
    }

    tags.passive_system = inst

    return tags
  end)

  case2:describe("#update_players/3", function (t2)
    t2:test("can dry run", function (t3, tags)
      local players = {}
      local dtime = 0.25
      local assigns = {}
      tags.passive_system:update_players(players, dtime, assigns)
    end)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
