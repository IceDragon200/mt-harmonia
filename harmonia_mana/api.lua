local player_service = assert(nokore.player_service)
local player_stats = assert(nokore.player_stats)

harmonia = rawget(_G, "harmonia") or {}

--- @namespace harmonia.mana
harmonia.mana = harmonia.mana or {}

harmonia.mana.registered_on_player_mana_changed = {}

--- @spec #register_on_player_mana_changed(name: String, callback: Function/2): void
function harmonia.mana:register_on_player_mana_changed(name, callback)
  assert(type(name) == "string", "expected a callback name")
  assert(type(callback) == "function", "expected a callback function")

  if self.registered_on_player_mana_changed[name] then
    error("callback name=" .. name " already registered")
  end
  self.registered_on_player_mana_changed[name] = callback
end

function harmonia.mana:trigger_on_player_mana_changed(player, event)
  for _, callback in pairs(self.registered_on_player_mana_changed) do
    callback(player, event)
  end
end

--- @spec #set_player_mana_max(PlayerRef, value: Integer): void
function harmonia.mana:set_player_mana_max(player, value)
  local meta = player:get_meta()
  meta:set_int("mana_max", value)
  harmonia.mana:trigger_on_player_mana_changed(player, { mana_max = value })
end

--- Prefer the player_stats:set_player_stat(player, "mana", mana) over this unless you know what
--- you're doing.
---
--- @spec #set_player_mana(PlayerRef, value: Integer): void
function harmonia.mana:set_player_mana(player, value)
  local meta = player:get_meta()
  meta:set_int("mana", value)
  harmonia.mana:trigger_on_player_mana_changed(player, { mana = value })
end

-- The Mana system's update hook
player_service:register_update(
  "harmonia_mana:update_players",
  function (players, dt, players_assigns)
    local mana
    local mana_max
    local mana_regen
    local mana_degen
    local mana_gen_time
    local player_assigns

    for player_name, player in pairs(players) do
      player_assigns = players_assigns[player_name]
      mana_max = player_stats:get_player_stat(player, "mana_max")
      mana = player_stats:get_player_stat(player, "mana")
      mana_regen = player_stats:get_player_stat(player, "mana_regen")
      mana_degen = player_stats:get_player_stat(player, "mana_degen")

      mana_gen_time = player_assigns["mana_gen_time"] or 0
      mana_gen_time = mana_gen_time + dt

      if mana_gen_time > 1 then
        mana_gen_time = mana_gen_time - 1

        if mana_regen > 0 then
          -- mana is allowed to overflow
          if mana < mana_max then
            mana = mana + math.min(mana_regen, mana_max - mana)
          end
        end

        if mana_degen > 0 then
          -- only try degen if the mana is greater than zero
          if mana > 0 then
            mana = math.max(mana - mana_degen, 0)
          end
        end

        --- We go through the player stats system instead of our own APIs to ensure it is alerted of the changes
        player_stats:set_player_stat(player, "mana", mana)
      end

      player_assigns["mana_gen_time"] = mana_gen_time

      if player_assigns["last_mana"] ~= mana or player_assigns["last_mana_max"] ~= mana_max then
        player_assigns["last_mana"] = mana
        player_assigns["last_mana_max"] = mana_max

        harmonia.mana:trigger_on_player_mana_changed(player, {
          mana = mana,
          mana_max = mana_max,
        })
      end
    end
  end
)
