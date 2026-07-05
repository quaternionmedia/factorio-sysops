# Factorio: Sysadmin - Core Mechanics (Revised)

## Design Principle

All mechanics **enhance** vanilla gameplay without replacing it. Players can ignore IT entirely (with penalties at scale) or fully embrace it (with significant bonuses).

---

## Data Flow System

### How Data Works

Every vanilla entity operation generates **data** as a byproduct:

```
VANILLA ENTITY OPERATION
         │
         ▼
    DATA GENERATED (invisible without sensors)
         │
    ┌────┴────┐
    ▼         ▼
UNCOLLECTED   COLLECTED (by Data Sensor)
    │              │
    ▼              ▼
 DECAYS       DATA PACKET
 (60 sec)          │
                   ▼
            NETWORK TRANSPORT
                   │
              ┌────┴────┐
              ▼         ▼
         PROCESSED   BACKLOG
         (by Server)     │
              │          ▼
              ▼     TECHNICAL DEBT
          INSIGHTS
              │
              ▼
         AUTOMATION / OPTIMIZATION
```

### Data Generation Rates

| Entity | Data per Operation | Operations Counted |
|--------|-------------------|-------------------|
| Assembler | 1 | Per craft completed |
| Inserter | 0.1 | Per item moved |
| Belt | 0.01 | Per item transported |
| Mining Drill | 0.5 | Per ore extracted |
| Furnace | 0.5 | Per smelt completed |
| Chemical Plant | 2 | Per craft completed |
| Lab | 1 | Per science consumed |
| Roboport | 0.1 | Per robot task |
| Train | 5 | Per station arrival |
| Reactor | 10 | Per second while active |
| Rocket Silo | 100 | Per launch |

### Data Without Collection

If data isn't collected (no sensors), it simply **disappears** - no penalty, no benefit. This allows players to ignore IT entirely in small factories.

### Data With Collection But No Processing

If data is collected but servers can't keep up, it becomes **Technical Debt**:
- Debt accumulates visibly
- Factory efficiency drops
- Incidents become more likely
- Solution: Add more servers or reduce collection scope

---

## Technical Debt System (Revised)

### New Definition

Technical Debt in the addon represents **unprocessed operational data** and **shortcuts in IT infrastructure** - not factory shortcuts.

### Debt Sources

| Source | Debt Rate | Player Control |
|--------|-----------|----------------|
| Unprocessed data backlog | 1/100 data/min | Add servers |
| Server at >90% capacity | 5/min | Add servers |
| Missing redundancy | 2/min | Add backup systems |
| Outdated IT equipment | 1/min | Upgrade |
| Security vulnerabilities | 3/min | Patch/upgrade |

### Debt Effects (IT Infrastructure Only)

| Debt Level | Effect |
|------------|--------|
| 0-50 | None |
| 51-100 | IT processing -10%, minor incidents |
| 101-200 | IT processing -25%, regular incidents |
| 201-500 | IT processing -50%, frequent incidents |
| 500+ | IT systems may crash, factory loses bonuses |

### Debt Does NOT Affect

- Vanilla entity operation (assemblers still work)
- Vanilla combat (biters unchanged)
- Vanilla research (labs still function)
- Basic factory operation

### Debt DOES Affect

- IT-provided efficiency bonuses (reduced/lost)
- Automation rules (may fail to execute)
- Monitoring accuracy (gaps, delays)
- Cyber threat resistance (more attacks)

### Debt Visualization

Technical debt appears as a **red/orange overlay** on IT buildings:
- Green: Healthy (0-50)
- Yellow: Warning (51-100)
- Orange: Danger (101-200)
- Red: Critical (201+)

Clicking IT buildings shows debt sources and mitigation options.

---

## Factory Efficiency Bonus System

### Core Mechanic

Properly configured IT infrastructure provides **efficiency bonuses** to connected vanilla entities.

### Bonus Tiers

| IT Coverage Level | Efficiency Bonus | Requirement |
|-------------------|------------------|-------------|
| None | 0% | - |
| Basic Monitoring | +2% | Sensors on entities |
| Full Monitoring | +5% | Log collectors, dashboards |
| Basic Automation | +8% | Automation controllers |
| Predictive | +12% | ML processors, insights |
| Full Orchestration | +20% | Orchestration controllers |
| Quantum | +35% | Quantum links |

### How Bonuses Apply

- **Assemblers**: Crafting speed bonus
- **Inserters**: Swing speed bonus
- **Mining Drills**: Mining speed bonus
- **Labs**: Research speed bonus
- **Robots**: Speed and charge rate bonus

### Bonus Calculation

```
effective_bonus = base_tier_bonus × (1 - debt_penalty) × coverage_percentage

Where:
- base_tier_bonus = tier bonus from table above
- debt_penalty = technical_debt / 1000 (capped at 0.9)
- coverage_percentage = monitored_entities / total_entities
```

### Example

Factory with 500 entities:
- 400 have sensors (80% coverage)
- Full Monitoring tier (5% base bonus)
- 100 technical debt (10% penalty)

```
effective_bonus = 5% × (1 - 0.1) × 0.8 = 3.6%
```

All 400 monitored entities get +3.6% speed.

---

## Incident System (Revised)

### What Causes Incidents

Incidents are **IT infrastructure failures**, not factory problems:

| Incident Type | Cause | Effect |
|---------------|-------|--------|
| Server Overload | Processing > capacity | Processing halts |
| Network Congestion | Bandwidth exceeded | Data delays |
| Storage Full | No space for data | Data loss |
| Security Breach | Cyber attack success | System compromise |
| Hardware Failure | Random (MTBF) | Entity stops working |
| Configuration Drift | Automation conflict | Wrong actions taken |

