# Factorio: Sysadmin

IT Infrastructure addon mod for Factorio 2. Add sensors, network cables,
servers, and dashboards to monitor and automate your factory — without
replacing any vanilla content.

Full design documentation, mechanics, and roadmap: see [docs/README.md](docs/README.md).

Mod source lives in [sysadmin-poc/](sysadmin-poc/). Status: design complete
through Phase 3 (automation); Milestone 1 (technical debt) implemented,
pending in-game verification — see [docs/NEXT-PHASE.md](docs/NEXT-PHASE.md).

## Sibling projects

This mod is one of three standalone-but-composable Factorio projects. Each
is independently cloneable, buildable, and releasable; none depends on
another's source. They share governance (see below) and compose only
through documented seams:

| Repo | Role | Composition seam |
|---|---|---|
| [datafactorio](https://github.com/quaternionmedia/datafactorio) | Out-of-game dashboard visualizing factory + IT data | Optional file-based JSON export from this mod, consumed by DataFactorio's importer — see [docs/DATAFACTORIO-INTEGRATION.md](docs/DATAFACTORIO-INTEGRATION.md) |
| [factorio-server](https://github.com/quaternionmedia/factorio-server) | Dedicated server hosting (Docker + ZeroTier) | Deployment target for playtesting this mod in multiplayer |

## Governance

This project adopts the Quaternion Media constitution (decision-record
discipline, license/house-stack/seam records) via a `governance/qm`
submodule pinned to this project's own `project/factorio-sysops` branch of
[quaternionmedia/qm](https://github.com/quaternionmedia/qm). See
`governance/qm/adr/` for this project's decision records, starting with
`DRAFT-constitution-adoption-scope.md`.
