# Factorio: Sysadmin POC - Quickstart Guide

## Prerequisites

1. Install the mod: `python sysadmin-poc/scripts/install-mod.py install` (auto-detects
   your Factorio mods folder; pass `--dest PATH` to override, `locate` to just print
   detected paths)
2. Start a new game or load an existing save
3. Research "IT Basics" technology (requires Electronics and Circuit Network)

---

## Data Transmission Overview

Data in the sysadmin mod flows as physical **Data Packets** - items that move through your IT infrastructure.

### Transmission Methods

| Method | Description | POC Status |
|--------|-------------|------------|
| **Belt (Network Cable)** | Data packets auto-transfer (no inserters needed) | **Implemented** |
| **Pipe** | Fluid-based data flow (future) | Planned |
| **Wire** | Instant circuit-based transmission (future) | Planned |

The POC uses belt-based transmission with auto-transfer:
- **No inserters required** - sensors and servers auto-connect to adjacent cables
- **Ultra-high speed** (1.0) - faster than express belts for near-instant data flow
- **Dark-tinted cables** - black belt appearance with orange data packets visible
- Familiar Factorio belt mechanics under the hood
- Supports underground cables and splitters for routing

**Visual Design:** Network cables are dark/black tinted to contrast with orange data packets flowing on them.

---

## Bare Minimum Setup

This is the simplest working configuration to demonstrate the POC functionality.

### What You Need

| Item | Quantity | Purpose |
|------|----------|---------|
| Assembling Machine | 1+ | Generates crafting activity (monitored) |
| Data Sensor | 1 | Collects data from nearby assemblers |
| Network Cable | 1+ | Transports data packets (auto-transfer) |
| Network Cable Underground | As needed | Route cables through obstacles |
| Network Cable Splitter | As needed | Split/merge data streams |
| Basic Server | 1 | Processes data packets |
| Dashboard Terminal | 1 | View IT metrics (optional but recommended) |
| Circuit Bridge | 1 | Circuit network integration (optional) |

**No inserters needed!** Data flows automatically between adjacent entities.

### Step-by-Step Setup

```
Layout (top-down view):

    [Assembler]
         |
    [Data Sensor] → [Cable] → [Cable] → [Cable] → [Server]
         ↑                                            ↑
    (auto-output)                               (auto-input)

    [Dashboard Terminal]  [Circuit Bridge]
```

1. **Place an Assembling Machine**
   - Set it to craft something (e.g., iron gear wheels)
   - Ensure it has input materials

2. **Place a Data Sensor**
   - Place within 5 tiles of the assembler
   - The sensor will automatically detect and monitor the assembler
   - Custom cyan/antenna sprite

3. **Connect with Network Cable**
   - Place a network cable **adjacent** to the sensor (touching it)
   - Data packets will auto-transfer from sensor to cable
   - Extend cables toward your server

4. **Place a Basic Server**
   - Place **adjacent** to the end of the network cable
   - Data packets will auto-transfer from cable to server
   - Custom green server rack sprite (1x1 size)
   - Will automatically process data packets
   - Requires power (200kW)

5. **Place Dashboard Terminal** (optional)
   - Custom purple monitor sprite
   - Click to open the IT Dashboard GUI
   - Shows live metrics

6. **Place Circuit Bridge** (optional)
   - Custom yellow combinator sprite
   - Connect with red/green wires to read IT signals

---

## Entity Visuals

All entities have custom programmatically-generated sprites:

| Entity | Visual | Description |
|--------|--------|-------------|
| Data Sensor | Cyan | Antenna with signal waves, industrial body |
| Basic Server | Green | Server rack with LEDs, drive bays, cooling fan |
| Circuit Bridge | Yellow | PCB with circuit traces, wire connection points |
| Dashboard Terminal | Purple | Monitor with bar chart display on stand |
| Network Cable | Dark/Black | Dark-tinted belt with orange directional arrows |
| Network Cable Underground | Dark/Black | Dark underground belt variant |
| Network Cable Splitter | Dark/Black | Dark splitter for load balancing |
| Data Packet | Blue | Folded document with data lines |

**Regenerating graphics:**
```bash
cd sysadmin-poc
python scripts/generate-icons.py    # 32x32 icons
python scripts/generate-sprites.py  # 64x64 entity sprites
```

---

## Blueprint String

Import this blueprint in-game: Open inventory → Import String (Ctrl+Shift+V)

