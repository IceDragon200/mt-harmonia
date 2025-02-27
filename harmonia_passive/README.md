# Harmonia Passive

Harmonia Passive provides a managed system to apply continuous effects to a player.

These can range from status effects such as poison, blindness to temporary buffs.

This utilizes the player service provided by `nokore_player_service` and the `player_data_service` to store information on passives.

## Purpose

The passive system was designed to fix a very common problem: poison.

Or rather timed status effects, things such as poison over time, slow, haste and so forth.

## Quick Start

The first step is to register a passive effect:

```lua
--- The passive registry follows the convention of most APIs, being a name + table definition.
--- Passives need not be prefixed by their mod name only that they are unique.
harmonia.passive.registry:register_passive("my_passive_name", {
  description = "My Passive Name",

  --- Callback whenever the passive is newly set or added to a player
  ---
  --- @spec on_added(
  ---   passive: PassiveDefinition,
  ---   player: PlayerRef,
  ---   time: Float,
  ---   time_max: Float,
  ---   counter: Integer,
  ---   assigns: Table
  --- ): void
  on_added = function (passive, player, time, time_max, counters, assigns)
    ---
  end,

  --- Callback whenever the passive is added or recently "pushed" or otherwise updated.
  ---
  --- @spec on_changed(
  ---   passive: PassiveDefinition,
  ---   player: PlayerRef,
  ---   time: Float,
  ---   time_max: Float,
  ---   counter: Integer,
  ---   assigns: Table
  --- ): void
  on_changed = function (passive, player, time, time_max, counters, assigns)
    ---
  end,

  --- Callback whenever the passive expires, that is its time runs its course.
  ---
  --- @spec on_changed(
  ---   passive: PassiveDefinition,
  ---   player: PlayerRef,
  ---   time: Float,
  ---   time_max: Float,
  ---   counter: Integer,
  ---   assigns: Table
  --- ): void
  on_expired = function (passive, player, time, time_max, counters, assigns)
    ---
  end,

  --- Callback whenever the passive is removed either due to expiration or explictly removed.
  ---
  --- @spec on_removed(
  ---   passive: PassiveDefinition,
  ---   player: PlayerRef,
  ---   time: Float,
  ---   time_max: Float,
  ---   counter: Integer,
  ---   assigns: Table
  --- ): void
  on_removed = function (passive, player, time, time_max, counters, assigns)
    ---
  end,

  --- @optional
  --- @spec update(
  ---   passive: PassiveDefinition,
  ---   player: PlayerRef,
  ---   time: Float,
  ---   time_max: Float,
  ---   counter: Integer,
  ---   dtime: Float,
  ---   assigns: Table
  --- ): (time: Float, counter: Integer)
  update = function (passive, player, time, time_max, counters, dtime, assigns)
    time = time - dtime
    return time, counters
  end,

  --- Modifies player stats, these should be static as stats are cached by default
  ---
  --- @optional
  stats = {
    [stat_name] = {
      --- @spec base(PassiveDefinition, PlayerRef, T, Float, Float, Integer, Table): T
      base = function (_passive, _player, value, time, time_max, counters, assigns)
        return value
      end,

      --- @spec add(PassiveDefinition, PlayerRef, T, Float, Float, Integer, Table): T
      add = function (_passive, _player, value, time, time_max, counters, assigns)
        return value + my_value
      end,

      --- @spec mul(PassiveDefinition, PlayerRef, T, Float, Float, Integer, Table): T
      mul = function (_passive, _player, value, time, time_max, counters, assigns)
        return value * my_multiplier
      end
    }
  }
})
```

Once registered, a passive effect can be applied to a player using:

```lua
harmonia.passive.system:set_passive(player, "my_passive_name", {
  --- Apply 1 counter of the specified passive
  counters = 1,
  --- Apply it for 15 seconds
  duration = 15,
})
```

Or it can be stacked/added with:

```lua
harmonia.passive.system:push_passive(player, "my_passive_name", {
  --- Apply 1 counter of the specified passive
  counters = 1,
  --- Apply it for 15 seconds
  duration = 15,
})
```

## Passive Hooks

The passive system will prioritize the passive's hooks first, and then its own internal hooks before issuing any global or external hooks.

That is:
* `passive#on_*` callbacks
* INTERNAL functions (such as invalidating player stats)
* `on_passive_*` callbacks

## Global Hooks

While every passive has its own hooks: `on_added`, `on_changed`, `on_expired`, `on_removed`, it may be useful to also monitor ANY passive of its changes.

As such, the passive system itself provides the familiar `on_*` callbacks:
* `on_passive_added(passive, player, time, time_max, counters, assigns)`
* `on_passive_changed(passive, player, time, time_max, counters, assigns)`
* `on_passive_expired(passive, player, time, time_max, counters, assigns)`
* `on_passive_removed(passive, player, time, time_max, counters, assigns)`

Then can registered with:

```lua
harmonia.passive.system:on_passive_added('my_callback_name', function (passive, player, time, time_max, counters, assigns)
  --- Do whatever you like
end)

harmonia.passive.system:on_passive_changed('my_callback_name', function (passive, player, time, time_max, counters, assigns)
  --- Do whatever you like
end)

harmonia.passive.system:on_passive_expired('my_callback_name', function (passive, player, time, time_max, counters, assigns)
  --- Do whatever you like
end)

harmonia.passive.system:on_passive_removed('my_callback_name', function (passive, player, time, time_max, counters, assigns)
  --- Do whatever you like
end)
```

### What am I allowed to do within these hooks?

Anything except modify the given data.

`assigns` can be modified, but the passive system makes no guarantees that these changes will be persisted.

## Passive's Life Cycle

Passive's have a fairly simple life cycle:

* Added
* Changed
* Expired
* Removed

When a passive is first applied to a player it will be considered `added` AND `changed`.

When a passive is allowed to run its course and its time becomes 0 or less, it will be considered `expired`, immediately after it will be `removed`.

A passive will be considered changed if its `counters` changes during an `update`.

## Architecture

The passives system is built upon the player data service provided by `nokore_player_service` as such it uses the update_players/3 callback infrastructure.

Every step, all registered players will undergo the passive tick.

Passives are stored not as a single object, but across multiple tables as their raw values (that is, its time, time_max, counter, and assigns are in different tables of the same typing).

This data is housed by the `nokore_player_data` service on the `harmonia_passive` domain.
