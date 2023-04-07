--- @namespace harmonia_element

local player_data_service = assert(nokore.player_data_service)
local player_stats = assert(nokore.player_stats)

local get_player_stat = player_stats.get_player_stat
local set_player_stat = player_stats.set_player_stat

--- @class ElementSystem
local ElementSystem = foundation.com.Class:extends("harmonia_element.ElementSystem")

--- @const CraftingErrors: { [String]: Integer }
ElementSystem.CraftingErrors = {
  OK = 0,
  NOT_ENOUGH_ELEMENT = 1,
  NOT_ENOUGH_SPACE_FOR_ITEM = 2,
  BLUEPRINT_NOT_FOUND = 4,
}

--- @const States: { [String]: Integer }
ElementSystem.States = {
  NEW = 0,
  CRAFTING = 1,
  OUTPUT = 2,
}

do
  local ic = ElementSystem.instance_class

  --- @type ItemName: String

  --- @spec #initialize(): void
  function ic:initialize(options)
    self.m_blueprint_data_domain = assert(options.blueprint_data_domain)
    self.m_crafting_data_domain = assert(options.crafting_data_domain)
    -- @member registered_element_blueprints: {
    --   [blueprint_id: String]: ItemName
    -- }
    self.registered_element_blueprints = {}
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
      return player_data_service:with_player_domain_kv(
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
    local kv = player_data_service:get_player_domain_kv(player_name, self.m_blueprint_data_domain)

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
    local kv = player_data_service:get_player_domain_kv(player_name, self.m_blueprint_data_domain)

    if kv then
      return kv.data
    end

    return nil
  end

  --- @spec #get_player_element_crafting_kv(player_name: String): nokore.KeyValueStore
  function ic:get_player_element_crafting_kv(player_name)
    local kv = player_data_service:get_player_domain_kv(player_name, self.m_crafting_data_domain)

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
    local element_max = get_player_stat(player_stats, player, "element_max")
    local element = get_player_stat(player_stats, player, "element")
    local element_regen = get_player_stat(player_stats, player, "element_regen")
    local element_degen = get_player_stat(player_stats, player, "element_degen")

    -- element *gen
    local element_gen_time = assigns["element_gen_time"] or 0
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
          element = math.max(element - math.floor(element_max / element), 0)
        end
      end

      set_player_stat(player_stats, player, "element", element)
    end

    assigns["element_gen_time"] = element_gen_time
  end

  --- @spec #add_blueprint_to_crafting_queue(player_name: String): Boolean
  function ic:add_blueprint_to_crafting_queue(player_name, blueprint_id)
    local blueprint = self.registered_element_blueprints[blueprint_id]

    if blueprint then
      local kv = self:get_player_element_crafting_kv(player_name)

      if kv then
        local queue = kv:get("queue", {})
        local size = kv:get("size", 0)

        size = size + 1
        queue[size] = blueprint_id

        kv:put_all({
          queue = queue,
          size = size,
        })

        return true
      end
    end
    return false
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

      if size > 0 then
        return {
          current_item = queue[cursor],
          size = size,
          time = kv:get("time"),
          time_max = kv:get("time_max"),
          state = kv:get("state"),
          craft_error = kv:get("craft_error"),
        }
      end
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

  --- @spec #all_blueprint_crafting_queue(player_name: String): String
  function ic:all_blueprint_crafting_queue(player_name)
    local kv = self:get_player_element_crafting_kv(player_name)

    local result = {}

    if kv then
      local size = kv:get("size", 0)
      local cursor = kv:get("cursor", 0)
      local queue = kv:get("queue")

      if queue and size > 0 then
        local item
        for i = 1,size do
          item = queue[cursor + i]

          result[i] = item
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

        return kv:get("queue")[cursor]
      end
    end

    return nil
  end

  --- @spec #update_player_element_crafting(PlayerRef, dtime: Float, assigns: Table, Trace): void
  function ic:update_player_element_crafting(player, dt, assigns, trace)
    local player_name = player:get_player_name()

    local kv = self:get_player_element_crafting_kv(player_name)

    local queue = kv:get("queue")
    local size = kv:get("size", 0)

    if size <= 0 then
      -- abort early
      return
    end

    local cursor = kv:get("cursor", 0)
    local time = kv:get("time", 0.0)
    local time_max = kv:get("time_max", 0.0)
    local state = kv:get("state", ElementSystem.States.NEW)
    local craft_error = kv:get("craft_error", ElementSystem.CraftingErrors.OK)
    local should_save = false
    local should_break = false
    local available_element = get_player_stat(player_stats, player, "element")

    while queue and size > 0 do
      if state == ElementSystem.States.NEW then
        -- Try pulling a new blueprint off queue
        local blueprint_id = queue[cursor + 1]
        local blueprint = self.registered_element_blueprints[blueprint_id]

        if blueprint then
          if blueprint.cost < available_element then
            available_element = available_element - blueprint.cost
            set_player_stat(player_stats, player, "element", available_element)

            cursor = cursor + 1
            time = time + blueprint.duration
            time_max = blueprint.duration
            state = ElementSystem.States.CRAFTING
            craft_error = ElementSystem.CraftingErrors.OK
            should_save = true
          else
            craft_error = ElementSystem.CraftingErrors.NOT_ENOUGH_ELEMENT
            should_break = true
          end
        else
          -- increment cursor
          cursor = cursor + 1
          -- clear the current item
          queue[cursor] = nil
          -- decrement size
          size = size - 1
          craft_error = ElementSystem.CraftingErrors.BLUEPRINT_NOT_FOUND
          should_save = true
        end
      elseif state == ElementSystem.States.CRAFTING then
        if time > 0 then
          -- decrement time as needed
          time = time - dt
          should_save = true
        end

        if time <= 0 then
          state = ElementSystem.States.OUTPUT
          should_save = true
        else
          should_break = true
        end
      elseif state == ElementSystem.States.OUTPUT then
        local blueprint_id = queue[cursor]
        local blueprint = assert(self.registered_element_blueprints[blueprint_id])
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
          else
            craft_error = ElementSystem.CraftingErrors.NOT_ENOUGH_SPACE_FOR_ITEM
            should_save = true
          end
        else
          -- Skip the missing blueprint
          craft_error = ElementSystem.CraftingErrors.BLUEPRINT_NOT_FOUND
          should_advance = true
        end

        if should_advance then
          queue[cursor] = nil
          cursor = cursor + 1
          size = math.max(size - 1, 0)

          state = ElementSystem.States.NEW
          should_save = true
        end
      else
        -- Bad state, reset
        minetest.log("warning", "bad crafting state, returning to NEW")
        state = ElementSystem.States.NEW
        should_save = true
      end

      if size == 0 then
        cursor = 0
        time = 0.0
        time_max = 0.0
      end

      if should_save then
        kv:put_all({
          queue = queue,
          cursor = cursor,
          size = size,
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