```
0eNqVk01vgzAMhv9KlDOZSgvtynE77TBtUnebpikEt7UGBiVhXVXx3+dCxSq1TOWArHzwvI7t9yDTvIbKInmZHCR6KGRythfIXKeQ895q73RWIInXl0ehxDMSFjoXK/B1xdcycMZi5bEkvvygHRrx9CaQ1lY7b2vjawuJcECutAFH+w0cM+22aaltFghNmTBoTY1epBazDTAWTUlOJu8H6XBDOj8m6fcVsEabayBJF8dVelRUHVY2/CNl8COTsPkIJJBHj9Bx2sX+k+oi5ZtJ2BO0c1CkOdJGFdpskUCFzK9Kh92rDpKBk7s4kPs2sooFg10ytiS1AW3Vbgtcrya4UJr2Spn2WnWVGBaYssAVyqynrLmuComf7OEKJzzjcHuQU+1OoyvUqKcS+F1pv5TRaQ6X1OkYanwrdTaGOr+VGo2hLm6lxmOo97d2az6Gurw+9RfQ+/8GKZyczePJhIpzY4uzzQbHMhqg/fno5GHVe3ig2S2J3cmpu/Y0nk+X0XIZ8xeFi3nT/ALSB4Va
```

**Blueprint contains:**
- 1× Assembling Machine 1 (set to craft iron gear wheels)
- 1× Data Sensor
- 4× Network Cable
- 1× Basic Server
- 1× Dashboard Terminal
- 1× Circuit Bridge

**Note:** No inserters needed - auto-transfer handles data flow between adjacent entities.

---

## Verify It's Working

### Visual Indicators
- A **green arrow** appears above the assembler = monitored and active
- A **red arrow** = emergency stop active
- A **yellow/orange arrow** = circuit-paused (disabled by circuit signal)
- A **cyan/blue arrow** = circuit-enabled (forced on by circuit signal)

### Dashboard Metrics
Click the Dashboard Terminal to see:
- **Monitored Assemblers**: Should show 1+
- **Data Throughput**: Items crafted per second
- **Server Utilization**: 0-100%
- **Data Backlog**: Packets waiting to be processed
- **Total Processed**: Cumulative packets processed

### Console Commands
For debugging, use these commands:
```
/sysadmin-stats     -- Show all IT metrics
/sysadmin-circuit   -- Show circuit bridge readings
/sysadmin-transfer  -- Debug auto-transfer system
/sysadmin-control   -- Show sensor circuit control state
```

### Circuit Signals
If you connected the Circuit Bridge to a circuit network, you'll see these **output signals**:
- `signal-throughput` = Total throughput
- `signal-data-rate` = Data rate (packets/sec)
- `signal-utilization` = Server utilization %
- `signal-monitored-count` = Monitored assemblers count
- `signal-data-backlog` = Data backlog count

### Circuit Control
Connect a circuit wire to a Data Sensor to control its monitored machines using `signal-it-control`:
- **Positive value (>0)**: Enable/resume monitored assemblers
- **Negative value (<0)**: Disable/pause monitored assemblers
- **Zero (0)**: No override (normal operation, respects emergency stop)

This allows circuit-based automation like:
- Emergency shutdown via decider combinators
- Load shedding based on backlog thresholds
- Time-based schedules using clock circuits

---

## Troubleshooting

### No data packets appearing in sensor
- Ensure assembler is within 5 tiles of sensor
- Ensure assembler is actually crafting (has recipe + inputs)

### Data backlog keeps growing
- Add more Basic Servers to increase processing capacity
- Each server can process 10 data packets per crafting cycle
- Watch the Dashboard for backlog alerts

### Dashboard shows no metrics
- Wait a few seconds - metrics update every 60 ticks (1 second)
- Verify the mod loaded correctly in the mod menu

### Graphics not showing
- Ensure graphics were generated: run `python scripts/generate-sprites.py`
- Check that `graphics/entity/` contains PNG files

---

## Next Steps

Once basic setup works:
1. Add more assemblers near the sensor (within 5 tiles)
2. Build more servers to handle increased data load
3. Watch for backlog warnings - add servers to keep up
4. Use circuit signals to automate responses (e.g., enable/disable machines)

### Backlog Thresholds
| Backlog | Status | Alert |
|---------|--------|-------|
| 0-99 | Normal | Green status |
| 100-499 | Warning | Yellow alert |
| 500-999 | Critical | Orange alert |
| 1000+ | Severe | Red alert |

---

## Implementation Status

### Completed ✓
- [x] Core entity prototypes (sensor, cable, server, bridge, dashboard)
- [x] Network cable variants (underground, splitter)
- [x] Data packet items and processing recipe
- [x] IT Basics technology unlock
- [x] Dashboard GUI with live metrics
- [x] Visual indicators on monitored assemblers
- [x] Alert system with state transitions
- [x] Circuit bridge signal output
- [x] Auto-transfer system (no inserters needed)
- [x] Item filtering (only data-packets on cables)
- [x] IT Infrastructure crafting menu tab
- [x] Dark-tinted belt appearance
- [x] Programmatic icon generation (32x32)
- [x] Programmatic entity sprite generation (64x64)
- [x] Debug console commands
- [x] Radius indicator for sensor range (shows when selected)
- [x] Circuit-controlled entity enable/disable via signal-it-control

### Future
- [ ] Per-sensor circuit signals (individual sensor metrics)
- [ ] Server upgrades (Advanced Server, High-Performance Server)
- [ ] Alternative transmission methods (pipe, wire)
- [ ] Incident/failure system
- [ ] Space Age integration
