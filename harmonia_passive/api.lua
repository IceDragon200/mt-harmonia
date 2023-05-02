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
      local player_name = player:get_player_name()
      local upgrades = hsw.nanosuit_upgrades:get_player_upgrade_states(player_name)

      if upgrades then
        local upgrade
        local upgrade_stat

        for upgrade_name, upgrade_state in pairs(upgrades) do
          upgrade = hsw.nanosuit_upgrades.registered_upgrades[upgrade_name]
          if upgrade then
            if upgrade.stats then
              upgrade_stat = upgrade.stats[stat_name]
              if upgrade_stat then
                if upgrade_stat[modifier_name] then
                  value = upgrade_stat[modifier_name](upgrade, player, value)
                end
              end
            end
          end
        end
      end

      return value
    end)
  end
end
