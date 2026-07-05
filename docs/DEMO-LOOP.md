# Factorio: Sysadmin - Demo Loop Implementation

## Objective

Build on the completed POC to create an engaging demo game loop with:
- Visual feedback so players can see the system working
- Tangible consequences for neglecting IT infrastructure
- Clear player agency and decision points

```
POC (Complete):
  Assembler → Data → Sensor → Server → Processed

Demo Loop (This Phase):
  Assembler → Data → Sensor → Server → Processed
                         ↓              ↓
                    Dashboard ←→ Visual Indicators
                         ↓
                 Backlog Alerts (if data not processed)
```

---

## Scope

### In Scope
- [x] Dashboard GUI showing live metrics
- [x] Visual indicators on monitored assemblers
- [x] Data backlog alerts (status warnings)
- [x] Better signal icons with distinct colors
- [x] Basic alert system (notifications)
- [x] Custom entity sprites (programmatic generation)
- [x] Belt-based data transmission (network cables)
- [x] Network cable variants (underground, splitter)
- [x] IT Infrastructure tab in crafting menu
- [x] Item filtering (only data-packets on cables)
- [x] Auto-transfer system (no inserters needed)

### Out of Scope (Future)
- Per-sensor/per-server circuit signals
- Automation rules
- Incidents
- Security/threats
- Space Age integration
- Alternative data transmission (pipe, wire)

---

## Implementation Checklist

### Phase 1: Dashboard GUI ✓

**Goal:** Players can click a dashboard terminal to see IT metrics visually

- [x] **Dashboard Terminal entity**
  - [x] New 1x1 entity (cloned from programmable-speaker)
  - [x] Opens custom GUI when clicked
  - [x] Recipe: 5 electronic circuit, 5 copper cable, 1 small lamp

- [x] **Dashboard GUI**
  - [x] Frame with title "IT Dashboard"
  - [x] Live metrics display:
    - Monitored assemblers count
    - Data throughput (packets/sec)
    - Server utilization %
    - Data backlog count
    - Total processed count
  - [x] Refresh every second (60 ticks)
  - [x] Color-coded status: green=normal, yellow=warning, red=critical

```lua
-- gui/dashboard.lua structure
Dashboard = {}

function Dashboard.on_gui_opened(event)
  -- Create dashboard frame
end

function Dashboard.update(player)
  -- Update metric labels
end

function Dashboard.on_gui_closed(event)
  -- Cleanup
end
```

### Phase 2: Visual Indicators ✓

**Goal:** Players can see at a glance which assemblers are monitored

- [x] **Indicator rendering**
  - [x] Render arrow sprite above monitored assemblers
  - [x] Green = monitored and active
  - [x] Red = emergency stop active

- [x] **Implementation**
  - Uses `rendering.draw_sprite` API
  - Updates every 60 ticks
  - Automatically removes when assembler removed

```lua
-- scripts/indicators.lua
Indicators = {}

function Indicators.update_all()
  for assembler_id, data in pairs(storage.monitored_assemblers) do
    if data.entity and data.entity.valid then
      Indicators.update_indicator(assembler_id, data)
    end
  end
end

function Indicators.update_indicator(assembler_id, data)
  -- Create or update sprite above assembler
  local color = storage.emergency_stop and "red" or "green"
  -- Use rendering API
end
```

### Phase 3: Data Backlog Monitoring ✓

**Goal:** Create awareness - players see when data processing falls behind

- [x] **Backlog threshold system**
  - Warning threshold: 100 packets
  - Critical threshold: 500 packets
  - Severe threshold: 1000 packets

- [x] **Status effects**
  - At warning: Dashboard shows yellow status
  - At critical: Dashboard shows red, alert notification
  - At severe: Urgent alerts, system under stress

- [x] **Recovery**
  - When backlog clears below threshold, status improves
  - State transitions trigger alerts

```lua
-- In data-system.lua
function DataSystem.get_backlog_status()
  local backlog = storage.metrics.data_backlog or 0
  if backlog >= 1000 then
    return "severe", "SEVERE: Backlog critical!"
  elseif backlog >= 500 then
    return "critical", "CRITICAL: Backlog growing fast"
  elseif backlog >= 100 then
    return "warning", "WARNING: Backlog accumulating"
  else
    return "normal", "Normal operation"
  end
end
```

### Phase 4: Alert System ✓

**Goal:** Notify players of important events

- [x] **Alert types**
  - Backlog warning (yellow)
  - Backlog critical (orange/red)
  - Backlog severe (red)
  - Backlog cleared (green)
  - Emergency stop activated (red)
  - Emergency stop released (green)

- [x] **Alert display**
  - Uses `player.print()` with color coding
  - Alerts to all connected players
  - Only triggers on state transitions (no spam)

```lua
-- scripts/alerts.lua
Alerts = {}

function Alerts.send(alert_type, message)
  for _, player in pairs(game.connected_players) do
    local color = alert_type == "warning" and {1, 0.8, 0}
                  or alert_type == "critical" and {1, 0, 0}
                  or {0, 1, 0}
    player.print("[Sysadmin] " .. message, color)
  end
end
```

### Phase 5: Polish ✓

- [x] **Better icons**
  - Programmatic icon generation (scripts/generate-icons.py)
  - Distinct colors for each signal
  - Clear IT-themed visuals
  - Dark cable icons with orange accent arrows

- [x] **Entity sprites**
  - Programmatic sprite generation (scripts/generate-sprites.py)
  - 64x64 custom sprites with shadow layers
  - Custom visuals: sensor (antenna), server (rack), bridge (PCB), dashboard (monitor)
  - Network cables use dark-tinted vanilla belt appearance

- [x] **Network cable variants**
  - Underground cables for routing through obstacles
  - Splitters for load balancing data streams
  - All variants support auto-transfer and item filtering

