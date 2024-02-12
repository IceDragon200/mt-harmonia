--- @namespace harmonia_passive

--- @type PassiveInstance: {
---   passive: harmonia_passive.PassiveDefinition,
---   counter: Integer,
---   time: Float,
---   time_max: Float,
--- }

--- @class PassiveSystem
local PassiveSystem = foundation.com.Class:extends("PassiveSystem")
do
  local ic = PassiveSystem.instance_class

  --- @spec #initialize({
  ---   data_domain: String,
  ---   passive_registry: PassiveRegistry
  --- }): void
  function ic:initialize(options)
    --- @member m_data_domain: String
    self.m_data_domain = assert(options.data_domain, "expected a data domain")

    --- The instance of a passive registry associated with this passive system.
    ---
    --- @member passive_registry: PassiveRegistry
    self.passive_registry = assert(options.passive_registry, "expected a passive registry")

    --- The instance of the PlayerDataService associated with this system.
    ---
    --- @member player_data_service: nokore_player_data_service.PlayerDataService
    self.player_data_service = assert(options.player_data_service, "expected player data service")
  end

  --- @spec #init(): void
  function ic:init()
    --
  end

  --- @spec #terminate(): void
  function ic:terminate()
    print("harmonia_passive", "terminating")
    --
    print("harmonia_passive", "terminated")
  end

  --- @spec #update_players(players: PlayerRef[], dtime: Float, assigns: Table): void
  function ic:update_players(players, dtime, assigns)
    local tmp
    local time_max
    local counter
    local passive_timers
    local passive_timers_max
    local passive_counters
    local passive

    for player_name, player in pairs(players) do
      self.player_data_service:with_player_domain_kv(player_name, self.m_data_domain, function (kv)
        passive_timers = kv:get("passive_timers")
        if passive_timers and next(passive_timers) then
          tmp = {}
          passive_timers_max = kv:get("passive_timers_max") or {}
          passive_counters = kv:get("passive_counters") or {}

          for passive_name, time in pairs(passive_timers) do
            passive = self.passive_registry:get_passive(passive_name)
            counter = passive_counters[passive_name]
            time_max = passive_timers_max[passive_name]
            time, counter = passive:update(player, time, time_max, counter, dtime)

            if time > 0 and counter > 0 then
              tmp[passive_name] = time
              passive_counters[passive_name] = counter
            else
              passive:on_expired(player)
              passive_counters[passive_name] = nil
              passive_timers_max[passive_name] = nil
            end
          end

          passive_timers = tmp

          kv:put("passive_timers", passive_timers)
          kv:put("passive_timers_max", passive_timers_max)
          kv:put("passive_counters", passive_counters)
        end

        -- Do not persist, since this function will be called often, this could get quite expensive
        return false
      end)
    end
  end

  --
  -- API
  --

  --- @spec #get_player_domain_kv_by_name(player_name: String): nokore.KVStore
  function ic:get_player_domain_kv_by_name(player_name)
    return self.player_data_service:get_player_domain_kv(player_name, self.m_data_domain)
  end

  --- Manually set passive's parameters.
  --- Params:
  --- * `counters` - some passives can be "stacked", this count controls how many stacks are present.
  ---             If not provided, the default is 1.
  --- * `duration` - Passives are expected to have a duration (in seconds) that they will continue
  ---                to apply, when the duration is over the #on_expired/1 will be called for that
  ---                passive.
  ---
  --- @spec #set_passive(player: PlayerRef, passive_name: String, params: Table): Boolean
  function ic:set_passive(player, passive_name, params)
    local passive = self.passive_registry:get_passive(passive_name)
    if passive then
      local duration = assert(params.duration, "expected a duration to be provided")
      local count = params.counters or 1

      local player_name = player:get_player_name()
      self.player_data_service:with_player_domain_kv(player_name, function (kv)
        kv:upsert_lazy("passive_counters", function (map)
          map = map or {}
          map[passive_name] = count
          return map
        end)
        kv:upsert_lazy("passive_timers", function (map)
          map = map or {}
          map[passive_name] = duration
          return map
        end)
        kv:upsert_lazy("passive_timers_max", function (map)
          map = map or {}
          map[passive_name] = duration
          return map
        end)
        return true
      end)

      return true
    end

    return false
  end

  --- Similar to #set_passive/3 but will add to the counters and optionally reset the timer if
  --- requested.
  --- This will act like set_passive if the passive wasn't already present.
  ---
  --- @spec #push_passive(player: PlayerRef, passive_name: String): Boolean
  function ic:push_passive(player, passive_name, params)
    local passive = self.passive_registry:get_passive(passive_name)

    if passive then
      local duration = assert(params.duration, "expected a duration to be provided")
      local count = params.counters or 1
      local reset_timer = params.reset_timer or false

      local player_name = player:get_player_name()
      self.player_data_service:with_player_domain_kv(player_name, function (kv)
        kv:upsert_lazy("passive_counters", function (map)
          map = map or {}
          map[passive_name] = (map[passive_name] or 0) + count
          return map
        end)
        kv:upsert_lazy("passive_timers", function (map)
          map = map or {}
          if not map[passive_name] then
            map[passive_name] = duration
          elseif reset_timer then
            map[passive_name] = duration
          end
          return map
        end)
        kv:upsert_lazy("passive_timers_max", function (map)
          map = map or {}
          map[passive_name] = duration
          return map
        end)
        return true
      end)

      return true
    end
    return false
  end

  --- Remove a passive from player, regardless of how many counters it had.
  --- This will return a PassiveInstance with the original data or nil if no passive was removed.
  ---
  --- @spec #remove_passive(player: PlayerRef, passive_name: String): PassiveInstance | nil
  function ic:remove_passive(player, passive_name)
    local player_name = player:get_player_name()
    local kv = self:get_player_domain_kv_by_name(player_name)

    local counters = kv:get("passive_counters")
    local timers = kv:get("passive_timers")
    local timers_max = kv:get("passive_timers_max")

    if counters[passive_name] then
      local result = {
        passive = self.passive_registry:get_passive(passive_name),
        counter = counters[passive_name],
        time = timers[passive_name],
        time_max = timers_max[passive_name],
      }

      counters[passive_name] = nil
      timers[passive_name] = nil
      timers_max[passive_name] = nil

      kv:put("passive_counters", counters)
      kv:put("passive_timers", timers)
      kv:put("passive_timers_max", timers_max)

      return result
    end

    return nil
  end

  --- Returns player's passives in a easy to use table structure, this is not optimized for use
  --- in an update loop or something similar.
  --- Instead this is provided as an easy interface for one-off lists.
  ---
  --- @spec #list_player_passives(
  ---   player: PlayerRef
  --- ): { [passive_name: String]: PassiveInstance }
  function ic:list_player_passives(player)
    local player_name = player:get_player_name()
    local kv = self:get_player_domain_kv_by_name(player_name)

    local counters = kv:get("passive_counters")
    local timers = kv:get("passive_timers")
    local timers_max = kv:get("passive_timers_max")

    local result = {}

    for passive_name, counter in pairs(counters) do
      result[passive_name] = {
        passive = self.passive_registry:get_passive(passive_name),
        counter = counter,
        time = timers[passive_name],
        time_max = timers_max[passive_name],
      }
    end

    return result
  end
end

harmonia_passive.PassiveSystem = PassiveSystem
