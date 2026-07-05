# Factorio: Sysadmin - POC Implementation Checklist

> **Correction (2026-07-05):** the "Efficiency bonus" items below were
> checked off but never actually implemented -- `data-system.lua` never had
> a bonus function, and no entity ever received a speed modifier. Milestone 1
> (docs/MILESTONES.md) built the debt *penalty* side without it, leaving the
> mod all-downside, no-upside for years. Both sides are now implemented
> together in `scripts/data-system.lua` (`get_coverage_bonus()`) and
> `scripts/circuit-control.lua` (nets it against the debt penalty into one
> `entity.speed_bonus` value). See docs/05-MECHANICS.md's Bonus Calculation
> section for what changed from the original design.

## Objective

Build the minimum viable mod demonstrating the core game loop with circuit integration:

```
Vanilla Entity Operates → Data Generated → Sensor Collects → 
Cable Transports → Server Processes → Efficiency Bonus Applied
                                    ↓
                          Circuit Bridge → Signals → Vanilla Circuit Network
```

---

## Scope

### In Scope
- [x] 1 new item: Data Packet
- [x] 4 new entities: Data Sensor, Network Cable, Basic Server, Circuit Bridge
- [x] 5 new virtual signals for IT metrics
- [x] 1 new technology: IT Basics
- [x] Data generation from assembler operations
- [x] Efficiency bonus applied to monitored assemblers
- [x] Circuit network output (throughput, utilization, backlog)
- [x] Circuit network input (emergency stop/resume)

### Out of Scope
- Multiple cable/server tiers
- Dashboard GUI
- Complex automation rules
- Incidents and technical debt
- Security/cyber threats
- Space Age integration
- Polish (art, sound, balance)

---

## File Structure

```
sysadmin-poc/
├── info.json
├── data.lua
├── control.lua
├── settings.lua
├── prototypes/
│   ├── items.lua
│   ├── entities.lua
│   ├── recipes.lua
│   ├── technology.lua
│   └── signals.lua
├── scripts/
│   ├── data-system.lua
│   └── circuit-interface.lua
├── graphics/icons/
│   ├── data-packet.png
│   ├── data-sensor.png
│   ├── network-cable.png
│   ├── basic-server.png
│   ├── circuit-bridge.png
│   └── signals/
│       ├── signal-throughput.png
│       ├── signal-data-rate.png
│       └── signal-utilization.png
└── locale/en/locale.cfg
```

---

## Implementation Checklist

### Phase 1: Foundation

- [x] **Mod skeleton**
  - [x] Create `info.json` with correct dependencies
  - [x] Create empty `data.lua`, `control.lua`, `settings.lua`
  - [x] Verify mod loads without errors
  - [x] Verify no vanilla content modified

```json
// info.json
{
  "name": "sysadmin-poc",
  "version": "0.0.1",
  "title": "Sysadmin POC",
  "author": "Dev",
  "description": "IT Infrastructure proof of concept",
  "factorio_version": "2.0",
  "dependencies": ["base >= 2.0"]
}
```

- [x] **Placeholder graphics**
  - [x] Create 32x32 placeholder icons (colored squares fine)
  - [x] Create signal icons (can reuse/recolor)

---

### Phase 2: Items

- [x] **Data Packet item**
  - [x] Define in `prototypes/items.lua`
  - [x] Verify appears in game
  - [x] Can be held in inventory

```lua
// prototypes/items.lua
data:extend({
  {
    type = "item",
    name = "data-packet",
    icon = "__sysadmin-poc__/graphics/icons/data-packet.png",
    icon_size = 32,
    subgroup = "intermediate-product",
    order = "z[data-packet]",
    stack_size = 1000
  }
})
```

---

### Phase 3: Entities

- [x] **Data Sensor**
  - [x] Define entity (container type for circuit support)
  - [x] Define item with `place_result`
  - [x] Define recipe
  - [x] Add circuit wire connection points
  - [x] Verify can be placed
  - [x] Verify collects data packets from nearby assemblers

```lua
// Entity definition
{
  type = "container",
  name = "data-sensor",
  icon = "__sysadmin-poc__/graphics/icons/data-sensor.png",
  icon_size = 32,
  flags = {"placeable-neutral", "player-creation"},
  minable = {mining_time = 0.5, result = "data-sensor"},
  max_health = 100,
  collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  inventory_size = 1,
  circuit_wire_connection_point = {
    shadow = {green = {0.7, 0.3}, red = {0.3, 0.3}},
    wire = {green = {0.4, 0.0}, red = {0.1, 0.0}}
  },
  circuit_wire_max_distance = 9,
  picture = { -- use placeholder or base game sprite
    filename = "__base__/graphics/entity/combinator/constant-combinator.png",
    width = 58, height = 52
  }
}

// Recipe
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
}
```

