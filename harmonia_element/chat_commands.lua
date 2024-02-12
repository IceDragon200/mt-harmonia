local mod = harmonia_element
local element = assert(harmonia.element)
local player_service = assert(nokore.player_service)

--- Helper command to unlock element blueprints by name
minetest.register_chatcommand("unlock_my_element_blueprint", {
  description = mod.S("Unlock an Element Blueprint for yourself"),

  params = mod.S("<blueprint_id>"),

  func = function (caller_name, blueprint_id)
    local player = player_service:get_player_by_name(caller_name)

    if player then
      if element:unlock_player_element_blueprint(caller_name, blueprint_id) then
        return true, "Blueprint unlocked"
      else
        return false, "Blueprint ID is invalid or cannot enable Blueprints at this time"
      end
    else
      return false, "Player not found"
    end
  end,
})
