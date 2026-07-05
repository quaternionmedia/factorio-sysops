# Factorio: Sysadmin - Entity Specifications (Revised)

## Design Principle

All IT entities are **new additions** that work alongside vanilla entities. They occupy their own layer and interact with vanilla through defined integration points.

---

## Network Layer

### Network Cables

Network cables transport data packets. They function similarly to belts but exist on a separate layer and don't collide with vanilla infrastructure.

| Cable Type | Unlocked By | Bandwidth | Max Length | Crafted From |
|------------|-------------|-----------|------------|--------------|
| Basic Network Cable | IT Basics | 100 data/s | 50 tiles | Copper Cable, Plastic |
| Fiber Cable | Advanced Networking | 1000 data/s | Unlimited | Glass, Copper, Plastic |
| Quantum Link | Quantum Research | Instant | Cross-surface | Space materials |

**Placement**: Can be placed over belts, pipes, rails (different layer)  
**Visual**: Thin cables that run along ground, distinct from power poles  
**Underground**: Conduit variant for crossing obstacles

### Network Switch

Routes data from one input to multiple outputs.

| Property | Value |
|----------|-------|
| Size | 1x1 |
| Power | 10kW |
| Ports | 1 in, 4 out |
| Throughput | 500 data/s total |
| Unlocked By | IT Basics |

**Behavior**: Splits incoming data evenly or by configured priority

### Network Router

Advanced routing with filtering and load balancing.

| Property | Value |
|----------|-------|
| Size | 2x2 |
| Power | 50kW |
| Ports | 4 in, 8 out |
| Throughput | 5000 data/s |
| Unlocked By | Advanced Networking |

**Behavior**: Configurable routing rules, can filter by data type

---

## Monitoring Layer

### Data Sensor

Attaches to vanilla entities to collect operational data.

| Property | Value |
|----------|-------|
| Size | 1x1 (attachable) |
| Power | 5kW |
| Range | Single entity or 5x5 area |
| Data Rate | Varies by monitored entity |
| Unlocked By | IT Basics |

**Attachment Mode**: Place adjacent to entity, automatically links  
**Area Mode**: Covers 5x5 area, collects from all entities within  
**Output**: Raw Data Packets to connected network cable

### Log Collector

Aggregates data from multiple sensors.

| Property | Value |
|----------|-------|
| Size | 2x2 |
| Power | 50kW |
| Range | 50 tile radius |
| Capacity | 100 sensors |
| Throughput | 1000 data/s |
| Unlocked By | Monitoring Systems |

**Behavior**: Automatically connects to sensors in range  
**Output**: Bundled data stream to servers

### Dashboard Terminal

Player interface for viewing factory metrics.

| Property | Value |
|----------|-------|
| Size | 2x2 |
| Power | 20kW |
| Display | Opens GUI on click |
| Unlocked By | IT Basics |

**GUI Features**:
- Real-time throughput graphs
- Entity health status
- Alert history
- Technical debt meter
- Efficiency scores

### Alert Beacon

Visual and audio notification for incidents.

| Property | Value |
|----------|-------|
| Size | 1x1 |
| Power | 5kW |
| Range | Visual: 100 tiles, Audio: map-wide |
| Unlocked By | Monitoring Systems |

**Behavior**: Lights up and sounds alarm when triggered by IT system  
**Configurable**: Alert types, colors, sounds

---

## Processing Layer

### Basic Server

Entry-level data processing.

| Property | Value |
|----------|-------|
| Size | 2x2 |
| Power | 200kW |
| Processing | 50 raw data/s → 25 processed data/s |
| Heat | Generates 100kJ/s (needs cooling consideration) |
| Unlocked By | IT Basics |

**Input**: Raw Data Packets via network  
**Output**: Processed Data via network

### Advanced Server

Higher throughput processing.

| Property | Value |
|----------|-------|
| Size | 2x2 |
| Power | 500kW |
| Processing | 200 raw data/s → 150 processed data/s |
| Heat | 300kJ/s |
| Unlocked By | Server Technology |

**Bonus**: Can run basic automation scripts