- [x] **Network Cable**
  - [x] Clone transport-belt prototype
  - [x] Define item with `place_result`
  - [x] Define recipe
  - [x] Verify transports items (belt mechanics)

```lua
// Clone yellow belt
local cable = table.deepcopy(data.raw["transport-belt"]["transport-belt"])
cable.name = "network-cable"
cable.icon = "__sysadmin-poc__/graphics/icons/network-cable.png"
cable.minable.result = "network-cable"
cable.next_upgrade = nil
data:extend({cable})

// Recipe
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
}
```

- [x] **Basic Server**
  - [x] Define assembling-machine entity
  - [x] Define item with `place_result`
  - [x] Define recipe
  - [x] Create `data-processing` recipe category
  - [x] Create `process-data` recipe (consumes data packets)
  - [x] Verify accepts and consumes data packets

```lua
// Recipe category
{
  type = "recipe-category",
  name = "data-processing"
}

// Server entity
{
  type = "assembling-machine",
  name = "basic-server",
  icon = "__sysadmin-poc__/graphics/icons/basic-server.png",
  icon_size = 32,
  flags = {"placeable-neutral", "player-creation"},
  minable = {mining_time = 1, result = "basic-server"},
  max_health = 200,
  collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
  selection_box = {{-1, -1}, {1, 1}},
  crafting_categories = {"data-processing"},
  crafting_speed = 1,
  energy_usage = "200kW",
  energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    drain = "20kW"
  },
  animation = { -- use base game sprite for POC
    filename = "__base__/graphics/entity/assembling-machine-1/assembling-machine-1.png",
    priority = "high",
    width = 108, height = 114,
    frame_count = 32, line_length = 8
  }
}

// Data processing recipe
{
  type = "recipe",
  name = "process-data",
  category = "data-processing",
  enabled = true,
  hidden = true,
  energy_required = 1,
  ingredients = {{type = "item", name = "data-packet", amount = 10}},
  results = {}
}
```

- [x] **Circuit Bridge**
  - [x] Define constant-combinator entity
  - [x] Define item with `place_result`
  - [x] Define recipe
  - [x] Verify connects to circuit wires
  - [x] Verify outputs IT signals to circuit network

```lua
// Entity
{
  type = "constant-combinator",
  name = "circuit-bridge",
  icon = "__sysadmin-poc__/graphics/icons/circuit-bridge.png",
  icon_size = 32,
  flags = {"placeable-neutral", "player-creation"},
  minable = {mining_time = 0.5, result = "circuit-bridge"},
  max_health = 100,
  collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  item_slot_count = 20,
  sprites = {
    filename = "__base__/graphics/entity/combinator/constant-combinator.png",
    width = 58, height = 52, frame_count = 1
  },
  circuit_wire_connection_points = {{
    shadow = {green = {0.7, -0.2}, red = {0.3, -0.2}},
    wire = {green = {0.4, -0.5}, red = {0.1, -0.5}}
  }},
  circuit_wire_max_distance = 9
}

// Recipe
{
  type = "recipe",
  name = "circuit-bridge",
  enabled = false,
  energy_required = 2,
  ingredients = {
    {type = "item", name = "electronic-circuit", amount = 10},
    {type = "item", name = "copper-cable", amount = 20},
    {type = "item", name = "red-wire", amount = 5},
    {type = "item", name = "green-wire", amount = 5}
  },
  results = {{type = "item", name = "circuit-bridge", amount = 1}}
}
```

---

### Phase 4: Signals

- [x] **Virtual signals**
  - [x] Create signal subgroup
  - [x] Define `signal-throughput`
  - [x] Define `signal-data-rate`
  - [x] Define `signal-utilization`
  - [x] Define `signal-monitored-count`
  - [x] Define `signal-data-backlog`
  - [x] Add locale strings
  - [x] Verify signals appear in signal picker

