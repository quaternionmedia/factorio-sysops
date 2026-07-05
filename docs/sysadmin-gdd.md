# FACTORIO: SYSADMIN

*IT Automation Overhaul Mod*

**Game Design Document** | Version 1.0 | January 2026

*A Total Conversion Mod for Factorio: Space Age*

## Table of Contents

# 1. Executive Summary
## 1.1 Vision Statement
Factorio: Sysadmin transforms the factory automation experience into an IT infrastructure journey. Players progress from a single server rack to interplanetary data centers, experiencing the evolution of computing from manual operations to fully automated, self-healing infrastructure.
The mod preserves Factorio's core gameplay loop of scaling, optimization, and automation while recontextualizing every system through an IT lens. Biters become security threats, pollution becomes technical debt, and science packs become documentation and tribal knowledge.
## 1.2 Core Pillars
- Authenticity: Systems reflect real IT concepts (CI/CD, Kubernetes, observability) accurately enough that industry professionals recognize them
- Progression: Clear advancement from manual operations to full automation mirrors actual industry evolution
- Challenge: Incident management, security threats, and technical debt create engaging tension
- Education: Players learn real infrastructure concepts through gameplay
## 1.3 Target Audience
- Existing Factorio players seeking fresh total conversion experiences
- IT professionals who want to see their work gamified
- Players interested in learning about infrastructure and DevOps
- Fans of management simulation and systems optimization games

# 2. Progression Overview
## 2.1 Era Structure
The mod divides progression into five distinct eras, each representing a phase in IT infrastructure evolution:

| Era | Factorio Equivalent | Theme | End Goal |
| --- | --- | --- | --- |
| 1. Garage | Stone/Wood Age | Single server, manual ops | Serve first webpage |
| 2. Startup | Burner/Steam | Basic automation, scripts | 10 concurrent users, 95% uptime |
| 3. Scale-Up | Electric/Oil | Virtualization, containers | 10K users, 99% uptime |
| 4. Enterprise | Blue/Production science | Orchestration, compliance | Global deployment, SOC2 |
| 5. Hyperscale | Space Age planets | Specialized data centers | Five nines, quantum net |

## 2.2 Pacing Philosophy
Each era should feel meaningfully different from the last, with new mechanics and challenges unlocking at a pace that allows players to master current systems before advancing. The early game (Eras 1-2) moves relatively quickly to hook players, while later eras expand in complexity and duration.

# 3. Era Details
## 3.1 Era 1: The Garage
### 3.1.1 Starting Scenario
The player crash-lands on an alien world with salvaged electronics. The goal is to bootstrap basic infrastructure from nothing, mirroring the experience of building a startup in a garage with limited resources.
### 3.1.2 Resources

| Resource | Source | Used For |
| --- | --- | --- |
| Scrap Electronics | Surface debris, crashed ships | Basic components, wiring |
| Copper Wire | Mined copper, recycled cables | Network cabling, circuits |
| Silicon Sand | Desert biomes, beaches | Basic chips, solar panels |
| Cooling Fans | Salvage, basic crafting | Thermal management |

### 3.1.3 Buildings
- Workbench Terminal: Manual CLI interface. Player executes one command at a time, similar to hand-crafting. Commands include: ping, traceroute, cat, grep.
- Basic PSU: Unreliable power. Brownouts randomly pause operations. Requires manual restart.
- Single-Board Computer: First 'inserter' equivalent. Moves data packets between storage and processing at a slow, fixed rate.
- Primitive Storage: Old hard drives with limited capacity. Data corruption possible without redundancy.
### 3.1.4 Era 1 Milestones
- Boot first system successfully
- Establish stable power for 5 minutes
- Transfer first data packet
- Serve static HTML page (era completion)

