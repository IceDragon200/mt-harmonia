local mod = assert(harmonia_spirits)

mod.autotest_suite:define_model("mana_heater", {
  state = {
    node = { name = mod:make_name("mana_heater_off") },
  },

  properties = {
    {
      property = "is_mana_heater",
    },
  }
})
