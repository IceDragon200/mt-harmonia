minetest.register_node("harmonia_pottery:clay_pot", {
  description = "Clay Pot",

  groups = {
    cracky = 1,
    oddly_breakable_by_hand = 1,
  },

  paramtype = "light",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-6/16,-8/16,-6/16,6/16,-7/16,6/16}, -- bottom plate
      {-7/16,-7/16,-7/16,7/16,1/16,7/16}, -- vessel body
      {-6/16,1/16,-6/16,6/16,2/16,6/16}, -- top plate
      {-5/16,2/16,-5/16,5/16,3/16,5/16}, -- pre throat
      {-4/16,3/16,-4/16,4/16,5/16,4/16}, -- throat
      {-5/16,5/16,-5/16,5/16,6/16,5/16}, -- pre mouth
      {-6/16,6/16,-6/16,6/16,8/16,6/16} -- mouth
    }
  },

  tiles = {
    "harmonia_clay_pot_top.png",
    "harmonia_clay_pot_bottom.png",
    "harmonia_clay_pot_side.png",
    "harmonia_clay_pot_side.png",
    "harmonia_clay_pot_side.png",
    "harmonia_clay_pot_side.png",
  }
})