## 3.2 Era 2: The Startup
### 3.2.1 Theme
The scrappy startup phase: basic automation, shell scripts, and the constant struggle between shipping features and maintaining stability. Technical debt begins accumulating.
### 3.2.2 New Resources
- Silicon Wafers: Processed from silicon sand. Required for modern chips.
- Rare Earth Elements: Mined from special deposits. Used for high-performance components.
- Fiber Optic Material: Glass + rare earths. Enables high-bandwidth connections.
### 3.2.3 Infrastructure Unlocks
- Rack-Mounted Servers: Modular, stackable compute units. Each server handles a defined workload capacity.
- Network Switches: Replace point-to-point connections. Enable packet routing to multiple destinations.
- UPS Units: Buffer power, prevent data loss during brownouts. Limited capacity, must be scaled with load.
- RAID Arrays: Redundant storage. RAID-1 (mirror) and RAID-5 (parity) configurations available.
### 3.2.4 Automation Unlocks
- Bash Scripts: Automate repetitive tasks. Player writes or selects from templates. Scripts consume CPU cycles.
- Cron Jobs: Scheduled automation. Set intervals for script execution. Foundation of automated operations.
- Rsync Belts: Continuous data replication between systems. The first 'belt' equivalent for data movement.
### 3.2.5 New Mechanics
Uptime SLA: Must maintain 95% uptime to retain customers. Customers provide 'revenue' resource used for expansion. Downtime loses customers; extended downtime triggers game over.
Log Accumulation: Operations generate log files. Unmanaged logs consume storage and slow systems. Must implement log rotation or archival.
### 3.2.6 Era 2 Milestones
- Deploy first redundant system
- Automate at least 3 operations with scripts
- Survive first unplanned outage
- Achieve 10 concurrent users with 95% uptime (era completion)

## 3.3 Era 3: The Scale-Up
### 3.3.1 Theme
Massive efficiency gains through virtualization and containers. The infrastructure becomes truly scalable, but complexity increases dramatically. This era introduces the full technical debt and incident management systems.
### 3.3.2 Major Technology Unlocks
- Virtualization: Run multiple virtual machines on single physical servers. 3-5x efficiency improvement. Requires hypervisor research.
- Load Balancers: Distribute traffic across server pools. Enable horizontal scaling. Multiple algorithms: round-robin, least-connections, weighted.
- Configuration Management: Template-based deployment (Ansible/Puppet equivalent). Define desired state, system converges automatically.
- Container Runtime: Lightweight isolation. Faster deployment than VMs. Foundation for microservices architecture.
### 3.3.3 New Processing Chains
Data processing becomes multi-stage, similar to Factorio's oil refinery chains:
- Observability Pipeline: Raw Logs -> Parsed Logs -> Metrics -> Dashboards -> Alerts
- Deployment Pipeline: Code Commits -> Build Artifacts -> Test Results -> Staged Deployments -> Production
- Learning Pipeline: Incidents -> Root Cause Analysis -> Postmortems -> Process Improvements (research points)
### 3.3.4 Buildings
- CI/CD Pipeline: Assembling machine equivalent. Input: code commits + configuration. Output: running services. Multiple quality levels affect deployment speed and reliability.
- Monitoring Stack: Radar equivalent. Reveals system health, performance bottlenecks, and incoming security threats. Larger stacks see further and more detail.
- On-Call Rotation Beacon: Summons engineer drones (combat robots equivalent) to handle incidents automatically. Engineers have specializations and fatigue.
### 3.3.5 Technical Debt System (Full Implementation)
Technical debt becomes the primary 'pollution' equivalent:
- Sources: Quick fixes, unpatched systems, undocumented changes, copy-paste code, skipped tests
- Effects: Attracts security incidents, slows deployments, increases failure probability, reduces engineer effectiveness
- Visualization: Debt appears as 'code smell' clouds over affected systems. Dense clouds trigger incidents.
- Mitigation: Refactoring (time + research investment), documentation sprints, testing initiatives, code review enforcement
### 3.3.6 Era 3 Milestones
- Deploy first virtualized workload
- Implement automated deployment pipeline
- Reduce technical debt below 50% threshold
- Achieve 10,000 concurrent users with 99% uptime (era completion)

