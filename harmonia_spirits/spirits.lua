--
-- Spirits
--
local mod = assert(harmonia_spirits)

local MetaSchema = assert(foundation.com.MetaSchema)

local SpiritSchema = MetaSchema:new("harmonia_spirits.SpiritSchema", "", {
  -- Spirits can gain general experience over time, this experience can be traded in
  -- for other bonuses
  exp = {
    type = "integer",
  },
  -- When the spirit is used as the core for an entity, they will increase the entity's
  -- maximum mana by this amount
  mana_max = {
    type = "integer",
  },
  -- Depending on the usage, efficiency affects how well the spirit works
  -- When used as a entity's core this can affect the speed at which they complete tasks
  -- When used as an upgrade for a machine this can improve resource usage
  efficiency = {
    type = "float",
  },
  -- A spirit may develop a secondary attribute in which case it will gain the bonuses from that
  -- attribute in addition to its own primary attribute
  attr_id2 = {
    type = "integer"
  }
}):compile("spi")

mod.SpiritSchema = SpiritSchema
