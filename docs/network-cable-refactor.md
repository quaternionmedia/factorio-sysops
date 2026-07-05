# Network Cable Refactor Plan

## Problem Statement

The current network cable implementation uses transport-belt entities, which causes several issues:
1. **Item filtering is unreliable** - Players/inserters can place any item on belts, and runtime filtering has edge cases
2. **Visual mismatch** - Transport belts look like industrial conveyor belts, not data cables
3. **Performance overhead** - Constantly checking and filtering belt contents every 2 ticks

## Solution: Script-Based Data Transfer

Replace transport-belt-based cables with **visual-only entities** and **script-based data transfer**.

### Core Concept

- Network cables become simple non-transport entities (decorative conduits)
- Data packets **never physically exist on cables** - they teleport directly from sensor to server
- The script validates connectivity (sensor → cable chain → server) and handles transfer
- This inherently prevents non-data-packet items since nothing can be placed on cables

---

## Implementation Plan

### Phase 1: New Entity Type

**Change cable entity type from `transport-belt` to `simple-entity-with-owner`**

```lua
-- prototypes/entities.lua
{
  type = "simple-entity-with-owner",
  name = "network-cable",
  icon = "__sysadmin-poc__/graphics/icons/network-cable.png",
  icon_size = 32,
  flags = {"placeable-neutral", "player-creation"},
  minable = {mining_time = 0.1, result = "network-cable"},
  max_health = 100,
  collision_box = {{-0.35, -0.35}, {0.35, 0.35}},  -- Smaller than belts
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  -- Custom thin cable sprite
  picture = {
    filename = "__sysadmin-poc__/graphics/entity/network-cable.png",
    width = 64,
    height = 64,
    scale = 0.5
  },
  -- Allow circuit connections for future expansion
  circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
  circuit_wire_max_distance = 9
}
```

**Benefits:**
- Cannot hold items (not a transport entity)
- Smaller collision box = thinner appearance
- Simpler entity = better performance
- Still placeable/minable like normal

### Phase 2: Custom Cable Sprites

Create thin fiber-optic/ethernet cable sprites:

**Design Goals:**
- 1/3 the width of transport belts
- Glowing fiber-optic core with outer sheath
- Directional connections (auto-connect to adjacent cables)
- Different sprite for each connection configuration (like pipes)

**Sprite Variants Needed:**
```
cable-straight-horizontal.png   (connects left-right)
cable-straight-vertical.png     (connects up-down)
cable-corner-ne.png             (connects north-east)
cable-corner-nw.png             (connects north-west)
cable-corner-se.png             (connects south-east)
cable-corner-sw.png             (connects south-west)
cable-t-north.png               (T-junction, no south)
cable-t-south.png               (T-junction, no north)
cable-t-east.png                (T-junction, no west)
cable-t-west.png                (T-junction, no east)
cable-cross.png                 (4-way junction)
cable-end-north.png             (dead end, cap on north)
cable-end-south.png
cable-end-east.png
cable-end-west.png
```

**Alternative: Use pipe-style connection system**
Factorio's pipe entity type handles connections automatically. We could:
- Clone pipe prototype but use item-based recipes
- Disable fluid transfer via script or settings
- Get automatic sprite rotation for free

### Phase 3: Connection Graph System

Implement a graph-based connectivity system:

```lua
-- scripts/cable-network.lua
local CableNetwork = {}

-- Build adjacency graph of cable connections
function CableNetwork.rebuild_graph()
  storage.cable_graph = {}

  for unit_number, cable_data in pairs(storage.cables) do
    local cable = cable_data.entity
    if cable and cable.valid then
      -- Find adjacent cables and endpoints (sensors/servers)
      local adjacent = find_adjacent_network_entities(cable)
      storage.cable_graph[unit_number] = {
        entity = cable,
        connections = adjacent
      }
    end
  end
end

-- Check if a sensor can reach any server
function CableNetwork.find_connected_servers(sensor)
  local servers = {}
  local visited = {}
  local queue = {sensor.unit_number}

  while #queue > 0 do
    local current = table.remove(queue, 1)
    if visited[current] then goto continue end
    visited[current] = true

    local node = storage.cable_graph[current]
    if node then
      for _, connected_unit in pairs(node.connections) do
        local entity = get_entity_by_unit_number(connected_unit)
        if entity and is_server(entity) then
          table.insert(servers, entity)
        elseif entity and is_cable(entity) then
          table.insert(queue, connected_unit)
        end
      end
    end
    ::continue::
  end

  return servers
end
```

### Phase 4: Script-Based Data Transfer

