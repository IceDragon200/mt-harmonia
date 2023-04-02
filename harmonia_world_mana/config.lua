local mod = assert(harmonia_world_mana)

mod.config = {
  -- If you're wondering where this magic number comes from:
  -- 10mana/s, 600mana/minute, 5 minutes worth is 3000
  MANA_OVERFLOW_THRESHOLD = 3000,

  -- See MANA_OVERFLOW_THRESHOLD for math
  -- If a block is unable to get rid of its mana, it starts heading into corruption
  -- state, in which it will start generating corrupted_mana by converting excess
  -- mana
  MANA_CORRUPTION_THRESHOLD = 9000,
}
