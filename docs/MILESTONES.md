# Factorio: Sysadmin — Milestone Plan

Phases 0–3 are complete. The POC has a working data pipeline, three server tiers,
full circuit integration, and per-sensor signals. The game loop is functional but
consequence-free: bad IT metrics currently cost nothing.

These milestones close that loop and carry the mod to a v1.0 release.

> **Update (2026-07-05):** Milestone 1 below assumed `data-system.lua` already
> had a `calculate_efficiency_bonus()` to subtract a debt penalty from --
> it didn't (checked off in docs/POC-CHECKLIST.md but never coded), so the
> milestone as actually implemented substituted an unrelated mechanic
> (probabilistically pausing a percentage of assemblers) with no positive
> counterpart. Both the missing bonus and a continuous (non-pausing) penalty
> are now implemented together -- see docs/05-MECHANICS.md's Bonus
> Calculation section for the actual formula in place of the sketch below.

---

## Pre-work: Performance Baseline

**One-liner:** Verify the 2-tick auto-transfer loop is safe at scale before building on top of it.

### Tasks
- Spawn 50+ sensors across a large factory in a test save
- Use `/sysadmin-stats` and `/time-usage` to measure tick load
- If the 2-tick loop exceeds ~0.5 ms, move cable-side transfer to 10-tick with a
  batch queue instead of per-cable polling

**Done when:** 50 sensors + 200 monitored assemblers runs at <1 ms/tick on a mid-spec machine.

---

## Milestone 1 — "Consequences"

> **Ignoring your IT backlog now hurts your factory.**

This is the single most important milestone. Everything already built has been
feedback without stakes. Debt makes the mod matter.

### What Ships

- **Technical Debt accumulates** when data backlog stays above threshold for
  sustained periods
- **Debt decays** automatically when backlog is cleared
- **Efficiency penalty** scales with debt level (up to −20%), subtracting from
  the existing efficiency bonus so high-debt players fall below baseline
- **Debt meter** on the dashboard (green → yellow → red bar with percentage)
- **`signal-technical-debt`** virtual signal output on the circuit bridge
  (0–1000 scale)
- **Critical debt warning** alert (uses existing `alerts.lua` system)

### Implementation

**New file: `sysadmin-poc/scripts/technical-debt.lua`**

```lua
local TechnicalDebt = {}

local DEBT_THRESHOLD    = 100   -- backlog below this = no debt gain
local DEBT_RATE         = 0.5   -- debt gained per second per 100 excess backlog
local RECOVERY_RATE     = 2.0   -- debt lost per second when backlog is clear
local MAX_DEBT          = 1000
local MAX_PENALTY       = 0.20  -- -20% efficiency at max debt

function TechnicalDebt.init()
  storage.technical_debt = storage.technical_debt or {
    total    = 0,
    history  = {},   -- ring buffer, last 60 samples for dashboard graph
    penalty  = 0,
  }
end

function TechnicalDebt.tick()
  local debt  = storage.technical_debt
  local backlog = storage.metrics.data_backlog or 0
  local excess  = math.max(0, backlog - DEBT_THRESHOLD)

  if excess > 0 then
    debt.total = math.min(MAX_DEBT, debt.total + DEBT_RATE * (excess / 100))
  else
    debt.total = math.max(0, debt.total - RECOVERY_RATE)
  end

  debt.penalty = (debt.total / MAX_DEBT) * MAX_PENALTY

  -- ring-buffer history for dashboard sparkline (keep 60 seconds)
  table.insert(debt.history, debt.total)
  if #debt.history > 60 then table.remove(debt.history, 1) end
end

function TechnicalDebt.get_penalty()
  return (storage.technical_debt or {}).penalty or 0
end

function TechnicalDebt.get_level()
  local t = (storage.technical_debt or {}).total or 0
  if t < 200 then return "low"
  elseif t < 500 then return "moderate"
  elseif t < 800 then return "high"
  else return "critical" end
end

return TechnicalDebt
```

**Changes to `control.lua`:**
```lua
local TechnicalDebt = require("scripts.technical-debt")

script.on_init(function()
  -- existing init ...
  TechnicalDebt.init()
end)

script.on_nth_tick(60, function()
  DataSystem.tick()
  TechnicalDebt.tick()           -- <-- add
  CircuitInterface.update_signals()
  Dashboard.update_all()
  Indicators.update_all()
  Alerts.tick()
end)
```

