# DataFactorio Integration Overview

**DataFactorio** (https://github.com/quaternionmedia/datafactorio) is an
out-of-game dashboard that exports Factorio save data as an interactive graph.
It already understands recipes, entities, technologies, logistics, and power
networks. This document outlines how the sysadmin mod can integrate with it
to add an IT infrastructure layer — both for this mod's custom entities and as
a richer overlay on the base game's factory graph.

---

## What DataFactorio Does

- A Lua mod runs inside Factorio; pressing Ctrl+Shift+J exports a JSON snapshot
  to `script-output/datafactorio/`
- A Python CLI (`datafactorio sync`) watches that directory and imports each
  snapshot into SQLite
- A FastAPI server exposes the data at `http://localhost:8000/api/`
- A D3.js frontend renders an interactive force-directed graph of nodes (items,
  recipes, entities, technologies) and edges (produces, consumes, powers,
  transports, unlocks, etc.)

The system is file-based and fully decoupled — no RCON, no live connection to
the game process.

---

## Why Integrate

DataFactorio already shows *what your factory produces*. The sysadmin mod adds
*how well your IT infrastructure is serving it*. Together they answer questions
like:

- Which production areas have IT monitoring coverage and which are dark?
- Which assemblers are under an active incident right now?
- Where is data backlog concentrated, and does it correlate with a bottleneck
  in the production graph?
- What is the IT network topology — sensor → cable → server — overlaid on the
  physical factory map?

Neither project alone answers all of these. The integration is optional and
additive for both.

---

## Integration Approaches

Three tiers, ordered by effort. Each is independent — you can stop at any tier.

---

### Tier 1: Sidecar Export (Low Effort, ~2 days)

**How it works:** The sysadmin mod adds an export handler that fires alongside
DataFactorio's Ctrl+Shift+J shortcut (or a separate keybind). It writes a
companion JSON file to `script-output/datafactorio/` with the IT infrastructure
snapshot. DataFactorio's existing CLI and storage pipeline picks it up as a
second graph, or a future parser extension can merge it.

**Sysadmin mod changes (`control.lua`):**

```lua
-- Detect DataFactorio mod
if script.active_mods["datafactorio"] then
  -- Hook into DataFactorio's export event (if it raises one)
  -- OR register our own keybind (Ctrl+Shift+I)
  input.on_key_combination("sysadmin-export", function(event)
    export_it_snapshot(game.players[event.player_index])
  end)
end

local function export_it_snapshot(player)
  local data = build_it_export()
  local json = game.table_to_json(data)
  game.write_file(
    "datafactorio/sysadmin-" .. game.tick .. ".json",
    json, false, player.index
  )
  player.print("[Sysadmin] IT snapshot exported.")
end
```

**Export schema** — extends DataFactorio's node/edge model with new types:

```json
{
  "save_name": "my-factory",
  "game_version": "2.0.0",
  "tick": 123456,
  "mods": [{ "name": "sysadmin-poc", "version": "0.1.0" }],
  "source": "sysadmin",

  "it_nodes": {
    "sensor_42": {
      "type": "it-sensor",
      "name": "data-sensor",
      "position": { "x": 10, "y": 20 },
      "sensor_id": 3,
      "monitored_count": 5,
      "data_backlog": 47,
      "data_rate": 12,
      "control_state": "normal"
    },
    "server_99": {
      "type": "it-server",
      "name": "advanced-server",
      "position": { "x": 25, "y": 20 },
      "tier": 2,
      "utilization_pct": 74
    }
  },

  "it_edges": [
    { "source": "sensor_42", "target": "assembler_101",
      "type": "monitors", "weight": 5 },
    { "source": "sensor_42", "target": "cable_77",
      "type": "transmits-to", "weight": 12 },
    { "source": "cable_77",  "target": "server_99",
      "type": "feeds", "weight": 47 }
  ],

  "it_metrics": {
    "technical_debt":   312,
    "efficiency_bonus": 0.08,
    "active_incidents": 1,
    "security_status":  0,
    "monitored_count":  27
  }
}
```

**DataFactorio side (minimal change):** The CLI already imports any JSON in
the watched directory. The parser would need a small addition to recognise
`"source": "sysadmin"` and load `it_nodes` / `it_edges` as a parallel graph.
Alternatively, the IT data can be surfaced as a second save-group in the
existing UI with no parser changes at all.

**Deliverable:** IT network visible as a standalone graph in DataFactorio.
Clicking a sensor node shows its metrics; clicking an edge shows throughput.

---

### Tier 2: Factory Overlay (Medium Effort, ~2 weeks)

**How it works:** DataFactorio's frontend is extended to render IT nodes as a
second layer overlaid on the factory entity graph. Assembler nodes get a
colour badge showing IT coverage state (monitored / unmonitored / incident).

**DataFactorio frontend changes (`src/datafactorio/static/js/`):**

1. **New node type renderer** — `it-sensor`, `it-server`, `it-cable` nodes
   rendered with IT colour palette (cyan/green/orange, matching the in-game
   sprites) and a distinct shape (hexagon vs. circle for factory nodes)

2. **Coverage badge** — for each `assembling-machine` node already in the graph,
   check whether any `monitors` edge connects it to an IT sensor. Render a
   small coloured dot:
   - Cyan dot = monitored, healthy
   - Yellow dot = monitored, high backlog
   - Red dot = active incident
   - No dot = unmonitored

3. **IT metrics sidebar panel** — alongside the existing recipe/entity info
   panel, add an "IT Status" panel showing: debt level, incident list,
   efficiency bonus, security status

4. **Toggle layer button** — "Show IT layer" checkbox in the toolbar so users
   can hide IT overlay if they only want the production graph

**DataFactorio backend changes (`src/datafactorio/parser.py`):**

```python
# Add IT node types to the existing hierarchy detection
IT_NODE_TYPES = {"it-sensor", "it-server", "it-cable", "it-bridge"}

def parse_sysadmin_export(data: dict) -> list[Node]:
    nodes = []
    for node_id, node_data in data.get("it_nodes", {}).items():
        nodes.append(Node(
            id=node_id,
            type=node_data["type"],
            name=node_data["name"],
            mod_source="sysadmin-poc",
            data=node_data,
        ))
    return nodes

def parse_sysadmin_edges(data: dict) -> list[Edge]:
    edges = []
    for edge in data.get("it_edges", []):
        edges.append(Edge(
            source=edge["source"],
            target=edge["target"],
            type=edge["type"],    # "monitors", "transmits-to", "feeds"
            weight=edge.get("weight", 1.0),
        ))
    return edges
```

New edge types to register in DataFactorio's `EDGE_TYPES.md`:

| Type | Source | Target | Weight | Meaning |
|------|--------|--------|--------|---------|
| `monitors` | it-sensor | assembling-machine | monitored entity count | Sensor covers this assembler |
| `transmits-to` | it-sensor / it-cable | it-cable / it-server | data rate (packets/s) | Data flow direction |
| `feeds` | it-cable | it-server | backlog count | Cable supplies server |
| `outputs-it` | it-server | it-bridge | processed count | Server → circuit bridge |

**Deliverable:** DataFactorio shows factory + IT together. Production bottlenecks
that overlap with high-debt or incident areas are immediately visible.

---

### Tier 3: Live Metrics via RCON (High Effort, optional)

**How it works:** DataFactorio adds an optional RCON poller that periodically
calls a sysadmin mod command (e.g. `/sysadmin-export-rcon`) and receives a
compact JSON payload. This enables near-real-time metric updates in the
DataFactorio frontend without requiring the player to manually trigger an export.

**Tradeoffs:**
- Requires Factorio RCON to be enabled (server config change)
- DataFactorio must handle RCON authentication and polling loop
- Adds a live dependency that the file-based approach avoids
- Primarily valuable for long-running multiplayer server dashboards

**Implementation sketch:**

Sysadmin mod side:
```lua
commands.add_command("sysadmin-rcon-metrics", "", function(cmd)
  -- Returns compact JSON string; designed for RCON callers
  local payload = {
    tick           = game.tick,
    debt           = storage.technical_debt.total,
    backlog        = storage.metrics.data_backlog,
    throughput     = storage.metrics.total_throughput,
    incidents      = table_size(storage.incidents),
    security       = storage.security and storage.security.status or 0,
  }
  rcon.print(game.table_to_json(payload))
end)
```

DataFactorio side — new optional `rcon_poller.py`:
```python
import rcon, asyncio

async def poll_sysadmin(host, port, password, interval=5):
    async with rcon.RCONClient(host, port, password) as client:
        while True:
            raw = await client.send("/sysadmin-rcon-metrics")
            metrics = json.loads(raw)
            await storage.update_it_metrics(metrics)
            await asyncio.sleep(interval)
```

**Recommendation:** Implement Tier 1 and Tier 2 first. Tier 3 is only worth
the complexity for a dedicated multiplayer server scenario.

---

## What Each Project Needs to Change

### Sysadmin Mod

| File | Change |
|------|--------|
| `control.lua` | Export handler (keybind or DataFactorio event hook) |
| `scripts/datafactorio-export.lua` | **new** — builds IT snapshot JSON |
| `prototypes/custom-input.lua` | **new** (if custom keybind) |
| `info.json` | Add `"? datafactorio"` as optional dependency |
| `locale/en/locale.cfg` | Export confirmation message |

The export script reads directly from `storage.sensors`, `storage.servers`,
`storage.technical_debt`, `storage.incidents`, `storage.security` — no new
tracking needed since Milestone 1–3 add all of these.

### DataFactorio

| File | Change |
|------|--------|
| `src/datafactorio/parser.py` | Parse `it_nodes`, `it_edges`, `it_metrics` |
| `src/datafactorio/models.py` | Add IT node types and edge types to enums |
| `src/datafactorio/static/js/graph/` | IT overlay renderer, coverage badges |
| `src/datafactorio/static/js/ui/` | IT metrics sidebar panel |
| `src/datafactorio/static/css/` | IT node colours (cyan, orange, green) |
| `docs/EDGE_TYPES.md` | Document new IT edge types |

---

## Integration Sequencing

The integration depends on Milestones 1–2 being complete first, because:

- **Tier 1** only needs the sysadmin export script — can be done any time
- **Tier 2** needs `technical_debt` and `incidents` in the export to show
  meaningful overlays (otherwise it's just topology with no state)
- **Tier 3** needs `storage.security` from Milestone 3

Recommended order:
```
M1 complete → write datafactorio-export.lua → Tier 1 working
M2 complete → update export + DataFactorio parser → Tier 2 overlay
M3 complete → add security metrics to export
             → optionally implement Tier 3 for multiplayer servers
```

---

## Base Game Value (Without Sysadmin Mod)

Even without the sysadmin mod, the DataFactorio integration approach above is
worth documenting because DataFactorio itself already provides:

- Recipe dependency graphs (visualise your production chain)
- Technology trees with unlock status
- Entity maps with logistics connections
- Inventory snapshots for any save

Players who run this mod alongside DataFactorio get the factory graph **and**
the IT infrastructure graph in the same tool, with cross-referencing between
them (e.g. "assembler X is in a critical-debt zone and is also a bottleneck
in the production chain for green circuits").

This makes the DataFactorio integration a genuine value multiplier, not just
a nice-to-have visual.
