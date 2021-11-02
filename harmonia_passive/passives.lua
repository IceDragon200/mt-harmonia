-- @namespace harmonia_passive
local player_data_service = nokore.player_data_service

-- @class PassiveSystem
local PassiveSystem = foundation.com.Class:extends("PassiveSystem")
local ic = PassiveSystem.instance_class

function ic:initialize(data_domain)
  self.m_data_domain = data_domain
end

function ic:init()
  --
end

function ic:terminate()
  print("harmonia_passive", "terminating")
  --
  print("harmonia_passive", "terminated")
end

function ic:update_players(players, delta, assigns)
  for player_name, player in pairs(players) do
    player_data_service:with_player_domain_kv(player_name, self.m_data_domain, function (kv_store)
      --
      return false
    end)
  end
end

harmonia_passive.PassiveSystem = PassiveSystem