### Incident Severity

| Level | Name | IT Impact | Factory Impact |
|-------|------|-----------|----------------|
| SEV4 | Minor | One entity affected | No bonus loss |
| SEV3 | Moderate | Section affected | -25% bonus |
| SEV2 | Major | Major system down | -50% bonus |
| SEV1 | Critical | IT infrastructure down | All bonuses lost |

### Incident Resolution

**Without On-Call Station**: Player must manually click incident alerts and repair buildings

**With On-Call Station**: Engineer drones automatically respond:
- Drone travels to affected building
- Drone "repairs" (takes time based on severity)
- Building returns to normal
- Postmortem available

### Factory Continues Without IT

Critical point: **Vanilla factory operation continues during IT incidents**

- Assemblers keep crafting
- Belts keep moving
- Biters still attack walls
- Research still progresses

You just lose IT bonuses until resolved.

---

## Cyber Threat System

### Separate from Biters

Cyber threats are a **parallel enemy type** that:
- Only attack IT infrastructure
- Ignore walls, turrets, military
- Spawn based on Technical Debt (not pollution)
- Defeated by IT security, not weapons

### Threat Spawning

```
spawn_rate = base_rate × (1 + debt/100) × (1 - security_coverage)

Where:
- base_rate = 1 per 10 minutes (configurable)
- debt = current technical debt level
- security_coverage = percentage of IT protected by firewalls/IDS/IPS
```

### Threat Behavior

1. Threat spawns at map edge (or near high-debt IT)
2. Travels toward nearest unprotected IT building
3. If blocked by Firewall: attacks firewall
4. If unblocked: damages target IT building
5. Damaged IT = increased debt + potential incident

### Defense Strategy

| Defense | Blocks | Doesn't Block |
|---------|--------|---------------|
| Firewall | Script kiddies, basic malware | APT, zero-day |
| IDS | Nothing (detection only) | - |
| IPS | Most threats | Zero-day |
| SOC | Coordinates all, catches APT | - |
| Honeypot | Attracts threats away | - |

### No Military Crossover

- Turrets don't shoot cyber threats
- Cyber threats don't attack vanilla buildings
- Biters don't attack IT buildings
- Two separate defense systems for two threat types

---

## Uptime Tracking

### What Uptime Measures

IT infrastructure uptime, not factory uptime:

```
IT_uptime = (time_IT_functional) / (total_time) × 100%
```

### Uptime Tiers

| Uptime | Rating | Effect |
|--------|--------|--------|
| < 90% | Poor | -50% efficiency bonus |
| 90-95% | Basic | -25% efficiency bonus |
| 95-99% | Good | No modifier |
| 99-99.9% | Excellent | +10% efficiency bonus |
| 99.9-99.99% | Enterprise | +20% efficiency bonus |
| 99.99%+ | Five Nines | +35% efficiency bonus, Achievement |

### Uptime Display

Dashboard shows:
- Current uptime percentage
- Uptime history graph
- Downtime incidents
- Time until next tier up/down

---

## Automation Rules

### Rule Structure

```
WHEN [condition] THEN [action]

Conditions:
- Data value > threshold
- Data value < threshold
- Entity state = [state]
- Time = [schedule]
- Incident = [type]

Actions:
- Set circuit signal
- Enable/disable entity
- Set recipe
- Set priority
- Alert player
- Scale IT resources
```

### Example Rules

**Auto-disable low-resource assembler**:
```
WHEN ore_feed_rate < 10/min
THEN disable connected_assembler
```

**Alert on belt backup**:
```
WHEN belt_throughput < 50%
AND belt_item_count > 90%
THEN alert "Belt backup at [location]"
```

**Scale servers for load**:
```
WHEN processing_utilization > 85%
THEN enable standby_server_rack
```

### Circuit Network Integration

Circuit Bridge converts:
- IT data → Circuit signals
- Circuit signals → IT conditions

This allows IT automation to read from and write to vanilla circuit networks.

---

## Postmortem System

### Triggered By

- Any SEV2 or SEV1 incident
- Multiple SEV3 incidents within 1 hour
- Manual trigger by player

### Postmortem Flow

1. **Incident resolves** → Postmortem unlocked
2. **Click postmortem button** → Review screen opens
3. **Timeline** → Auto-generated from IT logs
4. **Root cause** → Player selects from options
5. **Action items** → Player commits to improvements
6. **Complete** → Rewards granted

### Root Cause Options

- Hardware failure (neutral)
- Software bug (IT debt -10)
- Configuration error (IT debt -5)
- Capacity shortage (prompts upgrade)
- Security gap (prompts security)
- External factor (no IT change)

### Rewards

| Postmortem Quality | Research Points | Debt Reduction |
|-------------------|-----------------|----------------|
| Skipped | 0 | 0 |
| Basic | 10 IT Science | -5 |
| Thorough | 25 IT Science | -15 |
| Excellent | 50 IT Science + 10 Automation | -30 |

---

## Integration Points Summary

### IT → Vanilla

| IT Output | Vanilla Effect |
|-----------|----------------|
| Efficiency bonus | Entity speed increase |
| Circuit signals | Circuit network control |
| Entity commands | On/off, recipe, priority |
| Alerts | Player notifications |

### Vanilla → IT

| Vanilla Output | IT Input |
|----------------|----------|
| Entity operations | Data generation |
| Circuit signals | Automation conditions |
| Power grid | IT power consumption |
| Factory scale | IT complexity requirement |

### Independence Preserved

- Factory works without IT (no bonus, no penalty until large scale)
- IT works without specific vanilla buildings
- Either can be prioritized based on playstyle
- Combining both provides synergistic benefits