## 3.4 Era 4: The Enterprise
### 3.4.1 Theme
Enterprise-grade infrastructure: orchestration, compliance requirements, and global expansion. Players must balance technical excellence with business and regulatory constraints.
### 3.4.2 Technology Unlocks
- Kubernetes Orchestration: Automatic scaling, self-healing deployments, rolling updates. Transforms infrastructure management but requires significant learning investment.
- Service Mesh: Intelligent traffic routing, mTLS encryption, distributed tracing. Adds observability layer between services.
- Infrastructure as Code: Blueprint-like infrastructure definitions. Version-controlled, reproducible deployments across regions.
- GitOps Workflows: Git repository becomes source of truth. All changes through pull requests. Automatic reconciliation.
### 3.4.3 New Challenge Systems
Compliance Auditors: Periodic events requiring documentation review. Missing documentation or security gaps result in penalties (revenue reduction, expansion restrictions).
Security Penetration Tests: Scheduled attacks that test defenses. Successful defense grants security research points. Failures require incident response.
Vendor Management: NPC traders offer cloud credits, enterprise licenses, support contracts. Negotiation minigame affects costs.
### 3.4.4 Multi-Region Deployment
Players can establish presence on other continents, each with different:
- Latency characteristics (affects user experience metrics)
- Power costs and availability
- Regulatory requirements (GDPR, data residency)
- Natural disaster risks
### 3.4.5 Buildings
- Data Warehouse: Massive storage for analytics workloads. Enables business intelligence features that improve 'revenue' generation.
- ML Training Cluster: Expensive, power-hungry facility. Produces 'insights' used for automation improvements and threat prediction.
- Disaster Recovery Site: Mirror infrastructure in separate location. Required for compliance. Enables failover during regional outages.
### 3.4.6 Era 4 Milestones
- Pass first compliance audit
- Deploy to second region
- Implement GitOps for all deployments
- Achieve global deployment with 99.9% uptime and SOC2 compliance (era completion)

## 3.5 Era 5: Hyperscale (Space Age Integration)
### 3.5.1 Planetary Overview
Each Space Age planet becomes a specialized data center region with unique resources and challenges:

| Planet | SA Equivalent | Specialization | Unique Challenge |
| --- | --- | --- | --- |
| Computron | Vulcanus | GPU clusters, ML training | Thermal runaway events |
| Storagia | Nauvis | General purpose, balanced | Data gravity (migration cost) |
| Coldcache | Gleba | Archival, cold storage | Slow retrieval, data decay if warmed |
| Edgeworld | Fulgora | Edge computing, CDN | Intermittent connectivity |
| Quantumis | Aquilo | Quantum computing | Decoherence (state decay) |

### 3.5.2 Planet: Computron
An extreme heat world where dense compute generates massive thermal output. Specializes in GPU clusters and ML training.
- Unique Resource: Tensor Cores - crystalline structures that accelerate matrix operations
- Special Building: Liquid Cooling Megaplex - industrial-scale cooling using volcanic vents
- Challenge: Thermal runaway cascades can destroy entire racks. Requires careful thermal management.
- Export: Trained models, inference results
### 3.5.3 Planet: Storagia
A balanced world suitable for general-purpose data centers. The player's home base equivalent.
- Unique Resource: Persistent Storage Crystals - naturally occurring solid-state storage medium
- Special Building: Data Lake - massive storage facility with tiered access speeds
- Challenge: Data gravity - once data is stored, moving it becomes increasingly expensive
- Export: Processed data, backup services
### 3.5.4 Planet: Coldcache
A frozen world where ambient temperatures provide free cooling. Ideal for archival storage.
- Unique Resource: Cryogenic Storage Medium - data preserved indefinitely when frozen
- Special Building: Permafrost Archive - zero-energy-cost long-term storage
- Challenge: Retrieval latency measured in hours. Data degrades if storage warms above threshold.
- Export: Archive services, disaster recovery backups
### 3.5.5 Planet: Edgeworld
A storm-prone world with unreliable conditions. Enables low-latency edge computing but requires resilience.
- Unique Resource: Low-Latency Crystals - enable near-instantaneous local processing
- Special Building: Storm-Hardened Edge Node - self-healing distributed compute
- Challenge: Network partitions and power outages. Must handle offline operation gracefully.
- Export: CDN caching, real-time processing
### 3.5.6 Planet: Quantumis
An extreme environment enabling quantum computing research. The ultimate technology frontier.
- Unique Resource: Entangled Qubits - enable quantum operations and instant data teleportation
- Special Building: Quantum Computing Facility - solves previously impossible problems
- Challenge: Decoherence - quantum states decay rapidly. Must use results immediately.
- Export: Cryptographic solutions, optimization results, instant communication