- [x] **Auto-transfer system**
  - No inserters needed for data flow
  - Sensors auto-output to adjacent network cables
  - Servers auto-input from adjacent network cables
  - Runs every 2 ticks for high-speed belt compatibility

- [x] **Item filtering**
  - Only data-packets allowed on network cables
  - Non-allowed items automatically ejected
  - Prevents accidental item mixing

- [x] **IT Infrastructure tab**
  - Dedicated crafting menu tab for all IT items
  - Organized subgroups: Data, Network, Compute, Monitoring

- [x] **Locale updates**
  - Dashboard text
  - Alert messages
  - Tooltip descriptions
  - Item group/subgroup names

---

## Test Scenarios

### Scenario 1: Dashboard Usage
- [ ] Research IT Basics
- [ ] Build: sensor, server, dashboard terminal
- [ ] Click dashboard terminal
- [ ] Verify GUI shows metrics
- [ ] Verify metrics update in real-time

### Scenario 2: Visual Feedback
- [ ] Place sensor near assemblers
- [ ] Verify green indicators appear
- [ ] Trigger emergency stop (via circuit signal)
- [ ] Verify indicators turn red

### Scenario 3: Backlog Pressure
- [ ] Build many assemblers with one sensor
- [ ] Build only one server
- [ ] Let backlog grow
- [ ] Verify warning at 100 packets
- [ ] Verify critical alert at 500 packets
- [ ] Verify severe alert at 1000 packets
- [ ] Build more servers
- [ ] Verify recovery when backlog clears

---

## File Changes

### New Files ✓
```
sysadmin-poc/
├── gui/
│   └── dashboard.lua         -- Dashboard GUI logic ✓
├── scripts/
│   ├── indicators.lua        -- Visual indicator rendering ✓
│   ├── alerts.lua            -- Alert notification system ✓
│   ├── generate-icons.py     -- Programmatic icon generation ✓
│   └── generate-sprites.py   -- Programmatic entity sprite generation ✓
├── graphics/icons/           -- 32x32 inventory icons ✓
│   ├── data-packet.png
│   ├── data-sensor.png
│   ├── network-cable.png
│   ├── network-cable-underground.png
│   ├── network-cable-splitter.png
│   ├── basic-server.png
│   ├── circuit-bridge.png
│   ├── dashboard-terminal.png
│   └── signals/              -- Signal icons ✓
│       ├── signal-throughput.png
│       ├── signal-data-rate.png
│       ├── signal-utilization.png
│       ├── signal-monitored-count.png
│       └── signal-data-backlog.png
└── graphics/entity/          -- 64x64 world sprites ✓
    ├── data-sensor.png
    ├── data-sensor-shadow.png
    ├── basic-server.png
    ├── basic-server-shadow.png
    ├── circuit-bridge.png
    ├── circuit-bridge-shadow.png
    ├── dashboard-terminal.png
    ├── dashboard-terminal-shadow.png
    ├── network-cable.png
    └── network-cable-shadow.png
```

### Modified Files ✓
```
control.lua                 -- Add GUI event handlers, indicators, alerts ✓
prototypes/items.lua        -- Add dashboard-terminal item ✓
prototypes/entities.lua     -- Add dashboard-terminal entity ✓
prototypes/recipes.lua      -- Add dashboard-terminal recipe ✓
prototypes/technology.lua   -- Add dashboard-terminal to unlock ✓
scripts/data-system.lua     -- Add backlog status logic ✓
locale/en/locale.cfg        -- Add dashboard text ✓
```

---

## Success Criteria

**DEMO LOOP IMPLEMENTATION COMPLETE** ✓

1. [x] Dashboard shows live IT metrics
2. [x] Visual indicators on monitored assemblers
3. [x] Backlog alerts notify when falling behind
4. [x] Alerts notify players of issues
5. [ ] System feels responsive and understandable (needs testing)
6. [ ] Player has clear feedback and agency (needs testing)

**Implemented:** 2026-02-03

---

## Post-Demo Loop

**Next Phase: Automation (Phase 3 per roadmap)**

See [NEXT-PHASE.md](NEXT-PHASE.md) for detailed planning.

Priority items:
1. Circuit-controlled entity enable/disable
2. More circuit signals (per-sensor/per-server details)
3. Automation controller with rule system
4. Server upgrades (faster processing)

Future phases:
5. Incidents & Technical Debt (Phase 4)
6. Security/cyber threats (Phase 5)
7. Space Age integration (Phase 6)
8. Balance & Polish (Phase 7)

---

## Technical Notes

### Data Transmission
- Belt-based (network cable = transport belt clone with dark tint)
- Data packets auto-transfer: sensor → cable → server (no inserters needed)
- **Speed 1.0** - faster than express belts (0.5) for near-instant data flow
- **Dark tinted belts** - black appearance with orange data packets visible
- **Item filtering** - only data-packets allowed on cables (others ejected)
- Includes underground (10 tile range) and splitter variants
- Future: pipe-based (fluid) or wire-based (instant) options

### UI Organization
- Dedicated **IT Infrastructure** tab in crafting menu
- Subgroups: Data Collection, Network, Compute, Monitoring
- All IT items organized logically by function

### Graphics Generation
- All icons/sprites generated programmatically via Python/PIL
- Regenerate with: `python scripts/generate-icons.py` and `python scripts/generate-sprites.py`
- Cable icons: dark body with orange directional arrows
- See [ARCHITECTURE.md](ARCHITECTURE.md) for full technical details

### Debug Commands
- `/sysadmin-stats` - Show all IT metrics
- `/sysadmin-circuit` - Show circuit bridge readings
- `/sysadmin-transfer` - Debug auto-transfer system
