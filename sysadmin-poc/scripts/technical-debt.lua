-- Sysadmin POC - Technical Debt System
-- Tracks accumulated IT neglect and imposes a proportional factory penalty.
--
-- Debt accumulates when data backlog stays above DEBT_THRESHOLD for sustained
-- periods. It recovers automatically when backlog is cleared.  At high debt
-- levels a fraction of NORMAL-state assemblers (those not circuit-controlled)
-- are deterministically disabled each update cycle, reducing effective
-- throughput.  The disabled set is chosen by unit_number % 100, which is
-- stable and requires no extra per-assembler state.
--
-- Shared contract with circuit-control.lua:
--   storage.debt_penalty_fraction  (number 0.0–0.20)  read each control tick
--   storage.technical_debt         (table)             owned by this module

local TechnicalDebt = {}

local DEBT_THRESHOLD  = 100    -- backlog below this → no debt gain
local DEBT_RATE       = 1.0    -- debt gained/sec per 100 units of excess backlog
local RECOVERY_RATE   = 5.0    -- debt lost/sec when backlog is below threshold
local MAX_DEBT        = 1000

-- Penalty tiers: evaluated in order, first match wins
local PENALTY_TIERS = {
  { min = 800, fraction = 0.20, label = "critical" },
  { min = 500, fraction = 0.10, label = "high"     },
  { min = 200, fraction = 0.00, label = "moderate" },
  { min = 0,   fraction = 0.00, label = "low"      },
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

  -- Write penalty fraction for circuit-control.lua to consume
  local fraction = 0
  for _, tier in ipairs(PENALTY_TIERS) do
    if debt.total >= tier.min then
      fraction = tier.fraction
      break
    end
  end
  storage.debt_penalty_fraction = fraction
end

function TechnicalDebt.get_total()
  return math.floor((storage.technical_debt or {}).total or 0)
end

function TechnicalDebt.get_fraction()
  return storage.debt_penalty_fraction or 0
end

function TechnicalDebt.get_level()
  local t = TechnicalDebt.get_total()
  for _, tier in ipairs(PENALTY_TIERS) do
    if t >= tier.min then return tier.label end
  end
  return "low"
end

return TechnicalDebt
