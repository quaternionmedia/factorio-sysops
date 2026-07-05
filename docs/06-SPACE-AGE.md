# Factorio: Sysadmin - Space Age Integration (Revised)

## Design Principle

Space Age planets gain **IT specialization options** without replacing their vanilla functionality. Each planet offers unique IT advantages that complement its vanilla resources.

---

## Overview

| Planet | Vanilla Focus | IT Specialization | Unique IT Building |
|--------|---------------|-------------------|-------------------|
| Nauvis | Home base | General IT, Control Plane | Orchestration Center |
| Vulcanus | Lava, foundries | GPU Computing, ML Training | Thermal Compute Array |
| Gleba | Biology, agriculture | Cold Storage, Archives | Biological Storage Matrix |
| Fulgora | Lightning, scrap | Edge Computing, Resilience | Storm-Hardened Data Node |
| Aquilo | Ice, ammonia | Quantum Computing | Quantum Processing Facility |

---

## Nauvis (Home World)

### Vanilla Role
Standard gameplay, main factory base.

### IT Role: Control Plane

Nauvis serves as the **central IT hub** coordinating all planetary operations.

### Unique IT Features

**Orchestration Center**
- Size: 8x8
- Power: 5MW
- Function: Central command for multi-surface IT
- Unlocks: Cross-planet automation, unified dashboards

**Capabilities**:
- View all surfaces from one dashboard
- Create cross-surface automation rules
- Coordinate data flow between planets
- Single pane of glass for all IT metrics

### IT Bonuses on Nauvis
- +10% server processing speed (established infrastructure)
- +20% automation rule capacity
- No penalties (baseline environment)

### Challenge: Scale
As factory grows, Nauvis IT must scale to handle data from all planets. The control plane can become a bottleneck.

---

## Vulcanus (Lava World)

### Vanilla Role
Foundries, metallurgy, calcite, tungsten.

### IT Role: GPU Computing & ML Training

The extreme heat actually benefits compute-intensive workloads when properly managed.

### Unique IT Features

**Thermal Compute Array**
- Size: 6x6
- Power: 10MW
- Requires: Lava proximity, tungsten construction
- Function: Massive parallel GPU processing

**Capabilities**:
- 10x ML training speed compared to standard
- Lava cooling (free thermal management)
- Produces Refined Insights (higher quality)

**Lava Coolant System**
- Size: 3x3
- Uses: Lava (consumes slowly)
- Provides: Free cooling for adjacent IT buildings
- Risk: Lava pipe rupture = IT destruction

### IT Bonuses on Vulcanus
- +500% ML training speed (with proper infrastructure)
- -50% cooling costs (lava differential)
- Unique: Refined Insights (2x potency)

### Challenge: Thermal Runaway

GPU arrays generate massive heat. Without Lava Coolant:
- Heat accumulates in "thermal zones"
- Overheating = cascade failure
- Entire compute array can melt down

**Prevention**: Lava cooling, thermal monitoring, emergency shutoffs

### Integration with Vanilla Vulcanus
- Foundries generate extra data (metallurgical data)
- Tungsten used for heat-resistant IT components
- Calcite used in advanced server construction

---

## Gleba (Biological World)

### Vanilla Role
Agriculture, biological science, spoilage management.

### IT Role: Cold Storage & Biological Archives

Gleba's biology provides unique organic storage medium.

### Unique IT Features

**Biological Storage Matrix**
- Size: 5x5
- Power: 500kW (low!)
- Requires: Agricultural products, controlled environment
- Function: Organic data storage with self-repair

**Capabilities**:
- 100x storage density (biological encoding)
- Self-repairing storage (no hardware failures)
- Very slow access (archival only)
- Zero degradation over time

**Bio-Neural Network**
- Size: 4x4
- Requires: Living specimens, nutrients
- Function: Organic processing alternative
- Unique: "Intuitive" pattern recognition

### IT Bonuses on Gleba
- +1000% storage capacity (biological medium)
- -80% storage power consumption
- Unique: Self-repairing storage (no hardware incidents)

### Challenge: Spoilage

Biological IT components can spoil:
- Storage matrices need nutrients
- Bio-neural networks need maintenance
- Neglected organic IT decays

**Prevention**: Automated nutrient supply, regular harvests

### Integration with Vanilla Gleba
- Agricultural byproducts used in organic IT
- Spoilage mechanics apply to bio-IT
- Biochambers can grow IT components

---

## Fulgora (Storm World)

### Vanilla Role
Lightning harvesting, scrap recycling.

### IT Role: Edge Computing & Resilience

The harsh environment forced development of ultra-resilient systems.

### Unique IT Features

**Storm-Hardened Data Node**
- Size: 3x3
- Power: Variable (lightning powered!)
- Function: Edge computing that survives anything

**Capabilities**:
- Operates during power outages (internal battery)
- Survives network partitions (offline mode)
- Self-healing after storm damage
- Lightning can power IT (free energy during storms)

**Lightning Capacitor Bank**
- Size: 4x4
- Function: Stores lightning for IT use
- Provides: Massive burst power for intensive operations
- Risk: Overcharge = explosion

