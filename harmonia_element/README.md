# Harmonia Element

Element can be thought of as matter, it can be used to craft anything with the right blueprint.

## Setting Element Blueprint for items

```lua
-- works with any register_item variant (register_node, register_tool, register_craftitem)
minetest.register_item("my_mod:my_item", {
  element_blueprint = {
    id = "my_mod:my_item_blueprint",
  },
})
```

Explictly setting the `element_blueprint` is not necessary as it will be backfilled by the mod.

If you wish to totally disable blueprints for an item, set `element_blueprint` to `false`.

```lua
-- works with any register_item variant (register_node, register_tool, register_craftitem)
minetest.register_item("my_mod:my_secret_item", {
  element_blueprint = false, -- this item will not be craftable via the element crafting system
})
```
