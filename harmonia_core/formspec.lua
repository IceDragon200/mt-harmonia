--- @namespace harmonia.formspec
harmonia.formspec = harmonia.formspec or {}

if not harmonia.formspec.render_mana_gauge then
  local table_merge = assert(foundation.com.table_merge)

  --- @spec render_mana_gauge(RenderGaugeOptions): String
  function harmonia.formspec.render_mana_gauge(options)
    local amount = options.amount
    local max = options.max

    local new_options = table_merge({
      gauge_color = harmonia.config.colors.mana,
      border_name = "yatm_item_border_swirl.png",
      is_horz = false,
      tooltip = "Mana " .. amount .. " / " .. max
    }, options)

    return yatm.formspec.render_gauge(new_options)
  end
end

if not harmonia.formspec.render_corrupted_mana_gauge then
  local table_merge = assert(foundation.com.table_merge)

  --- @spec render_corrupted_mana_gauge(RenderGaugeOptions): String
  function harmonia.formspec.render_corrupted_mana_gauge(options)
    local amount = options.amount
    local max = options.max

    local new_options = table_merge({
      gauge_color = harmonia.config.colors.corrupted_mana,
      border_name = "yatm_item_border_swirl.png",
      is_horz = false,
      tooltip = "Corrupted Mana " .. amount .. " / " .. max
    }, options)

    return yatm.formspec.render_gauge(new_options)
  end
end
