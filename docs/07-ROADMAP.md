# Factorio: Sysadmin - Implementation Roadmap (Revised)

## Scope Change Summary

| Aspect | Total Conversion | Addon (New) |
|--------|------------------|-------------|
| Vanilla content | Replaced | Unchanged |
| Development time | 28 months | 18 months |
| Complexity | High | Medium |
| Compatibility | Low | High |
| User adoption | Hard | Easy |

---

## Development Phases

| Phase | Duration | Focus | Milestone |
|-------|----------|-------|-----------|
| 0 | 2 weeks | Setup | Mod skeleton, no vanilla changes |
| 1 | 2 months | Core Data System | Data collection working |
| 2 | 2 months | Processing & Monitoring | Servers, dashboards |
| 3 | 2 months | Automation | Rules, circuit integration |
| 4 | 2 months | Incidents & Debt | Challenge mechanics |
| 5 | 2 months | Security | Cyber threats |
| 6 | 3 months | Space Age | Planetary IT |
| 7 | 2 months | Balance & Polish | Release ready |

**Total: ~17-18 months**

---

## Phase 0: Foundation (Weeks 1-2)

### Goals
- Establish mod structure
- Verify NO vanilla modifications
- Set up development workflow

### Deliverables

**Mod Structure**
```
sysadmin/
├── info.json
├── data.lua
├── control.lua
├── settings.lua
├── prototypes/
│   ├── item.lua
│   ├── entity.lua
│   ├── recipe.lua
│   └── technology.lua
├── scripts/
│   ├── data-system.lua
│   ├── monitoring.lua
│   └── events.lua
├── gui/
│   └── dashboard.lua
├── graphics/
│   └── [placeholder sprites]
└── locale/
    └── en/strings.cfg
```

**info.json**
```json
{
  "name": "sysadmin",
  "version": "0.1.0",
  "title": "Sysadmin: IT Infrastructure",
  "author": "YourName",
  "description": "Add IT infrastructure to enhance your factory",
  "factorio_version": "2.0",
  "dependencies": [
    "base >= 2.0",
    "? space-age >= 2.0"
  ]
}
```

Note: `?` prefix means optional dependency - works with or without Space Age.

### Tasks
- [ ] Create mod skeleton
- [ ] Verify loads without errors
- [ ] Verify NO vanilla items hidden/changed
- [ ] Set up test save
- [ ] Create placeholder graphics
- [ ] Write basic locale strings

### Acceptance Criteria
- Mod loads alongside vanilla
- All vanilla gameplay unchanged
- No errors in log
- Ready for feature development

---

## Phase 1: Core Data System (Months 1-2)

### Goals
- Implement data generation from vanilla entities
- Create data collection (sensors)
- Build data transport (cables)

### Week 1-2: Data Item & Generation

**Data Packet Item**
```lua
{
  type = "item",
  name = "data-packet",
  icon = "__sysadmin__/graphics/icons/data-packet.png",
  icon_size = 64,
  subgroup = "sysadmin-data",
  stack_size = 1000
}
```

**Generation Logic** (control.lua)
```lua
-- Hook into vanilla entity events
script.on_event(defines.events.on_entity_crafted, function(event)
  -- Generate data based on entity type
  generate_data(event.entity, 1)
end)
```

### Week 3-4: Data Sensor

**Entity Definition**
- 1x1 attachable entity
- Connects to adjacent vanilla entity
- Collects generated data
- Outputs to network cable

**Attachment Mechanic**
- Player places sensor next to assembler
- Sensor auto-links to assembler
- Sensor outputs data packets

### Week 5-6: Network Cables