**Changes to `data-system.lua`** — subtract debt penalty from efficiency bonus:
```lua
-- In calculate_efficiency_bonus():
local raw_bonus  = base_bonus * coverage_factor
local penalty    = TechnicalDebt.get_penalty()
return math.max(0, raw_bonus - penalty)
```

**Changes to `circuit-interface.lua`** — add debt signal to bridge output:
```lua
-- In update_signals(), alongside existing signals:
{ signal = { type="virtual", name="signal-technical-debt" },
  count   = math.floor(storage.technical_debt.total) }
```

**New signal in `prototypes/signals.lua`:**
```lua
{ type="virtual-signal", name="signal-technical-debt",
  icon="__sysadmin-poc__/graphics/icons/signals/signal-technical-debt.png",
  icon_size=32, subgroup="sysadmin-signals", order="f" }
```

**Dashboard changes (`gui/dashboard.lua`):**
- Add "Technical Debt" row below existing metrics
- Color the label red when level = "critical", yellow for "high"
- Show the numeric value and level string

**`generate-icons.py`** — add `signal-technical-debt` icon (red background,
broken circuit trace motif, consistent with existing signal style).

### Files Modified
| File | Change |
|------|--------|
| `scripts/technical-debt.lua` | **new** |
| `control.lua` | require + call TechnicalDebt.tick(), init() |
| `scripts/data-system.lua` | subtract penalty in bonus calculation |
| `scripts/circuit-interface.lua` | output signal-technical-debt |
| `prototypes/signals.lua` | new virtual signal |
| `gui/dashboard.lua` | debt meter row |
| `scripts/generate-icons.py` | signal-technical-debt icon |
| `locale/en/locale.cfg` | debt level strings |

### Acceptance Criteria
- [ ] Debt rises visibly when backlog is left uncleareed for > 30 seconds
- [ ] Debt falls when backlog is cleared
- [ ] Efficiency penalty measurably reduces assembler speed at high debt
- [ ] Dashboard debt meter matches `signal-technical-debt` circuit output value
- [ ] Critical debt triggers an alert notification

---

## Milestone 2 — "Incidents"

> **Things start breaking when you leave debt too long.**

### What Ships

- **Incident events** spawn from high technical debt — at least 3 types:
  - `SERVER_OVERLOAD` — a server drops to 50% processing speed
  - `CABLE_CONGESTION` — a cable segment stops transferring (items stay in sensor)
  - `SENSOR_FAILURE` — a sensor stops generating data packets for 60 seconds
- **Dashboard "Incidents" tab** — list of active incidents, each with a "Resolve"
  button and time-since-spawned counter
- **Incident resolution** — player clicks Resolve, affected entity returns to
  normal, a small bonus is applied (debt −50, brief +5% efficiency spike)
- **Postmortem log** — last 5 resolved incidents shown with root cause and
  resolution time
- **`signal-incident-count`** added to circuit bridge output

### Implementation

**New file: `sysadmin-poc/scripts/incidents.lua`**

Key design: incidents are stored in `storage.incidents` as a table of
`{ id, type, entity_unit_number, surface_index, spawned_at, resolved }`.
The tick function checks debt level and rolls a spawn chance; the GUI calls
`Incidents.resolve(id)`.

```lua
local SPAWN_CHANCES = {
  -- debt level  → probability per minute
  moderate = 0.05,
  high     = 0.15,
  critical = 0.40,
}

-- Checked every 600 ticks (10s). Roll per minute = chance/6.
local function try_spawn_incident()
  local level  = TechnicalDebt.get_level()
  local chance = (SPAWN_CHANCES[level] or 0) / 6
  if math.random() > chance then return end

  -- Pick a random affected entity type
  local incident_type = pick_random_incident_type()
  local target        = find_valid_target(incident_type)
  if not target then return end

  apply_degradation(incident_type, target)
  local id = storage.incident_counter + 1
  storage.incident_counter = id
  storage.incidents[id] = {
    id = id, type = incident_type,
    entity_unit_number = target.unit_number,
    spawned_at = game.tick,
    resolved   = false,
  }
  Alerts.trigger("incident", { type = incident_type })
end
```

