# Harmonia Passive

Harmonia Passive provides a managed system to apply passive effects to a player.

These can range from status effects to temporary buffs.

## API

The first step is to register a passive effect:

```lua
harmonia.passive.registry:register_passive("my_passive_name", {
  description = "My Passive Name",

  --- @optional
  --- @spec update(PassiveDefinition, PlayerRef, Float, Float, Integer, Float): (Float, Float)
  update = function (passive, player, time, time_max, counter, dtime)
    time = time - dtime
    return time, counter
  end,

  --- Modifies player stats, these should be static as stats are cached by default
  ---
  --- @optional
  stats = {
    [stat_name] = {
      --- @spec base(PassiveDefinition, PlayerRef, T): T
      base = function (_passive, _player, value)
        return value
      end,

      --- @spec add(PassiveDefinition, PlayerRef, T): T
      add = function (_passive, _player, value)
        return value + my_value
      end,

      --- @spec mul(PassiveDefinition, PlayerRef, T): T
      mul = function (_passive, _player, value)
        return value * my_multiplier
      end
    }
  }
})
```

Once registered, a passive effect can be applied to a player using:

```lua
passive.system:set_passive(player, "my_passive_name", {
  --- Apply 1 counter of the specified passive
  counters = 1,
  --- Apply it for 15 seconds
  duration = 15,
})
```
