harmonia = rawget(_G, "harmonia") or {}
harmonia.mana = harmonia.mana or {}

local player_service = assert(nokore.player_service)
local player_stats = assert(nokore.player_stats)

local function maybe_refresh_player_hud(player, player_assigns)
  if nokore.player_hud then
    local mana = player_assigns["last_mana"]
    local mana_max = player_assigns["last_mana_max"]

    if mana_max > 0 then
      local amount = 20 * mana / mana_max
      local max = 20

      nokore.player_hud:upsert_player_hud_element(player, "mana", {
        number = amount,
        item = max,
      })
    else
      nokore.player_hud:remove_player_hud_element(player, "mana")
    end
  end
end

-- The Mana system's update hook
player_service:register_update(
  "harmonia_mana:update_players",
  function (players, dt, players_assigns)
    local mana
    local mana_max
    local mana_regen
    local mana_degen
    local mana_gen_time
    local player_assigns

    for player_name, player in pairs(players) do
      player_assigns = players_assigns[player_name]
      mana_max = player_stats:get_player_stat(player, "mana_max")
      mana = player_stats:get_player_stat(player, "mana")
      mana_regen = player_stats:get_player_stat(player, "mana_regen")
      mana_degen = player_stats:get_player_stat(player, "mana_degen")

      mana_gen_time = player_assigns["mana_gen_time"] or 0
      mana_gen_time = mana_gen_time + dt

      if mana_gen_time > 1 then
        mana_gen_time = mana_gen_time - 1

        if mana_regen > 0 then
          -- mana is allowed to overflow
          if mana < mana_max then
            -- but if it's under the max, it will cap it instead
            mana = math.min(mana + mana_regen, mana_max)
          end
        end

        if mana_degen > 0 then
          -- only try degen if the mana is greater than zero
          if mana > 0 then
            mana = math.max(mana - mana_degen, 0)
          end
        end

        player_stats:set_player_stat(player, "mana", mana)
      end

      player_assigns["mana_gen_time"] = mana_gen_time

      if player_assigns["last_mana"] ~= mana or player_assigns["last_mana_max"] ~= mana_max then
        player_assigns["last_mana"] = mana
        player_assigns["last_mana_max"] = mana_max

        maybe_refresh_player_hud(player, player_assigns)
      end
    end
  end
)

if rawget(_G, "hb") then
  nokore.player_service:register_on_player_join("harmonia_mana:init_hb", function (player)
    hb.init_hudbar(player, 'mana', 10, 10, false)
  end)

  hb.register_hudbar("mana",
                     0xFFFFFF,
                     "Mana",
                     { icon = "harmonia_hudbar_mana_icon.png",
                       bgicon = "harmonia_hudbar_mana_bgicon.png",
                       bar = "harmonia_hudbar_mana.png" },
                     0,
                     10, false)
end

if foundation.is_module_present("nokore_player_hud") then
  nokore.player_hud:register_hud_element("mana", {
    hud_elem_type = "statbar",
    position = {
      x = 0.5,
      y = 1,
    },
    text = "harmonia_mana_full.png",
    text2 = "harmonia_mana_empty.png",
    number = 20,
    item = 20,
    direction = nokore.player_hud.DIRECTION_LEFT_RIGHT,
    size = {x = 24, y = 24},
    offset = {
      x = 24,
      -- -(hotbar_height + icon_height + bottom_padding + margin + offset)
      y = -(48 + 24 + 16 + 8 + 32)
    },
  })

  nokore.player_hud:register_on_init_player_hud_element(
    "harmonia_mana:mana_init",
    "mana",
    function (player, _elem_name, hud_def)
      local mana_max = player_stats:get_player_stat(player, "mana_max")

      if mana_max > 0 then
        return hud_def
      end

      return nil
    end
  )
end