Resolution removes degradation and records postmortem:
```lua
function Incidents.resolve(incident_id)
  local inc = storage.incidents[incident_id]
  if not inc or inc.resolved then return end
  remove_degradation(inc.type, inc.entity_unit_number)
  inc.resolved   = true
  inc.resolved_at = game.tick
  -- grant reward
  storage.technical_debt.total = math.max(0, storage.technical_debt.total - 50)
  table.insert(storage.incident_history, inc)
  if #storage.incident_history > 5 then table.remove(storage.incident_history, 1) end
  storage.incidents[incident_id] = nil
end
```

**Dashboard tab** — new "Incidents" button next to existing dashboard content.
Use Factorio's tabbed-pane or a simple toggle frame showing the incident list.
Each row: incident type icon, entity position, time elapsed, "Resolve" button.

### Files Modified
| File | Change |
|------|--------|
| `scripts/incidents.lua` | **new** |
| `control.lua` | require + call Incidents.tick() on_nth_tick(600) |
| `gui/dashboard.lua` | Incidents tab / panel |
| `scripts/circuit-interface.lua` | signal-incident-count output |
| `prototypes/signals.lua` | signal-incident-count |
| `locale/en/locale.cfg` | incident type display names |

### Acceptance Criteria
- [ ] Incidents do not spawn at low/no debt
- [ ] At critical debt, player reliably sees an incident within 5 minutes
- [ ] Resolving an incident removes the degradation immediately
- [ ] Postmortem log persists across saves
- [ ] Dashboard shows correct count; circuit bridge signal matches

---

## Milestone 3 — "Defense"

> **A new kind of enemy attacks your network, and debt makes it worse.**

### What Ships

- **Cyber threat unit** — new enemy entity that spawns at map edges, pathfinds
  to IT buildings (sensors, servers, cables), and deals damage to them
- **Firewall node** — placeable defense entity (turret-like) that targets cyber
  threats only; ignores biters, ignored by biters
- **Debt-driven spawn rate** — base rate is very low; critical debt multiplies it 4×
- **`signal-security-status`** on circuit bridge (0 = secure, 1 = threats active,
  2 = IT building breached / destroyed by threat)
- **Dashboard security panel** — threat count, breach count, coverage %

### Design Notes

Cyber threats are a new `unit` prototype. They use the standard Factorio enemy
AI (`unit` type with `attack_parameters`) but belong to a separate force
(`it-threats`) so vanilla turrets and military don't target them. Firewalls are
`turret` prototypes that only attack the `it-threats` force.

This keeps the system fully separate from the biter combat layer — players who
disable biters still face IT threats, and players who keep biters don't have
firewalls accidentally hitting biters.

**Spawn logic** (`scripts/security.lua`):
```lua
local BASE_RATE   = 0.01  -- threats per minute at zero debt
local DEBT_MULT   = 4.0   -- multiplier at max debt

-- Called every 600 ticks (10s)
function Security.tick()
  local debt_ratio = (storage.technical_debt.total or 0) / 1000
  local rate_per_minute = BASE_RATE * (1 + DEBT_MULT * debt_ratio)
  local chance_per_10s  = rate_per_minute / 6
  if math.random() > chance_per_10s then return end

  local surface  = game.surfaces["nauvis"]
  local position = find_spawn_position(surface)   -- map edge, away from walls
  surface.create_entity{
    name     = "cyber-threat",
    position = position,
    force    = "it-threats",
    move_to  = find_nearest_it_building(surface, position)
  }
  storage.security.threats_spawned = storage.security.threats_spawned + 1
end
```

### Files Modified
| File | Change |
|------|--------|
| `prototypes/entities.lua` | cyber-threat unit, firewall-node turret |
| `prototypes/items.lua` | firewall-node item |
| `prototypes/recipes.lua` | firewall-node recipe |
| `prototypes/technology.lua` | IT Security tech (unlocks firewall) |
| `scripts/security.lua` | **new** — spawn logic, force setup, breach tracking |
| `control.lua` | Security.init(), Security.tick() |
| `scripts/circuit-interface.lua` | signal-security-status |
| `prototypes/signals.lua` | signal-security-status |
| `gui/dashboard.lua` | security panel |
| `scripts/generate-sprites.py` | cyber-threat sprite, firewall sprite |
| `scripts/generate-icons.py` | firewall icon |

### Acceptance Criteria
- [ ] Cyber threats spawn and pathfind to IT buildings, not walls or biters
- [ ] Firewall nodes attack threats and nothing else
- [ ] Vanilla turrets do not attack threats (separate force)
- [ ] Biters do not attack firewalls
- [ ] No threats spawn at debt < 200; spawn rate visibly increases with debt
- [ ] Breach event fires and sets security signal = 2

