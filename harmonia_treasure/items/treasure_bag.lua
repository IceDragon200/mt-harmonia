minetest.register_tool("harmonia_treasure:bag", {
  description = "Bag",

  inventory_image = "harmonia_treasure_bags_open.png",
})

-- When a treasure bag is used, it opens a formspec with some goodies inside, allowing the player
-- to retrieve the items in it, once empty it transitions to a regular bag, that can be used
-- to store items.
-- Note that treasure bags have their inventories randomized on the first open.
minetest.register_tool("harmonia_treasure:treasure_bag", {
  description = "Treasure Bag",

  inventory_image = "harmonia_treasure_bags_close.png",
})