# 4. Core Mechanics
## 4.1 Resource Mapping
### 4.1.1 Belt Equivalents: Network Fabric

| Network Type | Factorio Belt | Throughput | Max Distance |
| --- | --- | --- | --- |
| Cat5 Cable | Yellow Belt | 100 Mbps | 100m |
| Cat6 Cable | Red Belt | 1 Gbps | 55m shielded |
| Fiber Optic | Blue Belt | 10+ Gbps | Unlimited |

Unlike belts, networks can experience packet loss when overloaded. Buffering (using network switches with queue capacity) mitigates this but introduces latency.
### 4.1.2 Inserter Equivalents: Data Handlers

| Handler Type | Factorio Inserter | Behavior |
| --- | --- | --- |
| Manual Operator | Burner Inserter | Player clicks to transfer. Slow, unreliable. |
| Cron Daemon | Inserter | Scheduled transfers at fixed intervals. |
| Event Trigger | Fast Inserter | Reacts to conditions. Transfers on demand. |
| Stream Processor | Stack Inserter | Continuous high-throughput data flow. |

### 4.1.3 Assembler Equivalents: Services

| Service Type | Characteristics | Trade-offs |
| --- | --- | --- |
| Monolith Server | Single purpose, simple | Easy to understand but doesn't scale horizontally |
| Microservice Pod | Small, composable | Scales well but complex to orchestrate |
| Serverless Function | On-demand execution | Cost-efficient but cold start latency |
| Legacy Mainframe | Massive throughput | Expensive, slow to build, but handles huge loads |

## 4.2 Power System: Compute Budget
Power in Sysadmin represents compute budget - the total processing capacity available.

| Power Source | Factorio Equivalent | Characteristics |
| --- | --- | --- |
| Physical Servers | Steam/Coal Power | Baseline capacity. Reliable but expensive per unit. |
| Spot Instances | Solar Power | Cheap but unreliable. Can be reclaimed anytime. |
| Reserved Capacity | Nuclear Power | Expensive upfront, efficient long-term. |
| Autoscaling Buffer | Accumulators | Absorbs demand spikes. Limited capacity. |

## 4.3 Research System: Documentation
Science packs become forms of knowledge that unlock new capabilities:

| Pack | Name | Source | Used For |
| --- | --- | --- | --- |
| Red | Stack Overflow | External searches | Basic troubleshooting |
| Green | Internal Runbooks | Incident resolution | Operations automation |
| Blue | Vendor Docs | Vendor relationships | Enterprise features |
| Purple | Conference Talks | Networking events | Advanced architectures |
| Yellow | Original Research | R&D facilities | Cutting-edge tech |
| White | Tribal Knowledge | Senior engineers | Institutional wisdom |

## 4.4 Combat System: Security Threats
### 4.4.1 Threat Types

| Threat | Factorio Equivalent | Behavior | Counter |
| --- | --- | --- | --- |
| Script Kiddies | Small Biters | Frequent, weak attacks | Basic firewall |
| Botnets | Medium Biters | DDoS swarm attacks | Rate limiting, WAF |
| APT Groups | Big Biters | Slow, persistent, stealthy | IDS, threat hunting |
| Zero-Day Exploits | Behemoths | Bypass defenses entirely | Patch quickly, defense in depth |
| Insider Threats | Spawners inside base | Spawn within perimeter | Zero trust, audit logs |

### 4.4.2 Defense Layers
- Firewall Rules: Basic perimeter defense. Blocks known-bad traffic patterns.
- Web Application Firewall (WAF): Application-layer filtering. Detects and blocks malicious payloads.
- IDS/IPS: Intrusion Detection/Prevention. Identifies attack patterns and can auto-respond.
- Zero-Trust Mesh: No implicit trust. Every request authenticated and authorized. Ultimate defense.
## 4.5 Pollution Equivalent: Technical Debt
### 4.5.1 Debt Sources
- Quick fixes and hotfixes deployed without proper testing
- Unpatched systems running outdated software
- Undocumented changes and tribal knowledge
- Copy-paste code and duplicate configurations
- Skipped code reviews and testing shortcuts
### 4.5.2 Debt Effects
- Attracts security incidents (threat spawning increases near high-debt areas)
- Slows deployment pipelines (increased build/test times)
- Increases failure probability (random outages in high-debt systems)
- Reduces engineer effectiveness (longer incident resolution times)
### 4.5.3 Debt Visualization
Technical debt appears as 'code smell' clouds that emanate from affected systems. The cloud density indicates severity: light haze for minor debt, dense fog for critical debt. Players can click on debt clouds to see specific issues and mitigation options.
### 4.5.4 Debt Mitigation
- Refactoring Sprints: Dedicate resources to cleaning up specific systems. Requires time and research.
- Documentation Initiatives: Convert tribal knowledge to written runbooks.
- Testing Investments: Add automated tests to catch regressions.
- Code Review Gates: Enforce review requirements, slowing deployment but reducing debt generation.

