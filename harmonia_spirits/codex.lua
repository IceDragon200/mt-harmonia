local mod = assert(harmonia_spirits)

yatm.codex.register_entry(mod:make_name("spirit_lantern_empty"), {
  pages = {
    {
      heading_item = {
        context = true,
        default = mod:make_name("spirit_lantern_empty"),
      },
      heading = mod.S("Spirit Lantern without Core"),
      lines = {
        "A spirit lantern with its core missing.",
        "Without a core this lantern will not be able to attract spirits."
      }
    }
  }
})

yatm.codex.register_entry(mod:make_name("spirit_lantern_core_empty"), {
  pages = {
    {
      heading_item = {
        context = true,
        default = mod:make_name("spirit_lantern_core_empty"),
      },

      heading = mod.S("Empty Spirit Lantern"),
      lines = {
        "A spirit lantern attracts spirits by absorbing mana nearby.",
        "The lantern will attract various spirits and traps them inside the lantern.",
        "You can take these materialized spirits and utilize them as you please.",
      }
    }
  }
})

yatm.codex.register_entry(mod:make_name("spirit_lantern_core"), {
  pages = {
    {
      heading_item = {
        context = true,
        default = mod:make_name("spirit_lantern_core_empty"),
      },

      heading = mod.S("Spirit Lantern with Spirit"),

      lines = {
        "This spirit lantern contains a spirit, you can retrieve it from its inventory.",
      }
    }
  }
})
