# Multi-Repo Dev Environment — Handoff Prompt

Copy this prompt verbatim into a new Claude Code session that has both repos
checked out. Adjust the paths at the top to match your local setup.

---

```
## Context

I'm building a Factorio mod called "Sysadmin: IT Infrastructure" alongside an
optional integration with the DataFactorio out-of-game dashboard.

### Repos

| Repo | Path | Purpose |
|------|------|---------|
| factorio-sysops | ~/repos/factorio-sysops | Mod source and design docs |
| datafactorio    | ~/repos/datafactorio    | Out-of-game dashboard (Python/FastAPI/D3.js) |

The Factorio mod folder is at:
  C:\Users\<you>\AppData\Roaming\Factorio\mods\sysadmin-poc\
(symlinked or copied from ~/repos/factorio-sysops/sysadmin-poc/)

---

### Where We Are: Milestone 1 just implemented

Milestone 1 ("Consequences") is written but **not yet tested in-game**.
The following files were added or changed:

**New:**
- sysadmin-poc/scripts/technical-debt.lua  — debt accumulation + penalty fraction

**Modified:**
- sysadmin-poc/control.lua                 — requires TechnicalDebt, calls init() + tick()
- sysadmin-poc/scripts/circuit-control.lua — reads storage.debt_penalty_fraction in
                                              NORMAL state; new "debt_paused" display state
- sysadmin-poc/scripts/circuit-interface.lua — slot 6 on circuit bridge: signal-technical-debt
- sysadmin-poc/prototypes/signals.lua       — signal-technical-debt prototype
- sysadmin-poc/gui/dashboard.lua            — Technical Debt row + colored status label
- sysadmin-poc/scripts/generate-icons.py   — draw_signal_technical_debt() + registered
- sysadmin-poc/locale/en/locale.cfg         — signal-technical-debt locale string
- sysadmin-poc/graphics/icons/signals/signal-technical-debt.png  — generated icon

**How the penalty works (important context for debugging):**
- storage.debt_penalty_fraction is set by TechnicalDebt.tick() every 60 ticks (0.0–0.20)
- circuit-control.lua reads it in CircuitControl.update() (every 10 ticks)
- Assemblers in NORMAL state (not circuit-controlled) are selectively disabled:
  entity.active = (assembler_id % 100) >= math.floor(penalty * 100)
- At 20% penalty: assemblers with unit_number % 100 < 20 are paused
- Circuit-enabled/circuit-disabled assemblers are NOT affected by debt penalty
- Emergency stop still takes precedence over everything

**Dashboard changes:**
- New "Technical Debt" row shows: debt value (0-1000), level string, penalty % if active
- Row color: green (low) → yellow (moderate) → orange (high) → red (critical)
- Status label now checks debt level first, backlog second

**Circuit bridge:**
- slot 6 now outputs signal-technical-debt (integer 0-1000)

---

### First task: in-game verification

Before moving to Milestone 2, verify Milestone 1 works correctly:

1. Install/refresh the mod: `python sysadmin-poc/scripts/install-mod.py install`
   (auto-detects the Factorio mods folder), then load a save
2. Set up a test factory: assemblers → sensors → cables → servers -- or paste
   the test blueprint below, which sets up two chains for step 5
3. Disconnect the server (stop draining packets) and watch:
   - Data backlog climbs in dashboard
   - Technical Debt row increments (takes ~30s to start)
   - At debt > 500, some assemblers should pause (check with /sysadmin-control)
   - Circuit bridge slot 6 should show signal-technical-debt > 0
4. Reconnect the server: confirm debt recovers and assemblers resume
5. Test that circuit-controlled (CIRCUIT_ENABLED) assemblers are NOT paused by debt
6. Test that /sysadmin-stats still works without errors
7. Run with 50+ sensors and check /time-usage for performance (target: <1ms on
   the 60-tick bucket and <0.5ms on the 10-tick bucket)

### Test blueprint (steps 2-5)

Two independent chains: Chain A (assembler/sensor/cables/server, y=0.5-4.5) is
plain NORMAL -- its assembler should pause once the debt penalty kicks in.
Chain B (y=6.5-10.5) has a constant combinator next to its sensor; wire it to
the Chain B data-sensor (either wire color), then open the combinator and set
its output signal to `signal-it-control` = 1 and enable it -- Chain B's
assembler should keep running through the same debt pause, confirming step 5.
A dashboard terminal and circuit bridge are included on Chain A for steps 3-4.

```
0eNqlllFv0zAQx7/KqS/bpLlburZrJ/EwNhBIjCEYTwghxzkaq4kd2RdKNfW7c05SkYlWbcJD1Tix/7+789+XPA/irMTCaUODG3geaMKcL1p3z2GQyRizcPfL2ssk1wY+Pd6BgAedoSdrECK4x5jgiYdhQYJeOV2QtiYse1pZeP8EKpXaePhpHRBP1GbB/yo1WskMkrD+tKV4BgU6SKzyF+9uP94/vn0rHr5+eHovPr/59DjMkyHcBT24hVOyxTmsX10OJ2I8nJzdwMfHzw+3H87BWFDaqVITKGvI2QyEAE0epPeYxxkTfGrLLIFClh7BGoV1KAUamdEallotPWizxb2G09gS2TwQp0yMLivkSjsESjGAPEkTiHmsjaSQrq0ebRUSSVJ4NJ4fnaLmR65er2xm3dl5mGzAIzWCW50TD7akoqQg6PWCIxSaxDa1V7wN0iTAkXNmnGZIllLtoWad7Eh7iViAK42pdiN1tlykFdXLfFuJUJkh3GvPIIOKLhw2V/VMdL/Q+RMuUghNBbivIlwF0ZAsxFItM7uowltJUmktrTKdx5UcK3DxK7176dPYSpewnRybjc0Rlt01G/na6WTB1MwSTIfBbTqUnH327XlQF6VyMq0LDOarHM2zDCdUOVt6rUQd9GATlpsEf/OTiAc7FX5pRyXfa4n8U/wXSqPNdx6hIU0am8iq0fqHKfOYuUxrqTW7wtUSuVSpNiiiQCus180Zeh4EYbYa317XV4HIpdNNms4asUDpxCpFrOL5FzpqQVsmPMAaMWun3FVL7qf0JPh4oyPcLRi9EAxdgi2vminjnYBxC2CQVtYtReWvnYBRd8CkE+CqO2DaCTDuDrjuBJh0B8w6bfK0O2C+73Du0p8d8mR0+cLjTSsR1LSSA1Yf75Vtn9fmnSLiqhUdsMp+ydH/tYBprxYQXfXqAbO9WYx7NoHZsf6IJj27wPGEac82cDzhumcfOJ4w69kIjifMe3aCowmjyz6tYK81Ry/ObPNZJv5+Th2wfPiw21Rv8vB5U8+ZTEfz8Xw+4d84up5uNn8A7+GJeQ==
```

Built programmatically (entity list/positions reusing the same fields and
belt-inserter-server spacing as the "Sysadmin POC - Minimal Setup" blueprint
in docs/POC-QUICKSTART.md) and round-trip-verified as valid Factorio
blueprint encoding -- not yet pasted into an actual game. If anything looks
off on paste, that's the thing to check first.

Known issues (fixed 2026-07-05, no longer apply):
- ~~"section.filters_count" may be 5 even after setting slot 6...~~ Fixed:
  `circuit-interface.lua` now clears a fixed 1..10 range instead of trusting
  `filters_count`.
- ~~The dashboard "value_debt" element reference...~~ Fixed: `dashboard.lua`
  now guards the debt row and skips it if absent instead of erroring; closing
  and reopening the dashboard terminal still rebuilds it with the row.

---

### Next task after verification: Milestone 2 — Incidents

See docs/MILESTONES.md for the full spec. Summary:

**New file to create:** sysadmin-poc/scripts/incidents.lua

Key design points (do NOT re-derive — use these):
- Incident spawn is checked every 600 ticks (on_nth_tick(600)); spawn probability
  per 10-second window is: moderate=0.008, high=0.025, critical=0.067
  (= per-minute rates / 6)
- Three incident types, each degrading one entity type:
    SERVER_OVERLOAD  → target random server, set entity.active = false
    CABLE_CONGESTION → target random cable, temporarily block auto-transfer
                       (set a flag in storage.cables[id].congested = true,
                        check it in DataSystem.auto_transfer())
    SENSOR_FAILURE   → target random sensor, stop data generation for 60s
                       (set storage.sensors[id].failed_until = game.tick + 3600)
- storage.incidents = {} keyed by incident_id (integer, from storage.incident_counter)
- storage.incident_history = {} (last 5 resolved, for postmortem log)
- Resolution: player clicks "Resolve" button in dashboard incidents tab
  → remove degradation, add 50 debt reduction, append to history
- Dashboard: new "Incidents" tab/section (toggle button next to existing content)
  lists active incidents; each row: type icon + entity position + elapsed time + Resolve button
- New circuit signal: signal-incident-count (add to signals.lua and circuit-interface.lua)
- Incidents do NOT spawn if debt < 200

**DataSystem changes needed for CABLE_CONGESTION:**
In data-system.lua auto_transfer(), sensor → cable loop:
  local cable_data = storage.cables[cable.unit_number]
  if cable_data and cable_data.congested then goto continue_cable end

**Control.lua changes:**
  local Incidents = require("scripts.incidents")
  -- in on_init and on_configuration_changed: Incidents.init()
  -- new: script.on_nth_tick(600, function() Incidents.tick() end)
    NOTE: there is already an on_nth_tick(600) for Indicators.cleanup_radius_indicators()
    — add Incidents.tick() inside that same handler, don't create a second one.

---

### DataFactorio integration (separate track, can run in parallel)

Repo: ~/repos/datafactorio
Integration doc: ~/repos/factorio-sysops/docs/DATAFACTORIO-INTEGRATION.md

**Tier 1 task** (lowest effort, highest value):
Create sysadmin-poc/scripts/datafactorio-export.lua that:
1. Builds an IT snapshot JSON using game.table_to_json()
2. Writes it to "datafactorio/sysadmin-TICK.json" via game.write_file()
3. Is triggered by a custom keybind (Ctrl+Shift+I) defined in a new
   sysadmin-poc/prototypes/custom-inputs.lua

The JSON schema is in docs/DATAFACTORIO-INTEGRATION.md (Tier 1 section).
Key fields: it_nodes, it_edges, it_metrics — read directly from storage.

DataFactorio parser change needed (~/repos/datafactorio/src/datafactorio/parser.py):
- Add parse_sysadmin_export(data) that reads "it_nodes" and "it_edges" keys
- Called when "source" == "sysadmin" in the top-level JSON
- Returns list[Node] and list[Edge] using the existing model classes
- Register IT node types: "it-sensor", "it-server", "it-cable", "it-bridge"
- Register IT edge types: "monitors", "transmits-to", "feeds", "outputs-it"

DataFactorio storage change (~/repos/datafactorio/src/datafactorio/storage.py):
- GraphStorage.import_file() already handles any JSON in the watch dir
- Only change needed: don't skip files with unrecognised top-level keys —
  currently unknown keys are silently dropped, which is fine for Tier 1

DataFactorio CLI change:
- datafactorio sync already watches the directory; no change needed for Tier 1
- Tier 2 will need frontend changes (separate task)

---

### Architecture decisions already locked in (don't relitigate)

- Data transport stays belt-based (no pipe/wire refactor)
- No Automation Controller entity — circuit combinators cover that use case
- Processed Data / Insights items deferred post-launch
- Debt penalty is deterministic by unit_number % 100 (not random, not per-save)
- Circuit-controlled assemblers are immune to debt penalty (circuit takes precedence)
- Emergency stop is immune to debt penalty (emergency stop always wins)
- Incident spawn gated at debt >= 200 (no incidents on fresh save)
- Space Age is fully optional (guard all space-age code with script.active_mods["space-age"])

---

### Reference: key storage keys

storage.sensors               -- keyed by unit_number, each has {entity, monitored_assemblers,
                              --   sensor_id, data_generated, last_tick_data}
storage.servers               -- keyed by unit_number, each has {entity, utilization, packets_processed}
storage.cables                -- keyed by unit_number, each has {entity}
storage.circuit_bridges       -- keyed by unit_number, each has {entity}
storage.monitored_assemblers  -- keyed by unit_number, each has {entity, sensor_id, last_products_finished}
storage.sensor_interfaces     -- keyed by sensor unit_number, each has {entity, sensor_id}
storage.sensor_control_state  -- keyed by sensor unit_number, each has {state, signal_value}
storage.metrics               -- {total_throughput, data_rate, utilization, monitored_count,
                              --    data_backlog, total_processed}
storage.technical_debt        -- {total (0-1000), history (ring buffer)}
storage.debt_penalty_fraction -- float 0.0-0.20, written by TechnicalDebt.tick()
storage.emergency_stop        -- bool
storage.next_sensor_id        -- incrementing counter
storage.incidents             -- MILESTONE 2: keyed by id
storage.incident_history      -- MILESTONE 2: last 5 resolved
storage.incident_counter      -- MILESTONE 2: integer
```