# 5. Incident Management System
## 5.1 Incident Types
Incidents are the primary challenge mechanic, replacing combat as the core tension driver:

| Incident Type | Description | Resolution |
| --- | --- | --- |
| Page Storm | Multiple alerts fire simultaneously | Triage and prioritize; some may be noise |
| Cascading Failure | One system down triggers dependent failures | Identify root cause; fix upstream first |
| Data Corruption | Storage integrity compromised | Restore from backup; verify integrity |
| Security Breach | Unauthorized access detected | Containment, forensics, remediation |
| Capacity Exhaustion | Resources fully consumed | Scale up or optimize workloads |

## 5.2 Severity Levels

| SEV | Impact | Response Time | Resolution Target |
| --- | --- | --- | --- |
| SEV4 | Minor, cosmetic | Within business hours | 1 week |
| SEV3 | Degraded service | Within 4 hours | 24 hours |
| SEV2 | Major feature broken | Within 1 hour | 4 hours |
| SEV1 | Full outage | Immediate | 1 hour |

## 5.3 On-Call Engineers
Engineers function as the combat robot equivalent, automatically responding to incidents:
### 5.3.1 Specializations
- SRE (Site Reliability): General purpose. Handles most incidents adequately.
- Security Engineer: Expert at breach containment and forensics.
- DBA (Database Admin): Specialized in data corruption and performance issues.
- Network Engineer: Handles connectivity and routing problems.
### 5.3.2 Fatigue System
Engineers accumulate fatigue when handling incidents. Fatigued engineers make mistakes (longer resolution times, chance of incorrect diagnosis). Rest areas and rotation policies mitigate fatigue.
## 5.4 Postmortem System
After major incidents, players conduct postmortems:
- Blameless Culture: Focusing on systemic causes grants research bonuses
- Blame Culture: Blaming individuals increases engineer turnover
- Five Whys Research: Unlocks root cause analysis, preventing repeat incidents

# 6. Implementation Plan
## 6.1 Development Phases
### Phase 1: Core Systems (Months 1-3)
Establish the foundational systems that everything else builds upon.
- Replace iron/copper/coal with scrap electronics, silicon sand, copper wire
- Implement basic server entities (workbench, single-board computer, basic storage)
- Create network fabric system (cables as belt replacement)
- Implement data handler entities (inserter equivalents)
- Basic power system (compute budget)
- Simple UI for system status
Milestone: Player can boot a system and serve a static page
### Phase 2: Era 1-2 Content (Months 4-6)
Flesh out the early game experience.
- Complete Era 1 buildings and recipes
- Implement uptime SLA mechanic
- Create log accumulation system
- Era 2 buildings: rack servers, switches, UPS, RAID
- Bash script automation system
- Cron job scheduling
- Basic monitoring and alerts
Milestone: Player can achieve 10 users with 95% uptime
### Phase 3: Technical Debt & Incidents (Months 7-9)
Implement the core challenge systems.
- Technical debt generation and visualization
- Debt effects on system performance
- Incident generation based on debt levels
- Incident severity and response systems
- On-call engineer entities
- Postmortem UI and rewards
Milestone: Full incident management loop functional
### Phase 4: Era 3 Content (Months 10-12)
Scale-up era with virtualization and containers.
- Virtualization mechanics
- Container runtime
- Load balancer entities
- CI/CD pipeline buildings
- Configuration management
- Full observability pipeline
Milestone: Player can achieve 10K users with 99% uptime
### Phase 5: Era 4 Content (Months 13-15)
Enterprise features and compliance.
- Kubernetes orchestration system
- Service mesh implementation
- GitOps workflow mechanics
- Compliance audit events
- Multi-region deployment
- Vendor management system
Milestone: Global deployment with SOC2 achievable
### Phase 6: Security System (Months 16-18)
Threat actors and defense layers.
- Implement all threat types
- Defense building entities
- Security research tree
- Breach containment mechanics
- Zero-trust implementation
Milestone: Full security gameplay loop
### Phase 7: Space Age Integration (Months 19-24)
Planetary specializations and endgame.
- Computron planet and thermal mechanics
- Storagia planet and data gravity
- Coldcache planet and archival systems
- Edgeworld planet and partition handling
- Quantumis planet and quantum computing
- Inter-planetary networking
- Victory conditions implementation
Milestone: Complete five-nines endgame achievable
### Phase 8: Polish & Balance (Months 25-27)
- Comprehensive playtesting
- Balance adjustments
- Achievement system
- Easter eggs and humor
- Performance optimization
- Localization preparation

