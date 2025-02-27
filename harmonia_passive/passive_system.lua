--- @namespace harmonia_passive
local table_merge = assert(foundation.com.table_merge)

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

    --- @member registered_on_passive_added: Table
    self.registered_on_passive_added = {}

    --- @member registered_on_passive_changed: Table
    self.registered_on_passive_changed = {}

    --- @member registered_on_passive_expired: Table
    self.registered_on_passive_expired = {}

    --- @member registered_on_passive_removed: Table
    self.registered_on_passive_removed = {}
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

  --- @spec #on_passive_added(name: String, callback: Function/2): void
  function ic:on_passive_added(name, callback)
    assert(name, "expected a name")
    if self.registered_on_passive_added[name] then
      error("on_passive_added callback already exists name="..name)
    end
    self.registered_on_passive_added[name] = callback
  end

  --- @spec #on_passive_changed(name: String, callback: Function/2): void
  function ic:on_passive_changed(name, callback)
    assert(name, "expected a name")
    if self.registered_on_passive_changed[name] then
      error("on_passive_changed callback already exists name="..name)
    end
    self.registered_on_passive_changed[name] = callback
  end

  --- @spec #on_passive_expired(name: String, callback: Function/2): void
  function ic:on_passive_expired(name, callback)
    assert(name, "expected a name")
    if self.registered_on_passive_expired[name] then
      error("on_passive_removed callback already exists name="..name)
    end
    self.registered_on_passive_expired[name] = callback
  end

  --- @spec #on_passive_removed(name: String, callback: Function/2): void
  function ic:on_passive_removed(name, callback)
    assert(name, "expected a name")
    if self.registered_on_passive_removed[name] then
      error("on_passive_removed callback already exists name="..name)
    end
    self.registered_on_passive_removed[name] = callback
  end

  --- Triggered whenever a passive changes
  ---
  --- @spec #_invalidate_player_stats_for_passive(PlayerRef, PassiveDefinition): void
  function ic:_invalidate_player_stats_for_passive(player, passive)
    local player_stats = nokore.player_stats
    if passive.stats then
      for name, _ in pairs(passive.stats) do
        player_stats:clear_player_stat(player, name)
      end
    end
  end

  function ic:_trigger_on_passive_added(...)
    for _, callback in pairs(self.registered_on_passive_added) do
      callback(...)
    end
  end

  function ic:_trigger_on_passive_changed(...)
    for _, callback in pairs(self.registered_on_passive_changed) do
      callback(...)
    end
  end

  function ic:_trigger_on_passive_expired(...)
    for _, callback in pairs(self.registered_on_passive_expired) do
      callback(...)
    end
  end

  function ic:_trigger_on_passive_removed(...)
    for _, callback in pairs(self.registered_on_passive_removed) do
      callback(...)
    end
  end

  --- @spec #update_players(players: PlayerRef[], dtime: Float, assigns: Table): void
  function ic:update_players(players, dtime, assigns)
    local tmp
    local time_max
    local counters
    local new_counters
    local assigns
    local passive_timers
    local passive_timers_max
    local passive_counters
    local passive_assigns
    local passive

    for player_name, player in pairs(players) do
      self.player_data_service:with_player_domain_kv(player_name, self.m_data_domain, function (kv)
        passive_timers = kv:get("passive_timers")
        if passive_timers and next(passive_timers) then
          tmp = {}
          passive_timers_max = kv:get("passive_timers_max") or {}
          passive_counters = kv:get("passive_counters") or {}
          passive_assigns = kv:get("passive_assigns") or {}

          for passive_name, time in pairs(passive_timers) do
            passive = self.passive_registry:get_passive(passive_name)
            counters = passive_counters[passive_name]
            time_max = passive_timers_max[passive_name]
            assigns = passive_assigns[passive_name] or {}
            if not passive_assigns[passive_name] then
              passive_assigns[passive_name] = assigns
            end

            time, new_counters = passive:update(
              player,
              time,
              time_max,
              counters,
              dtime,
              assigns
            )

            if time > 0 and new_counters > 0 then
              tmp[passive_name] = time
              passive_counters[passive_name] = new_counters
              if new_counters ~= counters then
                passive:on_changed(player, time, time_max, counters, assigns)
                self:_invalidate_player_stats_for_passive(player, passive)
                self:_trigger_on_passive_changed(passive, player, time, time_max, counters, assigns)
              end
            else
              --- Expire the passive
              passive:on_expired(player, time, time_max, counters, assigns)
              --- Handle the expired callbacks
              self:_trigger_on_passive_expired(passive, player, time, time_max, counters, assigns)
              --- Then trigger any stat invalidations
              self:_invalidate_player_stats_for_passive(player, passive)

              --- Finally handle the passive's removal
              passive:on_removed(player, time, time_max, counters, assigns)
              --- And then the passive's removal callbacks
              self:_trigger_on_passive_removed(passive, player, time, time_max, counters, assigns)

              --- Finally clear the passive's fields
              passive_counters[passive_name] = nil
              passive_timers_max[passive_name] = nil
              passive_assigns[passive_name] = nil
            end
          end

          passive_timers = tmp

          kv:put("passive_timers", passive_timers)
          kv:put("passive_timers_max", passive_timers_max)
          kv:put("passive_counters", passive_counters)
          kv:put("passive_assigns", passive_assigns)
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
      local counters = params.counters or 1
      local assigns = params.assigns or {}

      local player_name = player:get_player_name()
      self.player_data_service:with_player_domain_kv(player_name, self.m_data_domain, function (kv)
        kv:upsert_lazy("passive_counters", function (map)
          map = map or {}
          map[passive_name] = counters
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
        kv:upsert_lazy("passive_assigns", function (map)
          map = map or {}
          map[passive_name] = assigns
          return map
        end)
        --
        passive:on_added(player, duration, duration, counters, assigns)
        passive:on_changed(player, duration, duration, counters, assigns)
        self:_invalidate_player_stats_for_passive(player, passive)
        self:_trigger_on_passive_added(passive, player, duration, duration, counters, assigns)
        self:_trigger_on_passive_changed(passive, player, duration, duration, counters, assigns)
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
  --- @spec #push_passive(player: PlayerRef, passive_name: String, params: Table): Boolean
  function ic:push_passive(player, passive_name, params)
    local passive = self.passive_registry:get_passive(passive_name)

    if passive then
      local duration = assert(params.duration, "expected a duration to be provided")
      local time
      local counters = params.counters or 1
      local reset_timer = params.reset_timer or false
      local assigns = params.assigns or {}

      local player_name = player:get_player_name()
      self.player_data_service:with_player_domain_kv(player_name, self.m_data_domain, function (kv)
        local just_added = false
        kv:upsert_lazy("passive_counters", function (map)
          map = map or {}
          just_added = not map[passive_name]
          counters = (map[passive_name] or 0) + counters
          map[passive_name] = counters
          return map
        end)
        kv:upsert_lazy("passive_timers", function (map)
          map = map or {}
          if not map[passive_name] then
            map[passive_name] = duration
          elseif reset_timer then
            map[passive_name] = duration
          end
          time = map[passive_name]
          return map
        end)
        kv:upsert_lazy("passive_timers_max", function (map)
          map = map or {}
          map[passive_name] = duration
          return map
        end)
        kv:upsert_lazy("passive_assigns", function (map)
          map = map or {}
          local current_assigns = map[passive_name] or {}
          assigns = table_merge(current_assigns, assigns)
          map[passive_name] = assigns
          return map
        end)

        if just_added then
          passive:on_added(player, time, duration, counters, assigns)
        end

        passive:on_changed(player, time, duration, counters, assigns)

        self:_invalidate_player_stats_for_passive(player, passive)
        if just_added then
          self:_trigger_on_passive_added(
            passive,
            player,
            time,
            duration,
            counters,
            assigns
          )
        end
        self:_trigger_on_passive_changed(
          passive,
          player,
          time,
          duration,
          counters,
          assigns
        )

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

    local passive_counters = kv:get("passive_counters")

    local counters = passive_counters[passive_name]
    if counter then
      local timers = kv:get("passive_timers")
      local timers_max = kv:get("passive_timers_max")
      local passive_assigns = kv:get("passive_assigns")

      local passive = self.passive_registry:get_passive(passive_name)
      local time = timers[passive_name]
      local time_max = timers_max[passive_name]
      local assigns = passive_assigns[passive_name] or {}

      local result = {
        passive = passive,
        counters = counters,
        time = time,
        time_max = time_max,
        assigns = assigns,
      }

      counters[passive_name] = nil
      timers[passive_name] = nil
      timers_max[passive_name] = nil

      kv:put("passive_counters", counters)
      kv:put("passive_timers", timers)
      kv:put("passive_timers_max", timers_max)
      kv:put("passive_assigns", passive_assigns)

      passive:on_removed(player, time, time_max, counter, assigns)
      self:_invalidate_player_stats_for_passive(player, passive)
      self:_trigger_on_passive_removed(
        passive,
        player,
        time,
        time_max,
        counters,
        assigns
      )

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

    local passive_counters = kv:get("passive_counters")
    local timers = kv:get("passive_timers")
    local timers_max = kv:get("passive_timers_max")
    local passive_assigns = kv:get("passive_assigns")

    local result = {}

    for passive_name, counters in pairs(counters) do
      result[passive_name] = {
        passive = self.passive_registry:get_passive(passive_name),
        counters = counters,
        time = timers[passive_name],
        time_max = timers_max[passive_name],
        assigns = (passive_assigns and passive_assigns[passive_name]) or {}
      }
    end

    return result
  end

  --- Determines if the player has the specified passive.
  ---
  --- @spec #get_player_passive(PlayerRef, passive_name: String): Boolean
  function ic:get_player_passive(player, passive_name)
    local player_name = player:get_player_name()
    local kv = self:get_player_domain_kv_by_name(player_name)
    local passive_counters = kv:get("passive_counters")

    local counters = passive_counters[passive_name]
    if counters then
      local timers = kv:get("passive_timers")
      local timers_max = kv:get("passive_timers_max")
      local passive_assigns = kv:get("passive_assigns")
      return {
        passive = self.passive_registry:get_passive(passive_name),
        counters = counters,
        time = timers[passive_name],
        time_max = timers_max[passive_name],
        assigns = (passive_assigns and passive_assigns[passive_name]) or {}
      }
    end

    return nil
  end

  --- Determines if the player has the specified passive.
  ---
  --- @spec #player_has_passive(PlayerRef, passive_name: String): Boolean
  function ic:player_has_passive(player, passive_name)
    local player_name = player:get_player_name()
    return self:player_by_name_has_passive(player_name, passive_name)
  end

  --- Determines if the player (by name) has the specified passive.
  ---
  --- @spec #player_by_name_has_passive(player_name: String, passive_name: String): Boolean
  function ic:player_by_name_has_passive(player_name, passive_name)
    local kv = self:get_player_domain_kv_by_name(player_name)
    local counters = kv:get("passive_counters")
    if counters then
      return counters[passive_name] ~= nil
    else
      return false
    end
  end

  --- Iterates each passive for the specified player calling the given callback with its data
  ---
  --- @spec #reduce_player_passives(PlayerRef, T, callback: Function/6): T
  function ic:reduce_player_passives(player, acc, callback)
    local player_name = player:get_player_name()
    return self:reduce_player_by_name_passives(player_name, acc, callback)
  end

  --- @spec #reduce_player_by_name_passives(
  ---   player_name: String,
  ---   acc: T,
  ---   callback: (PassiveDefinition, time: Float, time_max: Float, counter: Integer, assigns: Table, acc: T) => T
  --- ): T
  function ic:reduce_player_by_name_passives(player_name, acc, callback)
    local kv = self:get_player_domain_kv_by_name(player_name)
    if kv then
      local counters = kv:get("passive_counters")
      if counters then
        local timers = kv:get("passive_timers")
        local timers_max = kv:get("passive_timers_max")
        local passive_assigns = kv:get("passive_assigns") or {}

        local time
        local time_max
        local assigns
        local passive
        for passive_name, counter in pairs(counters) do
          passive = self.passive_registry:get_passive(passive_name)
          if not passive_assigns[passive_name] then
            passive_assigns[passive_name] = {}
          end
          time = timers[passive_name]
          time_max = timers_max[passive_name]
          assigns = passive_assigns[passive_name]
          acc = callback(passive, time, time_max, counter, assigns, acc)
        end
        kv:put("passive_assigns", passive_assigns)
      end
    end
    return acc
  end
end

harmonia_passive.PassiveSystem = PassiveSystem