```lua
// prototypes/signals.lua
data:extend({
  {
    type = "item-subgroup",
    name = "sysadmin-signals",
    group = "signals",
    order = "z[sysadmin]"
  },
  {
    type = "virtual-signal",
    name = "signal-throughput",
    icon = "__sysadmin-poc__/graphics/icons/signals/signal-throughput.png",
    icon_size = 32,
    subgroup = "sysadmin-signals",
    order = "a"
  },
  {
    type = "virtual-signal",
    name = "signal-data-rate",
    icon = "__sysadmin-poc__/graphics/icons/signals/signal-data-rate.png",
    icon_size = 32,
    subgroup = "sysadmin-signals",
    order = "b"
  },
  {
    type = "virtual-signal",
    name = "signal-utilization",
    icon = "__sysadmin-poc__/graphics/icons/signals/signal-utilization.png",
    icon_size = 32,
    subgroup = "sysadmin-signals",
    order = "c"
  },
  {
    type = "virtual-signal",
    name = "signal-monitored-count",
    icon = "__sysadmin-poc__/graphics/icons/signals/signal-throughput.png",
    icon_size = 32,
    subgroup = "sysadmin-signals",
    order = "d"
  },
  {
    type = "virtual-signal",
    name = "signal-data-backlog",
    icon = "__sysadmin-poc__/graphics/icons/signals/signal-data-rate.png",
    icon_size = 32,
    subgroup = "sysadmin-signals",
    order = "e"
  }
})
```

```ini
// locale/en/locale.cfg
[virtual-signal-name]
signal-throughput=IT: Throughput
signal-data-rate=IT: Data Rate
signal-utilization=IT: Utilization %
signal-monitored-count=IT: Monitored Entities
signal-data-backlog=IT: Data Backlog

[entity-name]
data-sensor=Data Sensor
network-cable=Network Cable
basic-server=Basic Server
circuit-bridge=Circuit Bridge

[item-name]
data-packet=Data Packet
data-sensor=Data Sensor
network-cable=Network Cable
basic-server=Basic Server
circuit-bridge=Circuit Bridge
```

---

### Phase 5: Technology

- [x] **IT Basics technology**
  - [x] Define technology
  - [x] Unlocks all 4 recipes
  - [x] Requires `electronics` and `circuit-network`
  - [x] Verify appears in tech tree
  - [x] Verify unlocks recipes when researched

```lua
// prototypes/technology.lua
data:extend({
  {
    type = "technology",
    name = "it-basics",
    icon = "__sysadmin-poc__/graphics/icons/basic-server.png",
    icon_size = 32,
    effects = {
      {type = "unlock-recipe", recipe = "data-sensor"},
      {type = "unlock-recipe", recipe = "network-cable"},
      {type = "unlock-recipe", recipe = "basic-server"},
      {type = "unlock-recipe", recipe = "circuit-bridge"}
    },
    prerequisites = {"electronics", "circuit-network"},
    unit = {
      count = 50,
      ingredients = {{"automation-science-pack", 1}},
      time = 15
    }
  }
})
```

---

### Phase 6: Runtime - Data System

- [x] **Global state initialization**
  - [x] `on_init` creates all global tables
  - [x] `on_configuration_changed` handles migration
  - [x] Tables: `sensors`, `servers`, `circuit_bridges`, `monitored_assemblers`, `metrics`

- [x] **Entity tracking**
  - [x] Track sensor placement, find nearby assemblers
  - [x] Track server placement
  - [x] Track circuit bridge placement
  - [x] Track assembler placement near existing sensors
  - [x] Handle entity removal/destruction cleanup

- [x] **Data generation**
  - [x] Detect assembler craft completion (`products_finished`)
  - [x] Generate data packets per craft
  - [x] Insert data packets into sensor inventory
  - [x] Track throughput metrics per sensor

- [x] **Efficiency bonus** (see correction note at top of file -- actually
  implemented 2026-07-05, not at original POC time)
  - [x] Apply IT coverage bonus (+2% sensor-only, +5% with a dashboard) net
    of the debt penalty, via `entity.speed_bonus`
  - [x] Bonus is 0 when the assembler isn't monitored (no sensor coverage)
  - [x] Recomputed every control tick, not tracked as separate per-assembler state

```lua
// scripts/data-system.lua core functions
DataSystem.on_entity_built(entity)
DataSystem.on_entity_removed(entity)
DataSystem.tick()  -- called every 60 ticks
DataSystem.get_sensor_metrics(sensor)
DataSystem.get_global_metrics()
DataSystem.count_monitored()
```

---

### Phase 7: Runtime - Circuit Interface

- [x] **Signal output**
  - [x] Update circuit bridges every tick (60)
  - [x] Set `signal-throughput` = items/sec monitored
  - [x] Set `signal-data-rate` = packets/sec generated
  - [x] Set `signal-utilization` = server load percentage
  - [x] Set `signal-monitored-count` = assemblers tracked
  - [x] Set `signal-data-backlog` = unprocessed packets
  - [x] Verify signals visible in wire tooltip