## 6.2 Technical Architecture
### 6.2.1 Mod Structure
The mod will be structured as a total conversion, disabling base game content and replacing it entirely:
- data.lua: Entity definitions, recipes, technologies
- control.lua: Runtime logic, event handlers
- settings.lua: Mod configuration options
- locale/: Localization strings
- graphics/: Custom sprites and icons
- sounds/: Audio assets
### 6.2.2 Key Technical Challenges
- Network Simulation: Implementing packet-based data transfer with realistic throughput, latency, and loss characteristics.
- Incident Generation: Creating emergent incident behavior based on technical debt, load, and random events.
- UI Complexity: Displaying system health, debt visualization, and incident status without overwhelming players.
- Space Age Compatibility: Ensuring planetary mechanics integrate cleanly with Factorio's Space Age systems.
### 6.2.3 Performance Considerations
- Tick-based processing must be optimized for large deployments
- Network simulation should use simplified models at scale
- Debt visualization should be LOD-based (less detail when zoomed out)
- Incident processing should be batched to avoid per-tick overhead

## 6.3 Resource Requirements

| Role | Responsibilities | Effort |
| --- | --- | --- |
| Lead Developer | Core systems, architecture, Lua coding | Full-time, 27 months |
| Systems Designer | Balance, progression, mechanics | Part-time, 27 months |
| Artist | Sprites, icons, UI elements | Full-time, 18 months |
| Sound Designer | Audio assets, ambient sounds | Part-time, 12 months |
| Technical Writer | In-game text, tutorials, docs | Part-time, 15 months |
| QA Testers | Playtesting, bug reports | Part-time, ongoing |

# 7. Research Tree Overview
## 7.1 Era 1 Technologies
- Basic Electronics: Enables component crafting
- Power Management: Stable power delivery
- Data Storage: Hard drive arrays
- Networking Fundamentals: Point-to-point connections
- Web Serving: Static HTTP server
## 7.2 Era 2 Technologies
- Rack Infrastructure: Modular server deployment
- Network Switching: Multi-destination routing
- Power Redundancy: UPS systems
- Storage Redundancy: RAID configurations
- Shell Scripting: Bash automation
- Scheduled Tasks: Cron system
- Log Management: Rotation and archival
- Basic Monitoring: Uptime checks
## 7.3 Era 3 Technologies
- Virtualization: Hypervisor systems
- Containerization: Lightweight isolation
- Load Balancing: Traffic distribution
- CI/CD Pipelines: Automated deployment
- Configuration Management: Desired state automation
- Observability Stack: Metrics, logs, traces
- Incident Response: Alert routing and escalation
- Technical Debt Management: Refactoring tools
## 7.4 Era 4 Technologies
- Container Orchestration: Kubernetes equivalent
- Service Mesh: Inter-service communication
- Infrastructure as Code: Declarative infrastructure
- GitOps: Version-controlled operations
- Compliance Automation: Audit preparation
- Multi-Region Networking: Global deployment
- Disaster Recovery: Failover systems
- ML Operations: Model training and deployment
## 7.5 Era 5 Technologies
- GPU Clustering: Tensor core utilization
- Thermal Management: Heat dissipation at scale
- Cold Storage: Archival optimization
- Edge Computing: Distributed processing
- Partition Tolerance: Offline-first design
- Quantum Computing: Qubit manipulation
- Entanglement Networks: Instant communication

