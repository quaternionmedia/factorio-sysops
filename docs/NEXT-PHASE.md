# Factorio: Sysadmin - Next Phase Planning

## Current Status

**Completed Phases:**
- Phase 0: Foundation ✓
- Phase 1: Core Data System ✓ (POC)
- Phase 2: Processing & Monitoring ✓ (Demo Loop)

**Current Implementation:**
- Core entities: sensor, cable (with underground/splitter), server, bridge, dashboard
- Auto-transfer system (no inserters needed)
- Item filtering on cables
- Dashboard GUI with live metrics
- Visual indicators on monitored assemblers
- Alert system with backlog thresholds
- Circuit bridge signal output/input
- IT Infrastructure crafting menu tab
- Sensor radius indicator (shows detection range when selected)
- Circuit-controlled entity enable/disable via signal-it-control

---

## Phase 3: Automation & Circuit Enhancements

**Duration:** ~2 months (per roadmap)
**Goal:** Enable sophisticated automation of IT infrastructure via circuits and rules

### Priority 1: Sensor Radius Indicator ✓

**Goal:** Visual feedback showing sensor detection range (like power pole radius)

- [x] Render radius circle when sensor is selected
- [x] Radius matches sensor detection range (default 5 tiles)
- [x] Color indicates status (cyan = active, red = emergency stop, yellow = circuit paused, blue = circuit enabled)

**Implementation:** See [indicators.lua](../sysadmin-poc/scripts/indicators.lua)

### Priority 2: Circuit-Controlled Entity Enable/Disable ✓

**Goal:** Allow players to control assemblers via circuit signals

- [x] Read circuit signals at sensors
- [x] Support "enable/disable monitored entities" via signal
- [x] New signal: `signal-it-control` (IT: Control Signal)
- [x] When signal > 0: enable, when signal < 0: disable
- [x] Update indicators to show controlled state (yellow = paused, blue = forced enabled)

**Implementation:** See [circuit-control.lua](../sysadmin-poc/scripts/circuit-control.lua)

**Use Cases:**
- Emergency shutdown via circuit logic
- Load shedding based on backlog
- Time-based schedules via clock circuits

### Priority 3: Per-Sensor Circuit Signals ✓

**Goal:** Individual monitoring per sensor for granular control

- [x] Each sensor outputs its own metrics via hidden circuit interface
- [x] New signals: `signal-sensor-id`, `signal-sensor-entities`, `signal-sensor-backlog`, `signal-sensor-data-rate`
- [x] Enable circuit logic per-sensor (e.g., "if sensor A backlog > 50, alert")

**Implementation:**
- Created `sensor-circuit-interface` entity (hidden constant-combinator that overlays each sensor)
- Sensors now have unique incrementing IDs (1, 2, 3, ...)
- Each sensor outputs 4 signals: ID, entities count, backlog, data rate
- Debug command: `/sysadmin-sensors` to view per-sensor metrics

**Files:** See [circuit-interface.lua](../sysadmin-poc/scripts/circuit-interface.lua), [signals.lua](../sysadmin-poc/prototypes/signals.lua)

### Priority 4: Server Upgrades ✓

**Goal:** Progression in processing capacity

- [x] **Advanced Server** (tier 2)
  - 2× processing speed
  - Higher power consumption (400kW)
  - Requires advanced circuits + basic server

- [x] **High-Performance Server** (tier 3)
  - 4× processing speed
  - Highest power consumption (800kW)
  - Requires processing units + low-density structure + advanced server

**Technology:**
- IT Basics → unlocks Basic Server
- IT Automation → unlocks Advanced Server (requires IT Basics + Advanced Circuit)
- IT Advanced → unlocks High-Performance Server (requires IT Automation + Processing Unit)

**Implementation:**
- Created `advanced-server` and `hp-server` entities
- Server upgrade path: basic → advanced → hp (fast replaceable)
- Technology tree with science pack progression
- Custom sprites with blue (advanced) and gold (HP) accents

**Files:** See [entities.lua](../sysadmin-poc/prototypes/entities.lua), [technology.lua](../sysadmin-poc/prototypes/technology.lua)

### Priority 5: Automation Controller (Optional for this phase)

**Goal:** Rule-based automation without circuit complexity

- [ ] New entity: Automation Controller
- [ ] Simple GUI for WHEN/THEN rules
- [ ] Examples:
  - WHEN backlog > 500 THEN alert
  - WHEN utilization < 20% THEN disable server
  - WHEN time = 6:00 THEN enable all

