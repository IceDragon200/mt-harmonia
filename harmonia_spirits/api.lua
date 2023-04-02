local mod = assert(harmonia_spirits)

-- TODO: just leaving these as is, this really should be exposed through
-- a proper interface, but for now, to get a MVP, raw values!
mod.weighted_corrupted_spirits = foundation.com.WeightedList:new()
mod.weighted_spirits = foundation.com.WeightedList:new()