# 8. Victory Conditions
## 8.1 Standard Victory
Achieve 99.999% uptime ('five nines') across all regions for one in-game year while serving 1 million concurrent users. This requires mastery of all systems: redundancy, incident response, capacity planning, and security.
## 8.2 Space Age Victory
Establish quantum-entangled communication between all planets, enabling instant global consistency. This effectively 'solves' the CAP theorem using alien quantum technology, representing the ultimate achievement in distributed systems.
## 8.3 Challenge Modes
### 8.3.1 Move Fast and Break Things
Speedrun category: Reach 1M users as fast as possible. Technical debt and incident count don't matter - only scale matters. High-risk, high-reward playstyle.
### 8.3.2 Legacy Migration
Start with a horrific legacy system (COBOL on mainframes, spaghetti architecture, zero documentation) and modernize to cloud-native without any downtime. Extreme challenge mode.
### 8.3.3 Bootstrap Mode
No starting resources. Must scavenge everything. Represents a true garage startup experience.
### 8.3.4 Chaos Engineering
Random catastrophic failures occur at regular intervals. Tests player's ability to build resilient systems.

# 9. Easter Eggs & Humor
## 9.1 Achievements
- 'Have You Tried Turning It Off And On Again?' - First successful restart after crash
- 'Works On My Machine' - Deploy code that fails in production
- 'It's Always DNS' - Resolve 100 network issues
- 'The Cloud Is Just Someone Else's Computer' - Build first remote data center
- 'There Is No Cloud' - Achieve fully on-premise infrastructure
- 'Serverless Has Servers' - Deploy 1000 serverless functions
- 'This Meeting Could Have Been An Email' - Complete 50 compliance audits
## 9.2 Decorative Items
- 'Works On My Machine' certification - Framed wall decoration
- Rubber duck debugging station - Increases nearby engineer efficiency
- Whiteboard with impossible architecture diagram
- Coffee machine (improves engineer morale, required for 24-hour operations)
- 'Days Since Last Incident' counter
## 9.3 Random Events
- DNS propagation always takes 48 hours (regardless of actual TTL)
- Printer jam during critical deployment
- Intern accidentally drops production database
- CEO asks if you can 'just add blockchain'
- Marketing promises feature that doesn't exist
## 9.4 Tooltip Humor
Items and buildings include humorous tooltips referencing IT culture:
- Load Balancer: 'Like a traffic cop, but the traffic is made of ones and zeros, and the cop is also made of ones and zeros.'
- Technical Debt: 'The compound interest rate is 100% per sprint.'
- Kubernetes: 'Greek for "person who pilots container ships into icebergs"'

# 10. Appendices
## Appendix A: Glossary
Terms are defined in-game through an integrated glossary accessible via ALT+click:
- APT: Advanced Persistent Threat. Sophisticated, long-term attack campaigns.
- CI/CD: Continuous Integration/Continuous Deployment. Automated build and release.
- DDoS: Distributed Denial of Service. Attack that overwhelms with traffic.
- GitOps: Using Git as single source of truth for infrastructure.
- IaC: Infrastructure as Code. Defining infrastructure in version-controlled files.
- K8s: Kubernetes. Container orchestration platform.
- SLA: Service Level Agreement. Uptime commitment to customers.
- SRE: Site Reliability Engineering. Discipline of maintaining service reliability.
## Appendix B: References
The following resources informed the design:
- Google SRE Book - Site reliability engineering principles
- The Phoenix Project - IT/DevOps transformation narrative
- Accelerate - Research on high-performing tech organizations
- Release It! - Patterns for resilient software design
- The Art of Capacity Planning - Scaling infrastructure
## Appendix C: Mod Compatibility
Sysadmin is designed as a total conversion and is incompatible with:
- Other total conversion mods
- Mods that modify base resources
- Major overhaul mods (Bob's, Angel's, Krastorio, SE)
Compatible with:
- Quality-of-life mods that don't change game mechanics
- UI improvement mods
- Map generation mods (with potential balance issues)

End of Document