Replace belt-based transfer with direct inventory transfer:

```lua
-- scripts/data-system.lua
function DataSystem.auto_transfer()
  -- For each sensor with data packets
  for sensor_id, sensor_data in pairs(storage.sensors) do
    local sensor = sensor_data.entity
    if not sensor or not sensor.valid then goto continue_sensor end

    local inventory = sensor.get_inventory(defines.inventory.chest)
    if not inventory then goto continue_sensor end

    local packet_count = inventory.get_item_count("data-packet")
    if packet_count == 0 then goto continue_sensor end

    -- Find connected servers via cable graph
    local connected_servers = CableNetwork.find_connected_servers(sensor)

    -- Distribute packets to servers with capacity
    local transferred = 0
    for _, server in pairs(connected_servers) do
      if transferred >= TRANSFER_RATE then break end

      local server_input = server.get_inventory(defines.inventory.assembling_machine_input)
      if server_input and server_input.can_insert({name = "data-packet", count = 1}) then
        -- Direct transfer - no belt involved
        local to_transfer = math.min(packet_count - transferred, TRANSFER_RATE - transferred)
        local removed = inventory.remove({name = "data-packet", count = to_transfer})
        if removed > 0 then
          server_input.insert({name = "data-packet", count = removed})
          transferred = transferred + removed
        end
      end
    end

    ::continue_sensor::
  end
end
```

### Phase 5: Visual Data Flow Indicators (Optional)

Since packets won't visually travel on cables, add visual feedback:

**Option A: Animated cable sprites**
- Cable glows brighter when data is flowing
- Pulsing animation along the cable direction

**Option B: Floating indicators**
- Small packet icons float along cable paths
- Pure rendering, no actual entities

**Option C: Status LEDs on cables**
- Small LED indicator shows active/idle state
- Changes color based on throughput

---

## Migration Plan

1. **Backup existing cable positions** before migration
2. **Remove old transport-belt cables** via script
3. **Place new simple-entity cables** at same positions
4. **Rebuild cable graph** on configuration change
5. **Remove belt-related code** (filter_cable_items, transport line access)

```lua
-- control.lua migration
script.on_configuration_changed(function(data)
  -- Migrate from transport-belt to simple-entity cables
  if data.mod_changes and data.mod_changes["sysadmin-poc"] then
    local old_version = data.mod_changes["sysadmin-poc"].old_version
    if old_version and old_version < "0.1.0" then
      migrate_cables_to_new_system()
    end
  end
end)
```

---

## File Changes Summary

| File | Changes |
|------|---------|
| `prototypes/entities.lua` | Replace transport-belt with simple-entity-with-owner |
| `scripts/generate-sprites.py` | Add cable connection sprite generation |
| `scripts/cable-network.lua` | NEW - Graph-based connectivity system |
| `scripts/data-system.lua` | Replace belt transfer with direct inventory transfer |
| `control.lua` | Add migration, remove belt filtering code |
| `graphics/entity/` | Add 15+ cable connection sprites |

---

## Benefits

1. **No item filtering needed** - Cables can't hold items by design
2. **Cleaner visuals** - Thin cable sprites instead of bulky belts
3. **Better performance** - No belt content scanning every 2 ticks
4. **Simpler code** - Remove all transport line manipulation
5. **More realistic** - Data "teleports" instantly like real network packets

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Loss of visual item flow | Add animated cable glow or floating indicators |
| Complex connection logic | Reuse Factorio's pipe connection system as base |
| Migration breaks saves | Thorough testing, backup cable positions first |
| Underground cables | Need separate simple-entity with distance limit |

---

## Timeline Estimate

- Phase 1 (Entity type): Simple prototype change
- Phase 2 (Sprites): Generate 15+ sprite variants
- Phase 3 (Graph system): Core connectivity logic
- Phase 4 (Transfer): Replace belt code with inventory transfer
- Phase 5 (Visuals): Optional polish

---

## Alternative Approaches Considered

### A. Pipe-based cables
- **Pros**: Auto-connection sprites, proven system
- **Cons**: Fluid-centric API, would need significant adaptation

### B. Rail-based cables
- **Pros**: Long-distance support built-in
- **Cons**: Completely wrong visual, 2-tile wide

### C. Keep belts with loader endpoints
- **Pros**: Minimal changes
- **Cons**: Still has filtering issues, doesn't solve core problem

### D. Linked containers
- **Pros**: Instant transfer, Factorio 2.0 feature
- **Cons**: No visual cable connection, limited flexibility

**Recommendation**: Simple-entity with script transfer (this plan) is the cleanest solution.
