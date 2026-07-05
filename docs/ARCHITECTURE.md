# Factorio: Sysadmin - Technical Architecture

## Data Transmission Design

The mod supports multiple data transmission methods, each with tradeoffs. For the POC, we prioritize simplicity and Factorio-native mechanics over visual fidelity.

### Transmission Methods

| Method | Base Entity | Pros | Cons | POC Status |
|--------|-------------|------|------|------------|
| **Belt** | transport-belt | Familiar, visual item flow, inserter-compatible | Complex animations (20+ sprites per direction) | **Implemented** |
| **Pipe** | pipe | Fluid mechanics, underground routing | Less intuitive for "data", no inserter support | Future |
| **Wire** | circuit wire | Instant, no physical items, circuit-native | No physical items to see, different UX | Future |

### POC Implementation: Belt-Based (with Auto-Transfer)

Network cables clone the transport belt entity. Data packets are physical items that move on the belt. **No inserters required** - auto-transfer handles item movement.

```
[Data Sensor] ←→ [Network Cable] ←→ [Server]
     ↓                  ↓                ↓
  (chest)        (transport-belt)   (assembler)
     └──── Auto-transfer every 2 ticks ────┘
```

**Why belts:**
- Item transport mechanics are proven
- Players understand belt logistics
- Underground and splitter variants available
- Circuit network integration works

**Auto-transfer system:**
- Runs every 2 ticks for responsiveness at high belt speeds
- Sensors auto-output packets to adjacent cables
- Servers auto-input packets from adjacent cables
- Supports all cable variants (regular, underground, splitter)

**Item filtering:**
- Only data-packets allowed on network cables
- Non-allowed items automatically ejected to ground
- Prevents accidental mixing with factory logistics

### Animation Simplification

**Design Decision: Maximum Speed, Minimal Custom Animation**

Belt animations in Factorio are complex:
- 20+ frames per direction
- Separate sprites for belt surface, edges, connectors
- HR and normal resolution variants
- Multiple belt speeds require different animation rates

Since data transmission is conceptually "instant" or "very fast", we can:
1. Use maximum belt speed (or close to it)
2. Keep vanilla belt animations (no custom sprites needed)
3. Focus visual distinction on the items (data packets) rather than the transport

**Current approach:**
- Network cables use vanilla belt appearance
- Custom icons distinguish items in inventory/GUI
- Data packets have distinctive visual design
- Entity sprites are custom for sensors, servers, etc.

### Future: Pipe-Based Transmission

Fluid-based data flow could offer:
- Underground conduits native to pipes
- Different "fluid types" for data categories
- Mixing/filtering mechanics

```lua
-- Conceptual: Data as fluid
data:extend({
  {
    type = "fluid",
    name = "raw-data",
    base_color = {r=0.2, g=0.6, b=1.0},
    flow_color = {r=0.4, g=0.8, b=1.0},
  }
})
```

### Future: Wire-Based Transmission

Circuit-wire-style instant transmission:
- No physical items
- Signal-based data representation
- True "networking" feel

```lua
-- Conceptual: Data as circuit signals
-- Circuit bridge already does this for metrics
-- Could extend to full data transmission
```

---

## Graphics Architecture

### Generation Scripts

All graphics are programmatically generated using Python/PIL:

| Script | Output | Size | Purpose |
|--------|--------|------|---------|
| `generate-icons.py` | `graphics/icons/*.png` | 32x32 | Inventory icons, signal icons |
| `generate-sprites.py` | `graphics/entity/*.png` | 64x64 | Entity world sprites |

### Regenerating Graphics

```bash
cd sysadmin-poc
python scripts/generate-icons.py    # Regenerate all icons
python scripts/generate-sprites.py  # Regenerate entity sprites
```

### Color Palette

Consistent colors across icons and sprites:

| Entity | Color | RGB | Purpose |
|--------|-------|-----|---------|
| Data Sensor | Cyan | (102, 204, 255) | Data collection |
| Network Cable | Orange | (255, 153, 51) | Data transport |
| Basic Server | Green | (77, 255, 128) | Processing |
| Circuit Bridge | Yellow | (255, 255, 102) | Circuit integration |
| Dashboard | Purple | (178, 102, 255) | Monitoring/UI |
| Data Packet | Blue | (51, 153, 255) | Data items |

### Entity Sprites

Each entity has:
- Main sprite (64x64, scaled to 0.5 in-game)
- Shadow layer (separate PNG with `draw_as_shadow = true`)

```lua
-- Entity sprite structure
sensor.picture = {
  layers = {
    {
      filename = "__sysadmin-poc__/graphics/entity/data-sensor.png",
      width = 64, height = 64,
      scale = 0.5
    },
    {
      filename = "__sysadmin-poc__/graphics/entity/data-sensor-shadow.png",
      width = 64, height = 64,
      scale = 0.5,
      draw_as_shadow = true
    }
  }
}
```

### Icon Design Principles

1. **Distinct silhouettes** - Each icon recognizable at small sizes
2. **Consistent style** - Dark backgrounds, colored elements
3. **IT-themed** - Server racks, monitors, antennas, circuit traces
4. **Signal icons** - Circle background with symbolic content

---

## Entity Architecture

### Clone Strategy

Each mod entity clones a vanilla entity that provides the needed mechanics:

| Mod Entity | Clones | Why |
|------------|--------|-----|
| Data Sensor | iron-chest | Inventory for data packets, auto-transfer compatible |
| Network Cable | transport-belt | Item transport, dark tint, speed 1.0 |
| Network Cable Underground | underground-belt | Through-wall routing, 10 tile range |
| Network Cable Splitter | splitter | Load balancing, stream merging |
| Basic Server | assembling-machine-1 | Crafting/processing, 1x1 size, fixed recipe |
| Circuit Bridge | constant-combinator | Circuit network integration |
| Dashboard Terminal | programmable-speaker | GUI interaction on click |

### Graphics Override

After cloning, we replace graphics with custom sprites:

```lua
local sensor = table.deepcopy(data.raw["container"]["iron-chest"])
sensor.name = "data-sensor"
-- Override with custom sprite
sensor.picture = { ... custom graphics ... }
```

### Limitations

1. **Belt animations**: Too complex for custom generation; use vanilla appearance
2. **Assembler working visualization**: Would need animated sprites; use static
3. **Directional sprites**: Combinators need all 4 directions; we use same sprite rotated

---

## Data Flow Architecture

### POC Data Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Assembler  │────▶│ Data Sensor │────▶│Network Cable│────▶│Basic Server │
│  (vanilla)  │     │  (chest)    │     │   (belt)    │     │ (assembler) │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │                   │
       │              Generates           Transports          Consumes
       │            data packets        data packets       data packets
       │                   │                   │                   │
       └───────────────────┴───────────────────┴───────────────────┘
                              Monitored by control.lua
