--- @namespace harmonia_passive

--- @class PassiveDefinition
local PassiveDefinition = foundation.com.Class:extends("harmonia_passive.PassiveDefinition")
do
  local ic = assert(PassiveDefinition.instance_class)

  --- @spec #initialize(name: String, def: Table): void
  function ic:initialize(name, def)
    ic._super.initialize(self)
    assert(type(name) == "string", "expected name to be a string")
    assert(type(def) == "table", "expected definition to be a table")

    --- @member name: String
    self.name = name

    --- @member description: String
    self.description = assert(def.description, "expected passive to have a description")

    --- Called every tick for the passive to update itself, it is expected to return
    --- the time and counter.
    --- If not provided the default behaviour is assumed which will only subtract the dtime from
    --- @member def_update: (
    ---   self: PassiveDefinition,
    ---   player: PlayerRef,
    ---   time: Float,
    ---   time_max: Float,
    ---   counter: Integer,
    ---   dtime: Float,
    ---   assigns: Table
    --- ) => (time: Float, counter: Integer)
    self.def_update = def.update

    --- @member def_on_added: (
    ---   self: PassiveDefinition,
    ---   player: PlayerRef,
    ---   time: Float,
    ---   time_max: Float,
    ---   counter: Integer,
    ---   assigns: Table
    --- ): void
    self.def_on_added = def.on_added

    --- @member def_on_changed: (
    ---   self: PassiveDefinition,
    ---   player: PlayerRef,
    ---   time: Float,
    ---   time_max: Float,
    ---   counter: Integer,
    ---   assigns: Table
    --- ): void
    self.def_on_changed = def.on_changed

    --- @member def_on_expired: (
    ---   self: PassiveDefinition,
    ---   player: PlayerRef,
    ---   time: Float,
    ---   time_max: Float,
    ---   counter: Integer,
    ---   assigns: Table
    --- ): void
    self.def_on_expired = def.on_expired

    --- @member def_on_removed: (
    ---   self: PassiveDefinition,
    ---   player: PlayerRef,
    ---   time: Float,
    ---   time_max: Float,
    ---   counter: Integer,
    ---   assigns: Table
    --- ): void
    self.def_on_removed = def.on_removed

    --- Whenever the counter on the passive changes this callback will be called.
    ---
    --- @member (self, player: PlayerRef, counter: Integer, prev_counter: Integer) => void
    self.on_counter_changed = def.on_counter_changed

    --- When a passive's duration has expired, it will decrement its counter and reset its
    --- time to the last max it was set to.
    ---
    --- @member decrement_on_expire: Boolean
    self.decrement_on_expire = def.decrement_on_expire or false

    --- @member stats: Table
    self.stats = def.stats
  end

  --- @spec #on_added(PlayerRef, Float, Float, Integer, Table): void
  function ic:on_added(player, time, time_max, counter, assigns)
    if self.def_on_added then
      self:def_on_added(player, time, time_max, counter, assigns)
    end
  end

  --- @spec #on_changed(PlayerRef, Float, Float, Integer, Table): void
  function ic:on_changed(player, time, time_max, counter, assigns)
    if self.def_on_changed then
      self:def_on_changed(player, time, time_max, counter, assigns)
    end
  end

  --- @spec #on_expired(PlayerRef, Float, Float, Integer, Table): void
  function ic:on_expired(player, time, time_max, counter, assigns)
    if self.def_on_expired then
      self:def_on_expired(player, time, time_max, counter, assigns)
    end
  end

  --- @spec #on_removed(PlayerRef, Float, Float, Integer, Table): void
  function ic:on_removed(player, time, time_max, counter, assigns)
    if self.def_on_removed then
      self:def_on_removed(player, time, time_max, counter, assigns)
    end
  end

  --- @spec #update(
  ---   PlayerRef,
  ---   time: Float,
  ---   time_max: Float,
  ---   counter: Integer,
  ---   dtime: Float,
  ---   assigns: Table
  --- ): (time: Float, counter: Integer)
  function ic:update(player, time, time_max, counter, dtime, assigns)
    if self.def_update then
      time, counter = self:def_update(player, time, time_max, counter, dtime, assigns)
    else
      time = time - dtime
    end

    if time <= 0 then
      if self.decrement_on_expire then
        local prev_counter = counter
        counter = math.max(counter - 1, 0)
        if counter > 0 then
          if self.on_counter_changed then
            self:on_counter_changed(player, counter, prev_counter)
          end
          time = time_max
        end
      end
    end

    return time, counter
  end
end

harmonia_passive.PassiveDefinition = PassiveDefinition

--- @class PassiveRegistry
local PassiveRegistry = foundation.com.Class:extends("harmonia_passive.PassiveRegistry")
do
  local ic = assert(PassiveRegistry.instance_class)

  --- @spec #initialize(): void
  function ic:initialize()
    ic._super.initialize(self)

    self.registered = {}
  end

  --- @spec #register_passive(passive_name: String, def: Table): void
  function ic:register_passive(passive_name, def)
    assert(type(passive_name) == "string", "expected a string as the passive_name")
    assert(type(def) == "table", "expected a passive definition")

    if self.registered[passive_name] then
      error("passive already registered with id=" .. passive_name)
    end
    self.registered[passive_name] = PassiveDefinition:new(passive_name, def)
  end

  --- @spec #get_passive(passive_name: String): PassiveDefinition | nil
  function ic:get_passive(passive_name)
    return self.registered[passive_name]
  end
end

harmonia_passive.PassiveRegistry = PassiveRegistry
