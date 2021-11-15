local NyctophobiaSystem = foundation.com.Class:extends("NyctophobiaSystem")
local ic = NyctophobiaSystem.instance_class

function ic:initialize()
  --
  self.elapsed = 0
  self.timer = 0

  self.multiplier_callbacks = {}
end

--
-- Register a multiplier callback
-- This callback is called when nyctophobia needs to calculate the scale/multiplier
-- for the nyctophobia effect, particularly it's duration calculations
--
-- @type MultiplierCallback :: (player: Player, scale: Float, delta: Float) => (scale: Float)
-- @spec register_multiplier(name: String, MultiplierCallback) :: void
function ic:register_multiplier(name, callback)
  if self.multiplier_callbacks[name] then
    error("multiplier callback is already registered name=" .. name)
  end
  assert(callback, "expected a callback")
  self.multiplier_callbacks[name] = callback
end

-- @spec unregister_multiplier(name: String) :: void
function ic:unregister_multiplier(name)
  self.multiplier_callbacks[name] = nil
end

function ic:init()
  --
  minetest.log("info", "nyctophobia enters the realm")
end

function ic:terminate()
  --
  minetest.log("info", "nyctophobia fades away")
end

function ic:update(delta)
  self.elapsed = self.elapsed + delta
  self.timer = self.timer + delta

  while self.timer > 1 do
    self.timer = self.timer - 1
    if minetest.settings:get_bool("enable_damage") then
      self:_perform_step(1)
    end
  end
end

function ic:_perform_step(delta)
  --
  local tod = minetest.get_timeofday()

  local players = minetest.get_connected_players()

  -- day is between 06:00 and (0.75: 18:00)
  -- so night is everything else
  if tod < 0.25 or tod >= 0.80 then
    for _, player in pairs(players) do
      self:_perform_step_on_player(player, delta)
    end
  else
    for _, player in pairs(players) do
      local meta = player:get_meta()

      if meta:get_int("nyctophobia_flag") ~= 0 then
        meta:set_int("nyctophobia_flag", 0)
        meta:set_int("nyctophobia_level", 0)

        minetest.chat_send_player(player:get_player_name(), "The darkness fades...")
      end
    end
  end
end

local function inflict_damage(player, amount, nyctophobia_level)
  minetest.log("action", "nyctophobia strikes player " .. player:get_player_name())
  player:set_hp(player:get_hp() - amount, { type = 'set_hp',
                                            subtype = 'nyctophobia',
                                            damage = amount,
                                            level = nyctophobia_level })
end

