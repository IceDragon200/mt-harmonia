local mod = assert(harmonia_spirits)

-- There is only one corrupted spirit for now
-- Maybe in the future there will be other variants
mod.weighted_corrupted_spirits:push(mod:make_name("spirit_corrupted"), 10)

-- The six elemental spirits for now, in the future there may be other variants
mod.weighted_spirits:push(mod:make_name("spirit_aqua"), 10)
mod.weighted_spirits:push(mod:make_name("spirit_ignis"), 10)
mod.weighted_spirits:push(mod:make_name("spirit_lux"), 10)
mod.weighted_spirits:push(mod:make_name("spirit_terra"), 10)
mod.weighted_spirits:push(mod:make_name("spirit_umbra"), 10)
mod.weighted_spirits:push(mod:make_name("spirit_ventus"), 10)
