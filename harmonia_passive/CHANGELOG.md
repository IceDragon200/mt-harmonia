# 0.2.0

* Added `PassiveDefinition#on_added/5`
* Added `PassiveDefinition#on_updated/5`
* Added `PassiveDefinition#on_expired/5`
* Added `PassiveDefinition#on_removed/5`
* Added `PassiveSystem#player_has_passive/2`
* Added `PassiveSystem#player_by_name_has_passive/2`
* Added `PassiveSystem#reduce_player_passives/3`
* Added `PassiveSystem#on_passive_added/2`
* Added `PassiveSystem#on_passive_changed/2`
* Added `PassiveSystem#on_passive_expired/2`
* Added `PassiveSystem#on_passive_removed/2`
* Adjusted `update` function on passives to include an `assigns` Table which can hold metadata for that passive
  * `update(passive, player, time, time_max, dtime)` is now update(passive, player, time, time_max, dtime, assigns)
* Fixed `dtime` not being passed to defined update functions
* Actually implement stat modifiers, as it was a copy of hsw_nanosuit's implementation, character for character (and wouldn't actually work correctly)
* Actually invalidate stats when a passive is added/removed, if the passive affects stats outside of its "stats" field, it must invalidate those by itself.
