-- Sysadmin POC - Technical Debt System
-- Tracks accumulated IT neglect and imposes a proportional factory penalty.
--
-- Debt accumulates when data backlog stays above DEBT_THRESHOLD for sustained
-- periods. It recovers automatically when backlog is cleared. The penalty is
-- linear in debt (0 at debt=0, MAX_PENALTY at MAX_DEBT) -- continuous, not
-- tiered, so there's no dead zone or cliff. circuit-control.lua nets this
-- against data-system.lua's IT coverage bonus into one speed_bonus per
-- assembler: a well-maintained factory sits above baseline, a neglected one
-- sinks below it.
--
-- Shared contract with circuit-control.lua:
--   storage.debt_penalty_fraction  (number 0.0–0.20, continuous)  read each control tick
--   storage.technical_debt         (table)                        owned by this module

local TechnicalDebt = {}

local DEBT_THRESHOLD  = 100    -- backlog below this → no debt gain
local DEBT_RATE       = 1.0    -- debt gained/sec per 100 units of excess backlog
local RECOVERY_RATE   = 5.0    -- debt lost/sec when backlog is below threshold
local MAX_DEBT        = 1000
local MAX_PENALTY     = 0.20   -- -20% speed at MAX_DEBT, linear in between

-- Display-only labels for the dashboard/debt meter -- the penalty itself
-- (above) is continuous and does not use these boundaries.
local LEVEL_TIERS = {
  { min = 800, label = "critical" },
  { min = 500, label = "high"     },
  { min = 200, label = "moderate" },
  { min = 0,   label = "low"      },
}

function TechnicalDebt.init()
  storage.technical_debt = storage.technical_debt or {
    total   = 0,
    history = {},  -- ring buffer, 60 samples (1 per second = 60-second sparkline)
  }
  storage.debt_penalty_fraction = storage.debt_penalty_fraction or 0
end

-- Called every 60 ticks (1 second) from control.lua
function TechnicalDebt.tick()
  local debt    = storage.technical_debt
  local backlog = storage.metrics and storage.metrics.data_backlog or 0
  local excess  = math.max(0, backlog - DEBT_THRESHOLD)

  if excess > 0 then
    debt.total = math.min(MAX_DEBT, debt.total + DEBT_RATE * (excess / 100))
  else
    debt.total = math.max(0, debt.total - RECOVERY_RATE)
  end

  -- Sparkline history (ring buffer, 60 entries)
  table.insert(debt.history, math.floor(debt.total))
  if #debt.history > 60 then table.remove(debt.history, 1) end

  -- Continuous penalty for circuit-control.lua's net efficiency calculation.
  storage.debt_penalty_fraction = (debt.total / MAX_DEBT) * MAX_PENALTY
end

function TechnicalDebt.get_total()
  return math.floor((storage.technical_debt or {}).total or 0)
end

-- Fraction of speed (0.0-MAX_PENALTY) that debt currently costs a NORMAL
-- monitored assembler, before netting against the IT coverage bonus.
function TechnicalDebt.get_penalty()
  return storage.debt_penalty_fraction or 0
end

function TechnicalDebt.get_level()
  local t = TechnicalDebt.get_total()
  for _, tier in ipairs(LEVEL_TIERS) do
    if t >= tier.min then return tier.label end
  end
  return "low"
end

return TechnicalDebt