**May defer to Phase 4 if scope too large**

---

## Implementation Checklist

### Week 1-2: Radius Indicator + Circuit Control ✓

- [x] Implement sensor radius rendering on selection
- [x] Add circuit input reading at sensors
- [x] Implement enable/disable control via signals
- [x] Update indicators for controlled state
- [x] Add new signal: `signal-it-control`

### Week 3-4: Per-Sensor Signals ✓

- [x] Add per-sensor metric output via hidden circuit interface
- [x] Create sensor ID assignment system (incrementing counter)
- [x] New signals: sensor-id, sensor-entities, sensor-backlog, sensor-data-rate
- [x] Test with multiple sensors via `/sysadmin-sensors` command

### Week 5-6: Server Upgrades ✓

- [x] Create Advanced Server entity (2× speed, 400kW)
- [x] Create High-Performance Server entity (4× speed, 800kW)
- [x] Add recipes and technology unlocks (IT Automation, IT Advanced)
- [x] Balance power consumption vs. throughput

### Week 7-8: Testing & Polish

- [ ] Integration testing all new features
- [ ] Performance testing with many entities
- [ ] Balance tuning
- [x] Documentation updates

---

## New Files Created (Phase 3)

```
sysadmin-poc/
├── scripts/
│   └── circuit-control.lua         -- ✓ Entity control via circuits
├── prototypes/
│   └── entities.lua                -- ✓ Updated: sensor-circuit-interface, advanced-server, hp-server
│   └── technology.lua              -- ✓ Updated: IT Automation, IT Advanced
│   └── signals.lua                 -- ✓ Updated: per-sensor signals
│   └── items.lua                   -- ✓ Updated: new server items
│   └── recipes.lua                 -- ✓ Updated: new server recipes
├── graphics/icons/
│   ├── advanced-server.png         -- ✓ Blue-accented server
│   ├── hp-server.png               -- ✓ Gold-accented server
│   └── signals/
│       ├── signal-it-control.png   -- ✓ Control signal icon
│       ├── signal-sensor-id.png    -- ✓ Sensor ID icon
│       ├── signal-sensor-entities.png -- ✓ Entities count icon
│       ├── signal-sensor-backlog.png  -- ✓ Sensor backlog icon
│       └── signal-sensor-data-rate.png -- ✓ Sensor data rate icon
├── graphics/entity/
│   ├── advanced-server.png         -- ✓ Blue-themed sprite
│   ├── advanced-server-shadow.png  -- ✓ Shadow layer
│   ├── hp-server.png               -- ✓ Gold-themed sprite
│   └── hp-server-shadow.png        -- ✓ Shadow layer
└── locale/en/locale.cfg            -- ✓ Updated with all new names
```

## All Phase 3 Priorities Complete ✓

No remaining tasks for Phase 3. Ready for testing and polish.

---

## Technology Tree (After Phase 3)

```
Electronics + Circuit Network
        ↓
    IT Basics
        ↓
  ┌─────┴─────┐
  ↓           ↓
IT Automation  IT Monitoring
(Advanced Server, (Per-sensor signals,
 Circuit control)  Enhanced dashboard)
        ↓
    IT Advanced
(HP Server, Complex rules)
```

---

## Success Criteria

1. [x] Sensor range visually indicated when selected
2. [x] Assemblers can be enabled/disabled via circuit signals
3. [x] Per-sensor metrics available on circuit network (via sensor circuit interface)
4. [x] Server upgrades provide meaningful progression (Basic → Advanced → HP)
5. [ ] System remains performant with 50+ sensors (needs testing)
6. [x] Documentation complete for new features

---

## Future Phases Reference

**Phase 4: Incidents & Technical Debt**
- Technical debt accumulation from neglect
- Random incident events (overload, failure)
- Engineer drones for incident resolution
- Postmortem system with rewards

**Phase 5: Security System**
- Cyber threat entities
- Defense buildings (firewall, IDS)
- Threat spawning based on debt
- Security-specific research tree

**Phase 6: Space Age Integration**
- Multi-surface IT networks
- Planetary specializations
- Quantum computing (Aquilo)
- Cross-surface data relay

**Phase 7: Balance & Polish**
- Final balancing pass
- Professional art assets
- Sound effects
- Tutorial and achievements
