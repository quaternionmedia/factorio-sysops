# Factorio: Sysadmin - Mod Overview (Revised)

## Design Philosophy Change

**Previous Approach**: Total conversion replacing all vanilla content  
**New Approach**: Parallel addon that runs alongside vanilla, integrating IT infrastructure with traditional factory automation

### Why Parallel is Better
- Players keep familiar Factorio gameplay
- IT systems augment and enhance factory operations
- Lower barrier to entry
- Can be combined with other mods
- More realistic: factories need IT infrastructure too!

---

## Integration Concept

Your factory now needs IT infrastructure to operate efficiently. As your factory scales, manual oversight becomes impossible - you need monitoring, automation, and orchestration systems.

### The Hook
- Small factories work fine without IT
- Medium factories benefit from monitoring and basic automation
- Large factories **require** IT infrastructure or suffer penalties
- Megabases need full enterprise-grade systems

### Vanilla Integration Points

| Factory Scale | IT Requirement | Benefit |
|---------------|----------------|---------|
| < 100 machines | None | - |
| 100-500 machines | Basic monitoring | +5% efficiency visibility |
| 500-2000 machines | Automation systems | +10% throughput, alerts |
| 2000-10000 machines | Full observability | +15% efficiency, predictive maintenance |
| 10000+ machines | Enterprise orchestration | +25% efficiency, self-healing |

---

## Core Concept (Revised)

### IT Infrastructure Supports Factory Operations

Instead of replacing belts with cables, your IT systems:
- **Monitor** factory performance and health
- **Optimize** production through data analysis
- **Automate** complex decisions and responses
- **Protect** against new IT-based threats
- **Coordinate** multi-surface operations

### New Resource: Data

Factories now generate **Data** as a byproduct of operations:
- Assemblers generate production data
- Inserters generate throughput data
- Belts generate logistics data
- Power systems generate consumption data

Data must be:
1. **Collected** (sensors, log collectors)
2. **Transported** (network cables)
3. **Processed** (servers, databases)
4. **Acted Upon** (automation, alerts)

Uncollected data decays. Unprocessed data accumulates as **Technical Debt**.

---

## New Systems (Parallel to Vanilla)

### Network Layer
- Runs alongside belt networks
- Carries data packets, not items
- Different infrastructure, complementary purpose

### Compute Layer
- Servers process data into insights
- Insights enable automation and optimization
- More compute = more sophisticated automation

### Automation Layer
- IT automation triggers factory actions
- Circuit network integration
- Can control vanilla entities based on data

### Security Layer
- New enemy type: Cyber Threats
- Attack your IT infrastructure, not walls
- Successful attacks degrade factory efficiency

---

## Progression (Parallel Track)

### Era 1: Basic Monitoring
**Unlocks alongside**: Green science
- Deploy sensors on factory machines
- Basic data collection
- Simple dashboards
- See what's happening

### Era 2: Automation
**Unlocks alongside**: Red + Green science
- Process data into decisions
- Automated alerts
- Basic auto-responses
- React to problems faster

### Era 3: Optimization
**Unlocks alongside**: Blue science
- ML-based optimization
- Predictive maintenance
- Throughput optimization
- Prevent problems before they happen

### Era 4: Orchestration
**Unlocks alongside**: Purple + Yellow science
- Full factory orchestration
- Self-healing systems
- Multi-surface coordination
- Factory runs itself

### Era 5: Hyperscale (Space Age)
**Unlocks alongside**: Space science
- Planetary data centers
- Quantum coordination
- Ultimate efficiency
- Interplanetary factory management

---

## Victory Conditions (Addon Goals)

### Standard Victory (Unchanged)
Launch rocket as normal - IT systems help but aren't required

### IT Excellence Achievement
Achieve "Five Nines" operational efficiency:
- 99.999% factory uptime
- Zero unhandled incidents for 10 hours
- Full observability coverage
- All automation tiers unlocked

### Cyber Resilience Achievement
- Survive 100 cyber attacks
- Achieve zero-breach status for 5 hours
- Full security coverage deployed

### Integration Master Achievement
- Every vanilla entity monitored
- Full data pipeline operational
- 25%+ efficiency bonus active

---

## Compatibility

### Works With
- Vanilla Factorio 2.0
- Space Age DLC
- Most QoL mods
- Most overhaul mods (Bob's, Angel's, K2, SE)

### Integration Points
- Circuit network (read IT data)
- Logistic network (IT-controlled requests)
- Blueprint system (IT configs included)
- Map view (IT overlay layer)

### Does NOT Replace
- Belts, inserters, assemblers
- Power systems
- Combat/military
- Vanilla research
- Any vanilla items or recipes

---

## Key Differences from Total Conversion

| Aspect | Total Conversion | Parallel Addon |
|--------|------------------|----------------|
| Vanilla content | Hidden/replaced | Fully available |
| Learning curve | Start over | Gradual addition |
| Mod compatibility | Low | High |
| Required to progress | Yes | No (but beneficial) |
| Complexity | Overwhelming | Opt-in layers |
| Save compatibility | New game only | Add to existing |