### IT Bonuses on Fulgora
- +200% resilience (storm-hardened everything)
- Free power during storms
- Unique: Partition tolerance (operates offline)

### Challenge: Intermittent Connectivity

Storms disrupt data links:
- Communication blackouts last minutes
- Must operate autonomously
- Sync backlog after storms

**Edge Computing Benefits**:
- Local processing continues during blackouts
- Queued data syncs when connection restored
- No dependency on Nauvis control plane

### Integration with Vanilla Fulgora
- Recycled scrap provides IT components
- Lightning powers IT directly
- Storm mechanics affect IT connectivity

---

## Aquilo (Ice World)

### Vanilla Role
Ammonia, cryogenic processes, fusion.

### IT Role: Quantum Computing

Extreme cold enables stable quantum operations.

### Unique IT Features

**Quantum Processing Facility**
- Size: 10x10
- Power: 20MW
- Requires: Cryogenic environment, ammonia coolant
- Function: True quantum computation

**Capabilities**:
- Solve NP-hard optimization problems
- Perfect factory layout optimization
- Quantum-encrypted communication
- Instant data teleportation (entanglement)

**Entanglement Generator**
- Size: 4x4
- Produces: Entangled Qubit pairs
- One qubit stays, one ships elsewhere
- Enables: Zero-latency cross-planet sync

### IT Bonuses on Aquilo
- Unique: Quantum computing (only available here)
- +50% efficiency bonus when quantum-optimized
- Instant communication (no latency)

### Challenge: Decoherence

Quantum states are fragile:
- Computations must complete quickly
- Heat disrupts quantum coherence
- Ammonia cooling is critical

**Decoherence Effects**:
- T+0: Qubit initialized (100% coherence)
- T+30s: 50% coherence
- T+60s: Computation fails if incomplete

**Prevention**: Research improves coherence time, ammonia cooling essential

### Integration with Vanilla Aquilo
- Ammonia required for quantum cooling
- Cryogenic infrastructure supports quantum
- Fusion power can run quantum facilities

---

## Cross-Planet IT Network

### Data Transit Options

| Method | Speed | Latency | Availability |
|--------|-------|---------|--------------|
| Rocket Cargo | High capacity | Hours | Always |
| Radio Link | Medium | Minutes (light speed) | Usually |
| Quantum Link | Low | Zero | With Entangled Qubits |

### Latency Table

| Route | Radio Latency | Notes |
|-------|---------------|-------|
| Nauvis ↔ Vulcanus | 8 min | Standard |
| Nauvis ↔ Gleba | 10 min | Standard |
| Nauvis ↔ Fulgora | 6 min | Often disrupted |
| Nauvis ↔ Aquilo | 15 min | Stable |
| Any ↔ Any (Quantum) | 0 | Requires entangled qubits |

### Cross-Planet Automation

With Multi-Surface IT research:
- Create rules that span planets
- "WHEN Vulcanus ML complete THEN deploy to Nauvis"
- "WHEN Fulgora offline THEN route traffic through Gleba"
- "WHEN Aquilo quantum ready THEN optimize all factories"

---

## Space Platform IT

### Platform Data Centers

Space platforms can host IT infrastructure:

**Advantages**:
- Zero gravity cooling (no thermal issues)
- No cyber threats from planet surfaces
- Direct line-of-sight communication

**Disadvantages**:
- Limited space
- Expensive construction
- Vulnerable to asteroid damage

### Orbital Relay

**Orbital Data Relay**
- Built on space platform
- Reduces latency between planets
- Provides backup communication route
- Enables quantum entanglement distribution

---

## Victory Integration

### IT Excellence (IT Victory)

Achieve on ANY playthrough:
1. Deploy IT infrastructure on all planets
2. Achieve 99.999% IT uptime for 10 hours
3. Process 1 million data packets
4. Survive 100 cyber attacks with zero breaches

Reward: Achievement + permanent +10% efficiency

### Quantum Mastery (Hard Victory)

Requires Space Age:
1. Build Quantum Processing Facility on Aquilo
2. Establish Entanglement Links to all planets
3. Solve the "Grand Optimization" (quantum-only problem)
4. Achieve quantum-coherent factory automation

Reward: Achievement + permanent +25% efficiency + unique cosmetics

### Integration Master

Combine with vanilla victory:
1. Launch rocket from Nauvis
2. Complete all vanilla Space Age objectives
3. Achieve IT Excellence
4. Have IT infrastructure on all planets at victory moment

Reward: Special achievement recognizing mastery of both systems

---

## Compatibility Notes

### Works With Vanilla Space Age
- All vanilla planet mechanics unchanged
- IT is additional layer, not replacement
- Rockets still work normally
- All vanilla resources still needed

### Surface Agnostic
- IT can be built on any surface
- Each surface has bonuses but none required
- Play the planets you enjoy
- IT scales to your ambition

### No Planet Requirements
- Can complete IT Excellence on Nauvis alone
- Planetary IT is optional optimization
- Base game + IT works without Space Age
- Space Age + IT provides maximum synergy
