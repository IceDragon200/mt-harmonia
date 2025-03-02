--- @namespace harmonia_passive
local mod = assert(harmonia_passive)

mod.enabled_stat_modifiers = {}

--- Enables Player Stat Modifiers for specified stat with the passive system.
--- By default passives will not affect any stats, but they can be enabled through this function.
--- Note that this function will only register the same stat once.
---
--- @spec enable_stat_modifier(stat_name: String): void
function mod.enable_stat_modifier(stat_name)
  if mod.enabled_stat_modifiers[stat_name] then
    return
  end

  mod.enabled_stat_modifiers[stat_name] = true

  for _, modifier_name in ipairs({ "base", "add", "mul" }) do
    local cbname = mod:make_name("mod_" .. stat_name .. "_" .. modifier_name)

    nokore.player_stats:register_stat_modifier(stat_name, cbname, modifier_name, function (player, value)
      local stat_def
      local modifier

      return harmonia.passive.system:reduce_player_passives(player, value, function (passive, time, time_max, counter, assigns, acc)
        if passive.stats then
          stat_def = passive.stats[stat_name]

          if stat then
            modifier = stat_def[modifier_name]
            if modifier then
              acc = modifier(passive, player, acc, time, time_max, counter, assigns)
            end
          end
        end
        return acc
      end)
    end)
  end
end
