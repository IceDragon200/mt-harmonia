--- @namespace harmonia_element

--- @class ElementSystem
local ElementSystem = foundation.com.Class:extends("harmonia_element.ElementSystem")

--- @type CraftError: Integer

--- @const CraftingErrors: { [String]: CraftError }
ElementSystem.CraftingErrors = {
  OK = 0,
  NOT_ENOUGH_ELEMENT = 1,
  NOT_ENOUGH_SPACE_FOR_ITEM = 2,
  BLUEPRINT_NOT_FOUND = 4,
  PLAYER_NOT_FOUND = 5,
}

--- @type CraftState: Integer

--- @const States: { [String]: CraftState }
ElementSystem.States = {
  NEW = 0,
  CRAFTING = 1,
  OUTPUT = 2,
}

--- @type Blueprint: {
---   id: String,
---   name: String,
---   cost: Integer,
---   duration: Float,
--- }

--- @type CraftEvent: {
---   type: String,
---   player_name: String,
---   player: PlayerRef,
---   blueprint_id: String,
---   blueprint: Blueprint,
---   time: Float,
---   time_max: Float,
---   state: CraftState,
---   craft_error: CraftError,
--- }

do
  local ic = ElementSystem.instance_class

  --- @type ItemName: String

  --- @type CraftEventCallback: (CraftEvent) => void

  --- @spec #initialize(options: Table): void
  function ic:initialize(options)
    self.m_player_data_service = assert(options.player_data_service)
    self.m_player_stats = assert(options.player_stats)
    self.m_blueprint_data_domain = assert(options.blueprint_data_domain)
    self.m_crafting_data_domain = assert(options.crafting_data_domain)

    --- @member registered_on_craft_started: {
    ---   [name: String]: CraftEventCallback
    --- }
    self.registered_on_craft_started = {}

    --- @member registered_on_craft_crafting: {
    ---   [name: String]: CraftEventCallback
    --- }
    self.registered_on_craft_crafting = {}

    --- @member registered_on_craft_error: {
    ---   [name: String]: CraftEventCallback
    --- }
    self.registered_on_craft_error = {}

    --- @member registered_on_craft_completed: {
    ---   [name: String]: CraftEventCallback
    --- }
    self.registered_on_craft_completed = {}

    --- @member registered_element_blueprints: {
    ---   [blueprint_id: String]: Blueprint
    --- }
    self.registered_element_blueprints = {}
  end

  --- @spec #register_on_craft_started(name: String, callback: CraftEventCallback): Boolean
  function ic:register_on_craft_started(name, callback)
    if self.registered_on_craft_started[name] then
      error("cannot register on_craft_started callback name=" .. name)
    end

    self.registered_on_craft_started[name] = callback

    return true
  end

  --- @spec #unregister_on_craft_started(name: String): Boolean
  function ic:unregister_on_craft_started(name)
    self.registered_on_craft_started[name] = nil
    return true
  end

  --- @spec #register_on_craft_crafting(name: String, callback: CraftEventCallback): Boolean
  function ic:register_on_craft_crafting(name, callback)
    if self.registered_on_craft_crafting[name] then
      error("cannot register on_craft_crafting callback name=" .. name)
    end

    self.registered_on_craft_crafting[name] = callback

    return true
  end

  --- @spec #unregister_on_craft_crafting(name: String): Boolean
  function ic:unregister_on_craft_crafting(name)
    self.registered_on_craft_crafting[name] = nil
    return true
  end

  --- @spec #register_on_craft_error(name: String, callback: CraftEventCallback): Boolean
  function ic:register_on_craft_error(name, callback)
    if self.registered_on_craft_error[name] then
      error("cannot register on_craft_error callback name=" .. name)
    end

    self.registered_on_craft_error[name] = callback

    return true
  end

  --- @spec #unregister_on_craft_error(name: String): Boolean
  function ic:unregister_on_craft_error(name)
    self.registered_on_craft_error[name] = nil
    return true
  end

  --- @spec #register_on_craft_completed(name: String, callback: CraftEventCallback): Boolean
  function ic:register_on_craft_completed(name, callback)
    if self.registered_on_craft_completed[name] then
      error("cannot register on_craft_completed callback name=" .. name)
    end

    self.registered_on_craft_completed[name] = callback

    return true
  end

  --- @spec #unregister_on_craft_completed(name: String): Boolean
  function ic:unregister_on_craft_completed(name)
    self.registered_on_craft_completed[name] = nil
    return true
  end

  --- @spec #trigger_on_craft_started(event: CraftEvent): void
  function ic:trigger_on_craft_started(event)
    for _name, callback in pairs(self.registered_on_craft_started) do
      callback(event)
    end
  end

  --- @spec #trigger_on_craft_crafting(event: CraftEvent): void
  function ic:trigger_on_craft_crafting(event)
    for _name, callback in pairs(self.registered_on_craft_crafting) do
      callback(event)
    end
  end

  --- @spec #trigger_on_craft_error(event: CraftEvent): void
  function ic:trigger_on_craft_error(event)
    for _name, callback in pairs(self.registered_on_craft_error) do
      callback(event)
    end
  end

  --- @spec #trigger_on_craft_completed(event: CraftEvent): void
  function ic:trigger_on_craft_completed(event)
    for _name, callback in pairs(self.registered_on_craft_completed) do
      callback(event)
    end
  end

  --- Toggles an element blueprint for a specific player
  ---
  --- @spec #toggle_player_element_blueprint(
  ---         player_name: String,
  ---         blueprint_id: String,
  ---         value: Boolean | nil
  ---       ): Boolean
  function ic:toggle_player_element_blueprint(player_name, blueprint_id, value)
    if self.registered_element_blueprints[blueprint_id] then
      return self.m_player_data_service:with_player_domain_kv(
        player_name,
        self.m_blueprint_data_domain,
        function (kv_store)
          kv_store:put(blueprint_id, value)
          return true
        end
      )
    end
    return false
  end

  --- Unlocks an element blueprint for a specific player.
  --- Returns true if the blueprint was unlocked, false if inaccessible.
  ---
  --- @spec #unlock_player_element_blueprint(player_name: String, blueprint_id: String): Boolean
  function ic:unlock_player_element_blueprint(player_name, blueprint_id)
    return self:toggle_player_element_blueprint(player_name, blueprint_id, true)
  end

  --- Locks a player's blueprint.
  --- Returns true if the blueprint was locked, false if inaccesible.
  ---
  --- @spec #lock_player_element_blueprint(player_name: String, blueprint_id: String): Boolean
  function ic:lock_player_element_blueprint(player_name, blueprint_id)
    return self:toggle_player_element_blueprint(player_name, blueprint_id, nil)
  end

  --- Determines if a player has a specific blueprint.
  ---
  --- @spec #player_has_element_blueprint(player_name: String, blueprint_id: String): Boolean
  function ic:player_has_element_blueprint(player_name, blueprint_id)
    local kv = self.m_player_data_service:get_player_domain_kv(player_name, self.m_blueprint_data_domain)

    if kv then
      return kv:get(blueprint_id) == true
    end

    return false
  end

  --- Retrieves the blueprint unlock map for the specified player
  --- Note that the table returned is the raw underlying key-value map.
  --- Under no circumstance should the caller try to modify this table as it can
  --- compromise the integrity of the key-value store.
  ---
  --- @spec #get_player_element_blueprints(
  ---   player_name: String
  --- ): { [element_blueprint_id: String]: Boolean } | nil
  function ic:get_player_element_blueprints(player_name)
    local kv = self.m_player_data_service:get_player_domain_kv(player_name, self.m_blueprint_data_domain)

    if kv then
      return kv.data
    end

    return nil
  end

  --- @spec #get_player_element_crafting_kv(player_name: String): nokore.KeyValueStore
  function ic:get_player_element_crafting_kv(player_name)
    local kv = self.m_player_data_service:get_player_domain_kv(player_name, self.m_crafting_data_domain)

    if kv then
      return kv
    end

    return nil
  end

  --- @spec #update_player_element_gen(PlayerRef, dtime: Float, assigns: Table, Trace): void
  function ic:update_player_element_gen(player, dt, assigns, trace)
    --
    -- element regeneration
    --
    local player_stats = self.m_player_stats

    local element_max = player_stats:get_player_stat(player, "element_max")
    local element = player_stats:get_player_stat(player, "element")
    local element_regen = player_stats:get_player_stat(player, "element_regen")
    local element_degen = player_stats:get_player_stat(player, "element_degen")

    -- element *gen
    local element_gen_time = assigns.element_gen_time or 0
    element_gen_time = element_gen_time + dt

    if element_gen_time > 1 then
      element_gen_time = element_gen_time - 1

      if element_regen > 0 then
        -- element is allowed to overflow
        if element < element_max then
          -- but if it's under the max, it will cap it instead
          element = math.min(element + element_regen, element_max)
        end
      end

      if element_degen > 0 then
        -- only try degen if the element is greater than zero
        if element > 0 then
          element = math.max(element - element_degen, 0)
        end
      end

      if element > element_max then
        -- handle element overflow
        if element > 0 then
          element = math.max(element - math.floor(element / element_max), 0)
        end
      end

      player_stats:set_player_stat(player, "element", element)
    end

    assigns.element_gen_time = element_gen_time
  end

  --- @spec #add_blueprint_to_crafting_queue(player_name: String): (added: Boolean, err: Any)
  function ic:add_blueprint_to_crafting_queue(player_name, blueprint_id)
    local blueprint = self.registered_element_blueprints[blueprint_id]

    if blueprint then
      local kv = self:get_player_element_crafting_kv(player_name)

      if kv then
        local data = kv.data
        local queue = data.queue or {}
        local size = data.size or 0
        local head = data.head or 0
        local tail = data.tail or 0

        if size < 1 then
          head = 1
        end
        size = size + 1
        tail = tail + 1
        queue[tail] = blueprint_id

        data.queue = queue
        data.size = size
        data.head = head
        data.tail = tail
        kv:mark_dirty()

        return true, ElementSystem.CraftingErrors.OK
      else
        return false, ElementSystem.CraftingErrors.PLAYER_NOT_FOUND
      end
    end

    return false, ElementSystem.CraftingErrors.BLUEPRINT_NOT_FOUND
  end

  --- Clears blueprint crafting queue for specific player.
  --- Returns true if queue was cleared, false otherwise.
  ---
  --- @spec #clear_blueprint_crafting_queue(player_name: String): Boolean
  function ic:clear_blueprint_crafting_queue(player_name)
    local kv = self:get_player_element_crafting_kv(player_name)

    if kv then
      kv:put_all({
        queue = {},
        size = 0,
        head = 0,
        tail = 0,
        cursor = 0,
        time = 0.0,
        time_max = 0.0,
        state = ElementSystem.States.NEW,
        craft_error = ElementSystem.CraftingErrors.OK,
      })
      return true
    end

    return false
  end

  --- Retrieve overview of queue, primarily for UI
  ---
  --- @spec #get_blueprint_crafting_queue_overview(player_name: String): Table
  function ic:get_blueprint_crafting_queue_overview(player_name)
    local kv = self:get_player_element_crafting_kv(player_name)

    if kv then
      local queue = kv:get("queue")
      local size = kv:get("size", 0)
      local cursor = kv:get("cursor")
      local state = kv:get("state")
      local time = kv:get("time")
      local time_max = kv:get("time_max")
      local craft_error = kv:get("craft_error")
      local current_item
      local next_item

      if size > 0 then
        current_item = queue[cursor]
        next_item = queue[cursor + 1]
      end

      return {
        current_item = current_item,
        next_item = next_item,
        size = size,
        time = time,
        time_max = time_max,
        state = state,
        craft_error = craft_error,
      }
    end

    return nil
  end

  --- Determines if a player's crafting queue is empty.
  --- Returns true if the queue is empty or there was no queue for the player name.
  --- Returns false otherwise.
  ---
  --- @spec #is_blueprint_crafting_queue_empty(player_name: String): Boolean
  function ic:is_blueprint_crafting_queue_empty(player_name)
    local kv = self:get_player_element_crafting_kv(player_name)

    if kv then
      return kv:get("size", 0) == 0
    end

    return true
  end

  --- @spec #all_blueprint_crafting_queue(player_name: String): [String]
  function ic:all_blueprint_crafting_queue(player_name)
    local kv = self:get_player_element_crafting_kv(player_name)

    local result = {}

    if kv then
      local size = kv:get("size", 0)
      local queue = kv:get("queue")

      if queue and size > 0 then
        local head = kv:get("head", 0)
        local tail = kv:get("tail", 0)

        local item
        local idx = 0
        for i = head,tail do
          idx = idx + 1
          item = queue[i]

          result[idx] = item
        end
      end
    end

    return result
  end

  --- @spec #peek_blueprint_crafting_queue(player_name: String): String
  function ic:peek_blueprint_crafting_queue(player_name)
    local kv = self:get_player_element_crafting_kv(player_name)

    if kv then
      if kv:get("size", 0) > 0 then
        local cursor = kv:get("cursor")
        local queue = kv:get("queue")

        if queue then
          return queue[cursor]
        end
      end
    end

    return nil
  end

  --- @spec #update_player_element_crafting(PlayerRef, dtime: Float, assigns: Table, Trace): void
  function ic:update_player_element_crafting(player, dt, assigns, trace)
    local player_name = player:get_player_name()

    local kv = self:get_player_element_crafting_kv(player_name)
    local data = kv.data

    local queue = data.queue
    local size = data.size or 0

    if size < 1 then
      -- abort early
      return
    end

    local player_stats = self.m_player_stats

    local cursor = data.cursor or 0
    local head = data.head or 0.0
    local tail = data.tail or 0.0
    local time = data.time or 0.0
    local time_max = data.time_max or 0.0
    local state = data.state or ElementSystem.States.NEW
    local craft_error = data.craft_error or ElementSystem.CraftingErrors.OK

    local should_save = false
    local should_break = false
    local available_element = player_stats:get_player_stat(player, "element")

    local emit_event
    local event
    local blueprint_id
    local blueprint

    while queue and size > 0 do
      if state == ElementSystem.States.NEW then
        -- Try pulling a new blueprint off queue
        blueprint_id = queue[cursor + 1]
        blueprint = self.registered_element_blueprints[blueprint_id]

        if blueprint then
          if blueprint.cost <= available_element then
            available_element = available_element - blueprint.cost
            player_stats:set_player_stat(player, "element", available_element)

            cursor = cursor + 1
            time = time + blueprint.duration
            time_max = blueprint.duration
            state = ElementSystem.States.CRAFTING
            craft_error = ElementSystem.CraftingErrors.OK
            should_save = true

            emit_event = "craft.started"
          else
            craft_error = ElementSystem.CraftingErrors.NOT_ENOUGH_ELEMENT
            should_save = true
            should_break = true

            emit_event = "craft.error"
          end
        else
          -- increment cursor
          cursor = cursor + 1
          -- increase the head, since the item is being removed
          -- clear the current item
          queue[head] = nil
          head = head + 1
          -- decrement size
          size = size - 1
          craft_error = ElementSystem.CraftingErrors.BLUEPRINT_NOT_FOUND
          should_save = true

          emit_event = "craft.error"
        end
      elseif state == ElementSystem.States.CRAFTING then
        if time > 0 then
          -- decrement time as needed
          time = time - dt
          should_save = true
          emit_event = "craft.crafting"
        end

        if time <= 0 then
          state = ElementSystem.States.OUTPUT
          should_save = true
        else
          should_break = true
        end
      elseif state == ElementSystem.States.OUTPUT then
        blueprint_id = queue[cursor]
        blueprint = assert(self.registered_element_blueprints[blueprint_id])
        -- whether or not to advance to the next state
        local should_advance = false

        if blueprint then
          local item_name = blueprint.name
          local item_stack = ItemStack(item_name)

          local inv = player:get_inventory()
          local leftover = inv:add_item("main", item_stack)

          if leftover:is_empty() then
            craft_error = ElementSystem.CraftingErrors.OK
            should_save = true
            should_advance = true

            emit_event = "craft.completed"
          else
            craft_error = ElementSystem.CraftingErrors.NOT_ENOUGH_SPACE_FOR_ITEM
            should_save = true

            emit_event = "craft.error"
          end
        else
          -- Skip the missing blueprint
          craft_error = ElementSystem.CraftingErrors.BLUEPRINT_NOT_FOUND
          should_advance = true

          emit_event = "craft.error"
        end

        if should_advance then
          queue[head] = nil
          head = head + 1
          size = size - 1

          state = ElementSystem.States.NEW
          should_save = true
        end
      else
        -- Bad state, reset
        minetest.log("warning", "bad crafting state, returning to NEW")
        state = ElementSystem.States.NEW
        should_save = true

        emit_event = "craft.error"
      end

      if emit_event then
        event = {
          type = emit_event,
          player_name = player_name,
          player = player,
          blueprint_id = blueprint_id,
          blueprint = blueprint,
          time = time,
          time_max = time_max,
          state = state,
          craft_error = craft_error,
        }

        -- print(event.type,
        --   "time=" .. event.time ..
        --   " time_max=" .. event.time_max ..
        --   " head=" .. head ..
        --   " tail=" .. tail ..
        --   " size=" .. size ..
        --   " blueprint_id=" .. dump(blueprint_id)
        -- )

        if emit_event == "craft.started" then
          self:trigger_on_craft_started(event)
        elseif emit_event == "craft.crafting" then
          self:trigger_on_craft_crafting(event)
        elseif emit_event == "craft.error" then
          self:trigger_on_craft_error(event)
        elseif emit_event == "craft.completed" then
          self:trigger_on_craft_completed(event)
        end

        emit_event = nil
      end

      if size < 1 then
        -- reset values
        cursor = 0
        head = 0
        tail = 0
        time = 0.0
        time_max = 0.0

        should_save = true
      end

      if should_save then
        kv:put_all({
          queue = queue,
          cursor = cursor,
          size = size,
          head = head,
          tail = tail,
          time = time,
          time_max = time_max,
          state = state,
          craft_error = craft_error,
        })
      end

      if should_break then
        break
      end
    end
  end

  --- @spec #update_players(
  ---   { [player_name: String]: PlayerRef },
  ---   dt: Float,
  ---   assigns: Table,
  ---   trace: Trace
  --- ): void
  function ic:update_players(players, dt, assigns, trace)
    local player_assigns

    for player_name, player in pairs(players) do
      player_assigns = assigns[player_name]

      self:update_player_element_gen(player, dt, player_assigns, trace)
      self:update_player_element_crafting(player, dt, player_assigns, trace)
    end
  end
end

harmonia_element.ElementSystem = ElementSystem