```

### Metrics Collection

Every 60 ticks (1 second):
1. Count items in sensor inventories (data backlog)
2. Count processed items in servers
3. Calculate throughput rates
4. Update circuit bridge signals
5. Check alert thresholds
6. Update visual indicators

### Circuit Integration

Circuit Bridge outputs:
- `signal-throughput` (T): Total items processed
- `signal-data-rate` (D): Packets per second
- `signal-utilization` (U): Server utilization %
- `signal-monitored-count` (M): Monitored assemblers
- `signal-data-backlog` (B): Unprocessed packets

---

## File Structure

```
sysadmin-poc/
├── control.lua              # Runtime logic, event handlers
├── data.lua                 # Prototype loading entry point
├── info.json                # Mod metadata
├── settings.lua             # Mod settings definitions
│
├── prototypes/
│   ├── entities.lua         # Entity definitions (sensor, server, etc.)
│   ├── items.lua            # Item definitions
│   ├── recipes.lua          # Crafting recipes
│   ├── signals.lua          # Virtual signal definitions
│   └── technology.lua       # Tech tree
│
├── scripts/
│   ├── data-system.lua      # Core data processing logic
│   ├── indicators.lua       # Visual indicator rendering
│   ├── alerts.lua           # Alert notification system
│   ├── generate-icons.py    # Icon generation script
│   └── generate-sprites.py  # Entity sprite generation
│
├── gui/
│   └── dashboard.lua        # Dashboard GUI logic
│
├── graphics/
│   ├── icons/               # 32x32 inventory icons
│   │   ├── data-packet.png
│   │   ├── data-sensor.png
│   │   ├── network-cable.png
│   │   ├── basic-server.png
│   │   ├── circuit-bridge.png
│   │   ├── dashboard-terminal.png
│   │   └── signals/         # Virtual signal icons
│   │       ├── signal-throughput.png
│   │       ├── signal-data-rate.png
│   │       ├── signal-utilization.png
│   │       ├── signal-monitored-count.png
│   │       └── signal-data-backlog.png
│   │
│   └── entity/              # 64x64 world sprites
│       ├── data-sensor.png
│       ├── data-sensor-shadow.png
│       ├── basic-server.png
│       ├── basic-server-shadow.png
│       ├── circuit-bridge.png
│       ├── circuit-bridge-shadow.png
│       ├── dashboard-terminal.png
│       ├── dashboard-terminal-shadow.png
│       ├── network-cable.png
│       └── network-cable-shadow.png
│
└── locale/
    └── en/
        └── locale.cfg       # English translations
```

---

## Implementation Status

### Completed (Phases 0–3)

**POC + Demo Loop (Phases 0–2)**
- [x] Core entities (sensor, cable, server, bridge, dashboard)
- [x] Network cable variants (underground, splitter)
- [x] Data packet item and processing recipe
- [x] Technology unlock (IT Basics)
- [x] Dashboard GUI with live metrics
- [x] Visual indicators on monitored assemblers
- [x] Alert system with backlog thresholds
- [x] Circuit bridge signal output
- [x] Programmatic icon generation (32x32)
- [x] Programmatic entity sprite generation (64x64)
- [x] Custom entity graphics (sensor, server, bridge, dashboard)
- [x] Dark-tinted belt appearance for cables
- [x] Auto-transfer system (no inserters needed)
- [x] Item filtering (data-packets only on cables)
- [x] IT Infrastructure crafting menu tab
- [x] Console debug commands (/sysadmin-stats, /sysadmin-circuit, /sysadmin-transfer)

**Automation (Phase 3)**
- [x] Sensor radius indicator (cyan/red/yellow/blue by state)
- [x] Circuit-controlled entity enable/disable via `signal-it-control`
- [x] Per-sensor circuit signals (ID, entities, backlog, data-rate)
- [x] Hidden `sensor-circuit-interface` combinator per sensor
- [x] Advanced Server (2× speed, 400 kW) + IT Automation tech
- [x] High-Performance Server (4× speed, 800 kW) + IT Advanced tech
- [x] `circuit-control.lua` — NORMAL / CIRCUIT_ENABLED / CIRCUIT_DISABLED states

### Open (pre-Milestone-1)

- [ ] Performance test with 50+ sensors (2-tick auto-transfer loop risk)

### Next: Milestone 1 — Technical Debt (Phase 4 start)

- [ ] `scripts/technical-debt.lua` — accumulation, recovery, penalty
- [ ] `signal-technical-debt` virtual signal
- [ ] Dashboard debt meter (green → yellow → red bar)
- [ ] Debt-driven efficiency penalty applied to sensor bonus

### Future Milestones

- [ ] Milestone 2: Incidents & Postmortems (Phase 4 cont.)
- [ ] Milestone 3: Cyber Threats & Firewall (Phase 5)
- [ ] Milestone 4: Space Age multi-surface IT (Phase 6)
- [ ] Milestone 5: Balance, sound, tutorial, mod portal release (Phase 7)
- [ ] Optional: DataFactorio out-of-game dashboard integration
