-- Sysadmin POC - Alert System
-- Notifies players of important IT events

local Alerts = {}

-- Alert colors
local COLORS = {
  info = {0.5, 0.8, 1},      -- Light blue
  success = {0, 1, 0},        -- Green
  warning = {1, 0.8, 0},      -- Yellow/Orange
  critical = {1, 0.3, 0},     -- Orange/Red
  error = {1, 0, 0}           -- Red
}

-- Backlog thresholds (must match data-system.lua)
local BACKLOG_WARNING = 100
local BACKLOG_CRITICAL = 500
local BACKLOG_SEVERE = 1000

-- Initialize alert tracking
function Alerts.init()
  storage.alert_state = storage.alert_state or {
    backlog = "normal",
    emergency = false
  }
end

-- Send alert to all connected players
function Alerts.send(alert_type, message)
  local color = COLORS[alert_type] or COLORS.info

  for _, player in pairs(game.connected_players) do
    player.print("[Sysadmin] " .. message, color)
  end
end

-- Check and send backlog alerts
function Alerts.check_backlog()
  local backlog = storage.metrics.data_backlog or 0
  local current_state

  if backlog >= BACKLOG_SEVERE then
    current_state = "severe"
  elseif backlog >= BACKLOG_CRITICAL then
    current_state = "critical"
  elseif backlog >= BACKLOG_WARNING then
    current_state = "warning"
  else
    current_state = "normal"
  end

  local last_state = storage.alert_state.backlog or "normal"

  -- Only alert on state transitions
  if current_state ~= last_state then
    if current_state == "severe" then
      Alerts.send("error", "DATA BACKLOG SEVERE! Build more servers immediately!")
    elseif current_state == "critical" then
      Alerts.send("critical", "Data backlog critical! Processing cannot keep up.")
    elseif current_state == "warning" then
      Alerts.send("warning", "Data backlog accumulating. Consider adding servers.")
    elseif current_state == "normal" and last_state ~= "normal" then
      Alerts.send("success", "Data backlog cleared. Systems operating normally.")
    end

    storage.alert_state.backlog = current_state
  end
end

-- Check and send emergency stop alerts
function Alerts.check_emergency()
  local is_emergency = storage.emergency_stop or false
  local was_emergency = storage.alert_state.emergency or false

  if is_emergency ~= was_emergency then
    if is_emergency then
      Alerts.send("error", "EMERGENCY STOP ACTIVATED! Data collection paused.")
    else
      Alerts.send("success", "Emergency stop released. Normal operations resumed.")
    end

    storage.alert_state.emergency = is_emergency
  end
end

-- Check all alert conditions (called from tick)
function Alerts.tick()
  Alerts.check_backlog()
  Alerts.check_emergency()
end

return Alerts
