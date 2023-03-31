-- @namespace harmonia_passive
local player_data_service = nokore.player_data_service

-- @class PassiveSystem
local PassiveSystem = foundation.com.Class:extends("PassiveSystem")
local ic = PassiveSystem.instance_class

-- @spec #initialize(data_domain: String): void
function ic:initialize(data_domain)
  -- @member m_data_domain: String
  self.m_data_domain = data_domain
end

-- @spec #init(): void
function ic:init()
  --
end

-- @spec #terminate(): void
function ic:terminate()
  print("harmonia_passive", "terminating")
  --
  print("harmonia_passive", "terminated")
end

-- @spec #update_players(players: PlayerRef[], delta: Float, assigns: Table): void
function ic:update_players(players, delta, assigns)
  for player_name, player in pairs(players) do
    player_data_service:with_player_domain_kv(player_name, self.m_data_domain, function (kv_store)
      --
      return false
    end)
  end
end

harmonia_passive.PassiveSystem = PassiveSystem