function ic:_perform_step_on_player(player, delta)
  local meta = player:get_meta()

  if meta:get_int("nyctophobia_flag") == 0 then
    -- the entity is now under the effect of nyctophobia
    meta:set_int("nyctophobia_flag", 1)

    minetest.chat_send_player(player:get_player_name(), "The night encroaches...")
  end

  if meta:get_int("nyctophobia_flag") ~= 0 then
    local pos = vector.floor(player:get_pos())
    local light_level = minetest.get_node_light(pos)
    local nyctophobia_duration = meta:get_float("nyctophobia_duration")
    local nyctophobia_level = meta:get_int("nyctophobia_level")
    if light_level and light_level < 8 then
      -- every step is handled in blocks of a second
      -- this is how long an entity has spent total under the effect of nyctophobia
      meta:set_float("nyctophobia_duration_total", meta:get_float("nyctophobia_duration_total") + delta)
      -- this is how long an entity has spent under nyctophobia recently, this value resets on higher light values
      -- nyctophobia damage can take place
      local scale = 2 * (8 - light_level) / 8

      for _name, callback in pairs(self.multiplier_callbacks) do
        scale = callback(player, scale, delta)
      end

      nyctophobia_duration = nyctophobia_duration + delta * scale

      if nyctophobia_duration >= 1 and nyctophobia_level <= 0 then
        -- This is stage one of the effect, no damage is applied at this level
        nyctophobia_level = 1
        minetest.chat_send_player(player:get_player_name(), "You hear faint voices...")
      elseif nyctophobia_duration >= 15 and nyctophobia_level < 2 then
        -- This is stage two, the player will take periodic damage
        nyctophobia_level = 2
        minetest.chat_send_player(player:get_player_name(), "The voices are getting louder...")
      elseif nyctophobia_duration >= 30 and nyctophobia_level < 3 then
        -- This is stage three, the player will take periodic damage
        nyctophobia_level = 3
        minetest.chat_send_player(player:get_player_name(), "The voices are nearby...")
      elseif nyctophobia_duration >= 60 and nyctophobia_level < 4 then
        -- This is stage four, the player will take periodic damage (faster)
        nyctophobia_level = 4
        minetest.chat_send_player(player:get_player_name(), "The voices are in your head...")
      elseif nyctophobia_duration >= 120 and nyctophobia_level < 5 then
        -- This is stage four, the player will take periodic damage (even faster, player becomes slow)
        nyctophobia_level = 5
        minetest.chat_send_player(player:get_player_name(), "Your mind has become fuddled...")
      elseif nyctophobia_duration >= 125 and nyctophobia_level < 6 then
        -- This is stage four, the player will take periodic greater damage (even faster, player becomes slow)
        nyctophobia_level = 6
        minetest.chat_send_player(player:get_player_name(), "You should have ran...")
      elseif nyctophobia_duration >= 150 then
        nyctophobia_duration = 150
      end

      meta:set_float("nyctophobia_duration", nyctophobia_duration)
      local nyctophobia_damage_duration = meta:get_float("nyctophobia_damage_duration")
      nyctophobia_damage_duration = nyctophobia_damage_duration + delta

      if nyctophobia_level == 0 then
        -- nothing
        nyctophobia_damage_duration = 0
      elseif nyctophobia_level == 1 then
        -- nothing yet
        nyctophobia_damage_duration = 0
      elseif nyctophobia_level == 2 then
        -- periodic damage
        if nyctophobia_damage_duration >= 5 then
          nyctophobia_damage_duration = 0
          inflict_damage(player, 0.5, nyctophobia_level)
        end
      elseif nyctophobia_level == 3 then
        -- periodic damage
        if nyctophobia_damage_duration >= 5 then
          nyctophobia_damage_duration = 0
          inflict_damage(player, 1, nyctophobia_level)
        end
      elseif nyctophobia_level == 4 then
        -- faster periodic damage
        if nyctophobia_damage_duration >= 3 then
          nyctophobia_damage_duration = 0
          inflict_damage(player, 1, nyctophobia_level)
        end
      elseif nyctophobia_level == 5 then
        -- faster periodic damage and slow
        if nyctophobia_damage_duration >= 3 then
          nyctophobia_damage_duration = 0
          inflict_damage(player, 1, nyctophobia_level)
        end
      elseif nyctophobia_level > 5 then
        -- even faster periodic damage and slower
        if nyctophobia_damage_duration >= 2 then
          nyctophobia_damage_duration = 0
          inflict_damage(player, 1, nyctophobia_level)
        end
      end
      meta:set_float("nyctophobia_damage_duration", nyctophobia_damage_duration)
    elseif light_level then
      if meta:get_float("nyctophobia_duration") > 0 then
        nyctophobia_duration = math.max(nyctophobia_duration - 2, 0)
        meta:set_float("nyctophobia_duration", nyctophobia_duration)

        if nyctophobia_duration < 1 and nyctophobia_level > 0 then
          nyctophobia_level = 0
          minetest.chat_send_player(player:get_player_name(), "The voices fade, for the moment...")
        elseif nyctophobia_duration < 10 and nyctophobia_level > 1 then
          nyctophobia_level = 1
          minetest.chat_send_player(player:get_player_name(), "The voices are becoming quiet...")
        elseif nyctophobia_duration < 30 and nyctophobia_level > 2 then
          nyctophobia_level = 2
          minetest.chat_send_player(player:get_player_name(), "The voices are becoming distant...")
        elseif nyctophobia_duration < 60 and nyctophobia_level > 3 then
          nyctophobia_level = 3
          minetest.chat_send_player(player:get_player_name(), "The voices have left your head...")
        elseif nyctophobia_duration < 120 and nyctophobia_level > 4 then
          nyctophobia_level = 4
          minetest.chat_send_player(player:get_player_name(), "Your head has become clear...")
        elseif nyctophobia_duration < 125 and nyctophobia_level > 5 then
          nyctophobia_level = 5
          minetest.chat_send_player(player:get_player_name(), "You have escaped, for now...")
        end
      end
    end

    meta:set_int("nyctophobia_level", nyctophobia_level)
  end
end

local nyctophobia_system = NyctophobiaSystem:new()

minetest.register_on_mods_loaded(nyctophobia_system:method("init"))
nokore_proxy.register_globalstep(
  "nyctophobia_system.update/1",
  nyctophobia_system:method("update")
)
minetest.register_on_shutdown(nyctophobia_system:method("terminate"))

harmonia_nyctophobia.nyctophobia_system = nyctophobia_system