### Server Rack

Consolidated server deployment.

| Property | Value |
|----------|-------|
| Size | 3x2 |
| Power | 1MW |
| Processing | 500 raw data/s → 400 processed data/s |
| Slots | 4 module slots |
| Heat | 800kJ/s |
| Unlocked By | Data Center Technology |

**Modules**: Speed, Efficiency, Redundancy

### Data Center

Large-scale processing facility.

| Property | Value |
|----------|-------|
| Size | 6x4 |
| Power | 5MW |
| Processing | 2000 data/s |
| Features | Built-in storage, redundancy |
| Heat | 4MJ/s (requires active cooling) |
| Unlocked By | Enterprise IT |

**Special**: Enables advanced automation, ML processing

### ML Processor

Creates Insights from Processed Data.

| Property | Value |
|----------|-------|
| Size | 3x3 |
| Power | 2MW |
| Processing | 100 processed data → 10 insights |
| Time | 10 seconds per batch |
| Unlocked By | Machine Learning |

**Output**: Insights enable optimization features

---

## Storage Layer

### Data Buffer

Prevents data decay, temporary storage.

| Property | Value |
|----------|-------|
| Size | 1x1 |
| Power | 10kW |
| Capacity | 1000 data packets |
| Unlocked By | IT Basics |

**Behavior**: FIFO buffer, outputs when downstream available

### Data Storage Array

Long-term data retention.

| Property | Value |
|----------|-------|
| Size | 2x2 |
| Power | 100kW |
| Capacity | 100,000 data packets |
| Retention | Indefinite |
| Unlocked By | Storage Systems |

**Use**: Historical data, compliance, backup

### Data Lake

Massive archival storage.

| Property | Value |
|----------|-------|
| Size | 4x4 |
| Power | 500kW |
| Capacity | 10,000,000 data packets |
| Access Speed | Tiered (hot/warm/cold) |
| Unlocked By | Enterprise IT |

---

## Automation Layer

### Automation Controller

Executes rules based on data conditions.

| Property | Value |
|----------|-------|
| Size | 2x2 |
| Power | 100kW |
| Rules | 20 concurrent |
| Unlocked By | IT Automation |

**GUI**: Visual rule editor  
**Inputs**: Processed Data, Insights  
**Outputs**: Circuit network signals, Entity controls

### Circuit Bridge

Connects IT network to vanilla circuit network.

| Property | Value |
|----------|-------|
| Size | 1x1 |
| Power | 5kW |
| Throughput | 100 signals/s |
| Unlocked By | IT Automation |

**Bidirectional**: IT → Circuit and Circuit → IT

### Entity Controller

Direct control of vanilla entities via IT.

| Property | Value |
|----------|-------|
| Size | 1x1 (attachable) |
| Power | 20kW |
| Control | On/off, recipe, priority |
| Unlocked By | Advanced Automation |

**Attaches to**: Assemblers, inserters, belts, etc.  
**Controlled by**: Automation Controller decisions

### Orchestration Controller

Master automation for entire factory sections.

| Property | Value |
|----------|-------|
| Size | 3x3 |
| Power | 500kW |
| Scope | 200 tile radius |
| Features | Self-healing, optimization |
| Unlocked By | Orchestration |

**Capabilities**:
- Automatic entity restart after incidents
- Load balancing across production lines
- Predictive scaling (with ML)
- Multi-controller coordination

---

## Security Layer

### Firewall

Basic cyber threat protection.

| Property | Value |
|----------|-------|
| Size | 2x2 |
| Power | 100kW |
| Protection | 50 tile radius |
| Blocks | Script kiddies, basic malware |
| Unlocked By | IT Security |

**Behavior**: Automatically blocks known threat signatures

### Intrusion Detection System (IDS)

Detects but doesn't block threats.

| Property | Value |
|----------|-------|
| Size | 2x2 |
| Power | 150kW |
| Detection Range | 100 tiles |
| Detects | All threat types |
| Unlocked By | Security Systems |

**Output**: Alerts, threat data for analysis

### Intrusion Prevention System (IPS)