---

## Milestone 4 — "Space Age"

> **IT infrastructure spans planets, with a unique twist on each one.**

*This milestone is gated on `script.active_mods["space-age"]`. All code must
fall back gracefully when the DLC is absent.*

### What Ships

- **Orbital Data Relay** — placed on a space platform; once built, links that
  platform's surface IT data back to Nauvis dashboard
- **Nauvis dashboard** shows aggregate metrics from all connected surfaces
- **Four planetary server variants** (each surface, one bonus):

| Planet | Entity | Bonus |
|--------|--------|-------|
| Vulcanus | Thermal Server | 2× processing, no idle power cost |
| Gleba | Bio-Storage Node | doubles sensor inventory (packet buffer) |
| Fulgora | Edge Server | processes packets locally, no relay latency |
| Aquilo | Quantum Processor | 4× processing, random `DECOHERENCE` incident |

- **Cross-surface `signal-total-throughput`** — sums all surfaces on the Nauvis
  circuit bridge

### Implementation Notes

Surface detection: `game.surfaces` iteration filtered by
`surface.name == "vulcanus"` etc. Guard every Space Age entity definition:
```lua
if script.active_mods["space-age"] then
  data:extend({ ... thermal-server prototype ... })
end
```

Orbital Data Relay is an `accumulator`-clone placed on space platforms.
When built, register surface in `storage.surface_links`:
```lua
storage.surface_links = {
  ["vulcanus"] = { relay_unit_number = ..., last_metrics = {} },
  ...
}
```

Nauvis dashboard reads `storage.surface_links` and renders a per-planet row.

### Acceptance Criteria
- [ ] Mod loads cleanly with Space Age absent (zero errors)
- [ ] Mod loads cleanly with Space Age present
- [ ] Each planet's server variant provides its stated bonus
- [ ] Aquilo quantum processor triggers decoherence incident type
- [ ] Nauvis dashboard shows per-surface breakdown when relays are built

---

## Milestone 5 — "Ship It"

> **The mod feels finished to a new player.**

### What Ships

- **Factoriopedia entries** for every custom entity and item (Factorio 2.0
  supports `factoriopedia_description` on prototypes)
- **Achievements** wired up:
  - *Five Nines* — 99.999% uptime proxy: zero incidents for 10 real-world minutes
  - *Cyber Resilient* — survive 100 cyber threats (firewall or manual)
  - *Integration Master* — all vanilla entity types on at least one surface monitored
- **Sound effects** — one sound event each for: alert triggered, incident spawned,
  incident resolved, threat detected, threat destroyed
- **Balance pass** — recipe costs, debt thresholds, threat spawn rates, efficiency
  bonus ceiling reviewed against playtest data
- **Mod portal listing** — description, screenshots, changelog, tags
- **ARCHITECTURE.md + README.md** brought fully up to date

### Acceptance Criteria
- [ ] A new player can understand what each entity does without reading external docs
- [ ] All three achievements trigger under the correct conditions
- [ ] Sound effects play without errors; volume is not jarring
- [ ] No known crashes or OOS desyncs in multiplayer
- [ ] Mod portal listing is complete and accurate

---

## What to Defer (Indefinitely)

| Feature | Reason |
|---------|--------|
| Automation Controller (WHEN/THEN GUI) | Circuit combinators already do this; deferred in Phase 3 and still the right call |
| Pipe-based data transmission | Requires auto-transfer rewrite with no gameplay gain |
| Wire-based instant transmission | Same; the belt model is intuitive and working |
| Processed Data / Insights items | Second resource tier adds complexity without clear player value; revisit post-launch |

---

## Rough Sequence

```
now
 │
 ├── Pre-work: performance test (1-2 days)
 │
 ├── M1: Technical Debt (~2 weeks)
 │      data-system + dashboard changes only, no new entities
 │
 ├── M2: Incidents (~3 weeks)
 │      new script, dashboard tab, 3 incident types
 │
 ├── M3: Defense (~4 weeks)
 │      new entity prototypes + sprites, security script, force setup
 │
 ├── M4: Space Age (~3 weeks, optional)
 │      surface links, 4 planetary entities, relay
 │
 └── M5: Ship It (~2 weeks)
        polish, achievements, mod portal
```

Total to v1.0 (without Space Age): ~11–12 weeks of part-time work.
Total to v1.0 (with Space Age): ~14–15 weeks.
