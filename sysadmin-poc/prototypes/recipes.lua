-- Sysadmin POC - Recipe Definitions

data:extend({
  -- Data Sensor recipe
  {
    type = "recipe",
    name = "data-sensor",
    enabled = false,
    energy_required = 2,
    ingredients = {
      {type = "item", name = "electronic-circuit", amount = 5},
      {type = "item", name = "copper-cable", amount = 10},
      {type = "item", name = "iron-plate", amount = 2}
    },
    results = {{type = "item", name = "data-sensor", amount = 1}}
  },

  -- Network Cable recipe
  {
    type = "recipe",
    name = "network-cable",
    enabled = false,
    energy_required = 0.5,
    ingredients = {
      {type = "item", name = "copper-cable", amount = 5},
      {type = "item", name = "iron-plate", amount = 1}
    },
    results = {{type = "item", name = "network-cable", amount = 2}}
  },

  -- Network Cable Underground recipe
  {
    type = "recipe",
    name = "network-cable-underground",
    enabled = false,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "network-cable", amount = 5},
      {type = "item", name = "iron-plate", amount = 10}
    },
    results = {{type = "item", name = "network-cable-underground", amount = 2}}
  },

  -- Network Cable Splitter recipe
  {
    type = "recipe",
    name = "network-cable-splitter",
    enabled = false,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "network-cable", amount = 4},
      {type = "item", name = "electronic-circuit", amount = 5},
      {type = "item", name = "iron-plate", amount = 5}
    },
    results = {{type = "item", name = "network-cable-splitter", amount = 1}}
  },

  -- Basic Server recipe
  {
    type = "recipe",
    name = "basic-server",
    enabled = false,
    energy_required = 10,
    ingredients = {
      {type = "item", name = "electronic-circuit", amount = 20},
      {type = "item", name = "advanced-circuit", amount = 5},
      {type = "item", name = "iron-plate", amount = 10},
      {type = "item", name = "copper-plate", amount = 5}
    },
    results = {{type = "item", name = "basic-server", amount = 1}}
  },

  -- Advanced Server recipe (tier 2)
  {
    type = "recipe",
    name = "advanced-server",
    enabled = false,
    energy_required = 15,
    ingredients = {
      {type = "item", name = "basic-server", amount = 1},
      {type = "item", name = "advanced-circuit", amount = 20},
      {type = "item", name = "steel-plate", amount = 10},
      {type = "item", name = "copper-plate", amount = 10}
    },
    results = {{type = "item", name = "advanced-server", amount = 1}}
  },

  -- High-Performance Server recipe (tier 3)
  {
    type = "recipe",
    name = "hp-server",
    enabled = false,
    energy_required = 20,
    ingredients = {
      {type = "item", name = "advanced-server", amount = 1},
      {type = "item", name = "processing-unit", amount = 10},
      {type = "item", name = "steel-plate", amount = 20},
      {type = "item", name = "low-density-structure", amount = 5}
    },
    results = {{type = "item", name = "hp-server", amount = 1}}
  },

  -- Circuit Bridge recipe
  {
    type = "recipe",
    name = "circuit-bridge",
    enabled = false,
    energy_required = 2,
    ingredients = {
      {type = "item", name = "electronic-circuit", amount = 15},
      {type = "item", name = "copper-cable", amount = 30}
    },
    results = {{type = "item", name = "circuit-bridge", amount = 1}}
  },

  -- Dashboard Terminal recipe
  {
    type = "recipe",
    name = "dashboard-terminal",
    enabled = false,
    energy_required = 3,
    ingredients = {
      {type = "item", name = "electronic-circuit", amount = 5},
      {type = "item", name = "copper-cable", amount = 5},
      {type = "item", name = "small-lamp", amount = 1}
    },
    results = {{type = "item", name = "dashboard-terminal", amount = 1}}
  },

  -- Data processing recipe (what servers do)
  -- This is a fixed recipe that consumes data packets
  {
    type = "recipe",
    name = "process-data",
    category = "data-processing",
    icon = "__sysadmin-poc__/graphics/icons/data-packet.png",
    icon_size = 32,
    enabled = true,
    hidden = true,
    hide_from_player_crafting = true,
    energy_required = 1,
    ingredients = {{type = "item", name = "data-packet", amount = 10}},
    results = {},
    main_product = "",
    allow_productivity = false
  }
})