Detects and blocks threats.

| Property | Value |
|----------|-------|
| Size | 3x3 |
| Power | 300kW |
| Range | 75 tiles |
| Blocks | Most threat types |
| Unlocked By | Advanced Security |

### Security Operations Center (SOC)

Central security management.

| Property | Value |
|----------|-------|
| Size | 5x5 |
| Power | 1MW |
| Range | Entire surface |
| Features | Correlation, forensics, auto-response |
| Unlocked By | Enterprise Security |

**Capabilities**:
- Coordinates all security buildings
- Threat pattern analysis
- Automated incident response
- Security postmortems

### Honeypot

Decoy system to attract and study threats.

| Property | Value |
|----------|-------|
| Size | 2x2 |
| Power | 50kW |
| Effect | Attracts threats away from real systems |
| Bonus | +50% threat intelligence from captured attacks |
| Unlocked By | Security Systems |

---

## Support Buildings

### Cooling Tower

Manages heat from IT equipment.

| Property | Value |
|----------|-------|
| Size | 3x3 |
| Power | 200kW |
| Cooling | 2MJ/s heat dissipation |
| Requires | Water (10/s) |
| Unlocked By | Data Center Technology |

**Required for**: Data Centers, ML facilities operating at capacity

### UPS (Uninterruptible Power Supply)

Backup power for IT systems.

| Property | Value |
|----------|-------|
| Size | 2x2 |
| Capacity | 50MJ |
| Output | 1MW max |
| Recharge | 500kW |
| Unlocked By | Power Management |

**Behavior**: Maintains IT systems during power fluctuations

### On-Call Station

Spawns engineer drones for incident response.

| Property | Value |
|----------|-------|
| Size | 3x3 |
| Power | 100kW |
| Capacity | 10 engineers |
| Recharge | 1 engineer/minute |
| Unlocked By | Incident Management |

**Engineers**: Automated units that resolve IT incidents

---

## Cyber Threat Entities (New Enemy Type)

### Overview

Cyber threats are a new enemy type that attacks IT infrastructure. They don't interact with vanilla combat - biters attack walls, cyber threats attack servers.

### Threat Spawning

- Spawn from "Dark Web Portals" (new spawner type)
- Attracted by Technical Debt (like pollution attracts biters)
- Appear at map edges and near IT infrastructure

### Threat Types

| Threat | Health | Speed | Damage | Target |
|--------|--------|-------|--------|--------|
| Script Kiddie | 50 | Fast | 5/s | Firewalls |
| Malware Bot | 100 | Medium | 10/s | Servers |
| Ransomware | 200 | Slow | 20/s | Storage |
| APT Agent | 500 | Slow | 15/s | All IT, stealthy |
| Zero-Day | 1000 | Fast | 50/s | Bypasses firewalls |

### Threat Behavior

- **Script Kiddie**: Direct attack, easily blocked
- **Malware Bot**: Spreads to adjacent IT buildings
- **Ransomware**: Encrypts storage, requires restore
- **APT Agent**: Invisible until attacks, targets high-value
- **Zero-Day**: Ignores basic defenses, requires IPS/SOC

### Damage Effects

When IT buildings take damage:
- Processing slows
- Data loss occurs
- Technical Debt increases
- Efficiency bonuses reduced

When IT buildings destroyed:
- All connected systems affected
- Major Technical Debt spike
- Factory efficiency penalties
- Incident generated

---

## Vanilla Integration Summary

| IT Entity | Integrates With | Integration Method |
|-----------|-----------------|-------------------|
| Data Sensor | All vanilla entities | Attachment/proximity |
| Circuit Bridge | Circuit network | Signal conversion |
| Entity Controller | Assemblers, inserters, etc. | Direct control |
| Automation Controller | Factory sections | Circuit + Entity control |
| Alert Beacon | Player | Visual/audio notification |
| Dashboard | Player | GUI interface |

### No Collision With

- Belts (network cables on different layer)
- Pipes (cables cross over)
- Power poles (separate infrastructure)
- Rails (cables go under/over)
- Walls (IT has own defense)