**Belt-like Behavior**
- New transport-belt type entity
- Different layer (doesn't collide with belts)
- Carries data packets
- Underground variant for obstacles

### Week 7-8: Integration Testing

- Connect sensor → cable → destination
- Verify data flows correctly
- Test with various vanilla entities
- Performance testing (many sensors)

### Milestone Criteria
- [ ] Data generates from vanilla operations
- [ ] Sensors collect data
- [ ] Cables transport data
- [ ] No impact on vanilla performance
- [ ] Works in multiplayer

---

## Phase 2: Processing & Monitoring (Months 3-4)

### Goals
- Create server entities
- Build dashboard GUI
- Implement efficiency bonuses

### Week 1-2: Basic Server

**Entity**
- Assembling-machine type
- Processes data packets → processed data
- Power consumption: 200kW
- 2x2 size

**Recipe**
- Electronic Circuit (20)
- Advanced Circuit (5)
- Iron Plate (10)
- Copper Plate (5)

### Week 3-4: Dashboard Terminal

**GUI Features**
- Opens on entity click
- Shows collected metrics
- Real-time graphs
- Entity list with status

**Data Displayed**
- Total data collected/processed
- Processing utilization
- Connected entities
- Efficiency bonus status

### Week 5-6: Efficiency Bonus System

**Implementation**
```lua
-- Apply bonus to monitored entities
script.on_nth_tick(60, function()
  for _, monitored in pairs(global.monitored_entities) do
    if monitored.entity.valid then
      local bonus = calculate_bonus(monitored)
      apply_speed_bonus(monitored.entity, bonus)
    end
  end
end)
```

**Bonus Application**
- Use entity.speed_bonus or crafting_speed modifier
- Scale based on IT coverage
- Update every second

### Week 7-8: Log Collector & Alert System

**Log Collector**
- Larger coverage area (50 tiles)
- Aggregates from multiple sensors
- Higher throughput

**Alert Beacon**
- Visual notification
- Configurable conditions
- Links to dashboard

### Milestone Criteria
- [ ] Servers process data
- [ ] Dashboard shows metrics
- [ ] Efficiency bonus applied
- [ ] Alerts trigger correctly
- [ ] Player understands system

---

## Phase 3: Automation (Months 5-6)

### Goals
- Create automation controller
- Build circuit bridge
- Implement rule system

### Week 1-2: Automation Controller

**Entity**
- Receives processed data
- Evaluates rules
- Outputs commands

**Rule Storage**
- Global table per controller
- Serializable for saves
- Max 20 rules per controller (upgradeable)

### Week 3-4: Rule GUI

**Rule Editor**
- WHEN dropdown (conditions)
- THEN dropdown (actions)
- Threshold inputs
- Entity selectors

**Condition Types**
- Data value comparison
- Entity state check
- Time/schedule
- Circuit signal value

**Action Types**
- Set circuit signal
- Enable/disable entity
- Change recipe
- Trigger alert

### Week 5-6: Circuit Bridge

**Entity**
- 1x1 size
- Red/green wire connectable
- Converts IT data ↔ circuit signals

**Bidirectional**
- IT condition: "circuit signal X > 100"
- IT action: "set circuit signal Y = 50"

### Week 7-8: Entity Controller

**Attachment Entity**
- Attaches to vanilla entities
- Receives commands from automation
- Controls: on/off, recipe, priority

**Integration**
- Controller → Entity Controller
- Entity Controller → Vanilla Entity
- Full automation chain working

### Milestone Criteria
- [ ] Rules execute correctly
- [ ] Circuit integration works
- [ ] Entity control functional
- [ ] Complex automations possible
- [ ] Performance acceptable

---

## Phase 4: Incidents & Technical Debt (Months 7-8)

### Goals
- Implement technical debt
- Create incident system
- Build postmortem GUI

### Week 1-2: Technical Debt

**Tracking**
```lua
global.technical_debt = {
  total = 0,
  by_building = {},
  sources = {}
}
```

**Generation**
- Unprocessed data backlog
- Overloaded servers
- Missing redundancy

**Effects**
- IT processing slowdown
- Increased incident rate
- Reduced efficiency bonus

### Week 3-4: Incident System

**Incident Types**
- Server overload
- Network congestion
- Storage full
- Hardware failure

**Incident Flow**
1. Condition met → incident created
2. Alert triggered
3. Building affected
4. Resolution required
5. Postmortem available

### Week 5-6: On-Call Station & Engineers

**On-Call Station Entity**
- Spawns engineer drones
- Drones travel to incidents
- Drones resolve incidents (takes time)

**Engineer Behavior**
- Pathfind to target
- "Repair" animation
- Return to station
- Fatigue system (optional complexity)

### Week 7-8: Postmortem System

**GUI**
- Timeline of incident
- Root cause selection
- Action items
- Rewards display

**Rewards**
- IT Science points
- Debt reduction
- Process improvements

### Milestone Criteria
- [ ] Debt accumulates visibly
- [ ] Incidents occur based on conditions
- [ ] Engineers respond automatically
- [ ] Postmortems provide rewards
- [ ] System feels fair

---

## Phase 5: Security System (Months 9-10)

### Goals
- Create cyber threat entities
- Build defense buildings
- Balance security gameplay

### Week 1-2: Threat Entities

**Enemy Unit Type**
- New unit category (not biter)
- Different AI behavior
- Targets IT buildings only

**Threat Types**
- Script Kiddie (small, fast)
- Malware Bot (medium)
- APT Agent (stealthy)
- Zero-Day (bypasses basic defense)

### Week 3-4: Defense Buildings

**Firewall**
- Area protection
- Blocks basic threats
- Passive defense

**IDS/IPS**
- Detection + prevention
- More threat coverage
- Active response

### Week 5-6: Threat Spawning

**Spawner Logic**
```lua
-- Spawn based on technical debt
local spawn_chance = base_rate * (1 + debt / 100) * (1 - security_coverage)
if math.random() < spawn_chance then
  spawn_threat(surface, position)
end
```

**Spawn Locations**
- Map edges
- Near high-debt areas
- Never inside defended zones

### Week 7-8: Balance & Integration

**Difficulty Curve**
- Early game: rare, weak threats
- Mid game: regular threats
- Late game: frequent, varied threats

**Defense Scaling**
- Basic firewall sufficient early
- Need IDS/IPS for mid
- Need SOC for late game

### Milestone Criteria
- [ ] Threats spawn appropriately
- [ ] Defenses counter threats
- [ ] Not overwhelming
- [ ] Engaging gameplay
- [ ] Separate from biter combat

---

## Phase 6: Space Age Integration (Months 11-13)

### Goals
- Create planetary IT buildings
- Implement cross-surface features
- Build quantum mechanics

### Month 11: Surface Awareness

**Multi-Surface Support**
- Track IT per surface
- Cross-surface data links
- Surface-specific bonuses

**Orbital Data Relay**
- Space platform building
- Enables cross-surface communication
- Reduces latency

### Month 12: Planetary Specializations

**Vulcanus: Thermal Compute**
- Lava cooling buildings
- GPU arrays
- ML training bonus

**Gleba: Bio Storage**
- Organic storage matrix
- Self-repairing
- Spoilage mechanics

**Fulgora: Edge Computing**
- Storm-hardened nodes
- Partition tolerance
- Lightning power

### Month 13: Aquilo Quantum

**Quantum Facilities**
- Quantum processor
- Entanglement generator
- Quantum links

**Decoherence Mechanic**
- Time-limited computations
- Ammonia cooling required
- High reward for success

### Milestone Criteria
- [ ] Works without Space Age
- [ ] Enhanced with Space Age
- [ ] Each planet has unique IT
- [ ] Quantum provides endgame
- [ ] Cross-surface automation works

---

## Phase 7: Balance & Polish (Months 14-15)

### Goals
- Complete balance pass
- Final art assets
- Documentation

### Month 14: Balance

**Playtesting Focus**
- Early game pacing
- Mid game progression
- Late game challenge
- Space Age integration

**Economy Tuning**
- Recipe costs
- Power consumption
- Efficiency bonus values
- Threat difficulty

### Month 15: Polish

**Art**
- Final entity sprites
- UI graphics
- Icons
- Effects

**Sound**
- IT ambient sounds
- Alert sounds
- Action feedback

**Documentation**
- In-game tips
- Tutorial scenarios
- Achievement descriptions

### Release Preparation
- Mod portal listing
- Screenshots
- Description
- Changelog

### Release Criteria
- [ ] Stable gameplay
- [ ] Balanced progression
- [ ] No known crashes
- [ ] Compatible with vanilla + Space Age
- [ ] Clear onboarding

---

## Resource Requirements (Revised)

| Role | Effort | Phases |
|------|--------|--------|
| Lead Developer | Full-time | All |
| Artist | Part-time | 4-7 |
| Sound Designer | Few weeks | 7 |
| Playtesters | Ongoing | 3-7 |

### Reduced from Original
- No systems designer (simpler scope)
- Less artist time (fewer unique assets)
- Shorter timeline (addon vs. conversion)

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Vanilla update breaks mod | Track Factorio updates, test on experimental |
| Performance issues | Profile early, optimize data generation |
| Complexity overwhelming | Tutorial system, gradual unlocks |
| Balance issues | Extensive playtesting, settings for tuning |
| Space Age compatibility | Test both with and without, use optional dependency |

---

## Success Metrics

### Development
- Phase milestones met
- Bug count manageable
- Playtest feedback positive

### Launch
- Downloads in first week
- Rating average
- Bug reports severity

### Post-Launch
- Active players after 1 month
- Community contributions
- Feature requests quality
