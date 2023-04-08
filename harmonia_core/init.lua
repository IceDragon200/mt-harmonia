local mod = foundation.new_module("harmonia_core", "1.0.0")

harmonia = rawget(_G, "harmonia") or {}
harmonia.config = harmonia.config or {}

harmonia.config.colors = harmonia.config.colors or {}
harmonia.config.colors.mana = harmonia.config.colors.mana or "#68959d"
harmonia.config.colors.corrupted_mana = harmonia.config.colors.mana or "#312c45"

harmonia.formspec = harmonia.formspec or {}

if not harmonia.formspec.render_mana_gauge then
  local table_merge = assert(foundation.com.table_merge)

  function harmonia.formspec.render_mana_gauge(options)
    local amount = options.amount
    local max = options.max

    local new_options = table_merge({
      gauge_color = harmonia.config.colors.mana,
      border_name = "yatm_item_border_percent.png",
      is_horz = false,
      tooltip = "Mana " .. amount .. " / " .. max
    }, options)

    return yatm.formspec.render_gauge(new_options)
  end
end

if not harmonia.formspec.render_corrupted_mana_gauge then
  local table_merge = assert(foundation.com.table_merge)

  function harmonia.formspec.render_corrupted_mana_gauge(options)
    local amount = options.amount
    local max = options.max

    local new_options = table_merge({
      gauge_color = harmonia.config.colors.corrupted_mana,
      border_name = "yatm_item_border_percent.png",
      is_horz = false,
      tooltip = "Corrupted Mana " .. amount .. " / " .. max
    }, options)

    return yatm.formspec.render_gauge(new_options)
  end
end
