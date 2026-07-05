-- Sysadmin POC - Technology Definitions

data:extend({
  -- IT Basics - Foundation technology
  {
    type = "technology",
    name = "it-basics",
    icon = "__sysadmin-poc__/graphics/icons/basic-server.png",
    icon_size = 32,
    effects = {
      {type = "unlock-recipe", recipe = "data-sensor"},
      {type = "unlock-recipe", recipe = "network-cable"},
      {type = "unlock-recipe", recipe = "network-cable-underground"},
      {type = "unlock-recipe", recipe = "network-cable-splitter"},
      {type = "unlock-recipe", recipe = "basic-server"},
      {type = "unlock-recipe", recipe = "circuit-bridge"},
      {type = "unlock-recipe", recipe = "dashboard-terminal"}
    },
    prerequisites = {"electronics", "circuit-network"},
    unit = {
      count = 50,
      ingredients = {{"automation-science-pack", 1}},
      time = 15
    },
    order = "z-a[it-basics]"
  },

  -- IT Automation - Unlocks Advanced Server and circuit-based automation
  {
    type = "technology",
    name = "it-automation",
    icon = "__sysadmin-poc__/graphics/icons/advanced-server.png",
    icon_size = 32,
    effects = {
      {type = "unlock-recipe", recipe = "advanced-server"}
    },
    prerequisites = {"it-basics", "advanced-circuit"},
    unit = {
      count = 100,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 30
    },
    order = "z-b[it-automation]"
  },

  -- IT Advanced - Unlocks High-Performance Server
  {
    type = "technology",
    name = "it-advanced",
    icon = "__sysadmin-poc__/graphics/icons/hp-server.png",
    icon_size = 32,
    effects = {
      {type = "unlock-recipe", recipe = "hp-server"}
    },
    prerequisites = {"it-automation", "processing-unit"},
    unit = {
      count = 200,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 45
    },
    order = "z-c[it-advanced]"
  }
})