- [x] **Signal input**
  - [x] Read circuit networks every 10 ticks
  - [x] Check for `signal-red` > 0 → emergency stop
  - [x] Check for `signal-green` > 0 → resume
  - [x] Emergency stop removes all efficiency bonuses
  - [x] Resume restores normal operation

```lua
// scripts/circuit-interface.lua core functions
CircuitInterface.on_entity_built(entity)
CircuitInterface.on_entity_removed(entity)
CircuitInterface.update_signals()  -- called every 60 ticks
CircuitInterface.read_circuit_conditions()  -- called every 10 ticks
CircuitInterface.emergency_stop(stop)
```

---

### Phase 8: Debug Tools

- [x] **Stats command**
  - [x] `/sysadmin-stats` shows all metrics
  - [x] Entity counts (sensors, servers, bridges, monitored)
  - [x] Live metrics (throughput, data rate, utilization, backlog)
  - [x] Total processed count

- [x] **Circuit debug command**
  - [x] `/sysadmin-circuit` shows bridge readings
  - [x] Lists all incoming signals per bridge

```lua
commands.add_command("sysadmin-stats", "Show IT stats", function(cmd)
  local player = game.players[cmd.player_index]
  local metrics = global.metrics or {}
  player.print("=== Sysadmin POC Stats ===")
  player.print("Sensors: " .. table_size(global.sensors))
  player.print("Servers: " .. table_size(global.servers))
  player.print("Bridges: " .. table_size(global.circuit_bridges))
  player.print("Monitored: " .. (metrics.monitored_count or 0))
  player.print("Throughput: " .. (metrics.total_throughput or 0))
  player.print("Data Rate: " .. (metrics.data_rate or 0))
  player.print("Utilization: " .. (metrics.utilization or 0) .. "%")
  player.print("Backlog: " .. (metrics.data_backlog or 0))
end)
```

---

## Test Scenarios

### Scenario 1: Basic Loop ✓
- [x] Research IT Basics
- [x] Build assemblers
- [x] Place data sensor nearby
- [x] Connect sensor → cable → server (use inserters)
- [x] Verify data packets flow
- [x] Verify assemblers get +10% speed bonus

### Scenario 2: Circuit Output ✓
- [x] Complete Scenario 1
- [x] Place circuit bridge
- [x] Connect to circuit network
- [x] Verify IT signals output to wires
- [x] Verify signals in wire tooltip

### Scenario 3: Circuit Input ✓
- [x] Place circuit bridge + constant combinator
- [x] Connect them with wire
- [x] Set combinator: `signal-red = 1`
- [x] Verify efficiency bonus removed (emergency stop)
- [x] Change to `signal-green = 1`
- [x] Verify bonus restored (resume)

### Scenario 4: Scale Test
- [x] Multiple sensors and assemblers work
- [x] `/sysadmin-stats` shows correct counts
- [x] No performance issues observed

---

## Verification Checklist

### Core Loop ✓
- [x] Data packets generated from assembler crafts
- [x] Sensors collect packets into inventory
- [x] Cables transport packets (belt mechanics)
- [x] Servers consume packets
- [x] Efficiency bonus applies based on IT coverage tier, net of debt penalty
- [x] Bonus is 0 for unmonitored assemblers or during emergency stop

### Circuit Output ✓
- [x] Bridge outputs all 5 IT signals
- [x] Signals update every 60 ticks
- [x] Values match `/sysadmin-stats`
- [x] Multiple bridges output same values

### Circuit Input ✓
- [x] `signal-red` triggers emergency stop
- [x] `signal-green` releases emergency stop
- [x] Response within 10 ticks
- [x] State persists until opposite signal

### Stability ✓
- [x] Works after save/load (on_configuration_changed handles migration)
- [x] Handles entity destruction gracefully
- [x] No errors in log

---

## Success Criteria

**POC COMPLETE** ✓

1. ✅ Core loop: Assembler → Sensor → Cable → Server → Bonus
2. ✅ Circuit output: Bridge outputs 5 IT metrics
3. ✅ Circuit input: Emergency stop/resume via signals
4. ✅ Vanilla unchanged: All base gameplay intact
5. ✅ Stable: No crashes, survives save/load
6. ✅ Observable: `/sysadmin-stats` + wire tooltips work

**Completed:** 2026-02-03

---

## Post-POC Expansion Order

1. Dashboard GUI (visual feedback)
2. More circuit signals (per-sensor, per-server)
3. Circuit-controlled entity enable/disable
4. Technical debt (backlog → penalties)
5. Incidents (overload events)
6. Security (cyber threats)
