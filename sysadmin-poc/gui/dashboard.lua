-- Sysadmin POC - Dashboard GUI
-- Displays IT metrics when clicking on a dashboard terminal

local Dashboard = {}

-- GUI element names
local GUI_FRAME = "sysadmin_dashboard_frame"
local GUI_METRICS = "sysadmin_dashboard_metrics"

-- Create the dashboard GUI for a player
function Dashboard.create(player)
  -- Close existing if open
  Dashboard.destroy(player)

  local screen = player.gui.screen

  -- Main frame
  local frame = screen.add{
    type = "frame",
    name = GUI_FRAME,
    caption = {"", "[img=item/dashboard-terminal] ", "IT Dashboard"},
    direction = "vertical"
  }
  frame.auto_center = true

  -- Close button in titlebar
  local titlebar = frame.add{
    type = "flow",
    direction = "horizontal"
  }
  titlebar.drag_target = frame

  -- Content area
  local content = frame.add{
    type = "frame",
    name = "content",
    style = "inside_shallow_frame_with_padding",
    direction = "vertical"
  }

  -- Metrics table
  local metrics_flow = content.add{
    type = "table",
    name = GUI_METRICS,
    column_count = 2
  }
  metrics_flow.style.column_alignments[1] = "left"
  metrics_flow.style.column_alignments[2] = "right"
  metrics_flow.style.horizontal_spacing = 20

  -- Add metric rows
  Dashboard.add_metric_row(metrics_flow, "monitored", "Monitored Assemblers", 0)
  Dashboard.add_metric_row(metrics_flow, "throughput", "Throughput (items/sec)", 0)
  Dashboard.add_metric_row(metrics_flow, "data_rate", "Data Rate (packets/sec)", 0)
  Dashboard.add_metric_row(metrics_flow, "utilization", "Server Utilization", "0%")
  Dashboard.add_metric_row(metrics_flow, "backlog", "Data Backlog", 0)
  Dashboard.add_metric_row(metrics_flow, "processed", "Total Processed", 0)
  Dashboard.add_metric_row(metrics_flow, "debt", "Technical Debt", "0 (low)")

  -- Status section
  local status_frame = content.add{
    type = "frame",
    name = "status_frame",
    style = "inside_shallow_frame",
    direction = "vertical"
  }
  status_frame.style.top_margin = 10
  status_frame.style.padding = 8

  local status_label = status_frame.add{
    type = "label",
    name = "status_label",
    caption = "System Status: Normal"
  }
  status_label.style.font = "default-bold"
  status_label.style.font_color = {0, 1, 0}

  -- Infrastructure counts
  local infra_flow = content.add{
    type = "table",
    name = "infra_flow",
    column_count = 2
  }
  infra_flow.style.top_margin = 10
  infra_flow.style.horizontal_spacing = 20

  Dashboard.add_metric_row(infra_flow, "sensors", "Data Sensors", 0)
  Dashboard.add_metric_row(infra_flow, "servers", "Basic Servers", 0)
  Dashboard.add_metric_row(infra_flow, "bridges", "Circuit Bridges", 0)

  -- Close button
  local button_flow = frame.add{
    type = "flow",
    direction = "horizontal"
  }
  button_flow.style.top_margin = 10
  button_flow.style.horizontal_align = "center"

  button_flow.add{
    type = "button",
    name = "sysadmin_dashboard_close",
    caption = "Close"
  }

  -- Update with current data
  Dashboard.update(player)

  return frame
end

-- Add a metric row to the GUI
function Dashboard.add_metric_row(parent, name, label_text, value)
  parent.add{
    type = "label",
    name = "label_" .. name,
    caption = label_text .. ":"
  }
  local value_label = parent.add{
    type = "label",
    name = "value_" .. name,
    caption = tostring(value)
  }
  value_label.style.font = "default-semibold"
  return value_label
end

-- Update the dashboard with current metrics
function Dashboard.update(player)
  local frame = player.gui.screen[GUI_FRAME]
  if not frame then return end

  local metrics = storage.metrics or {}
  local content = frame.content
  local metrics_table = content[GUI_METRICS]

  -- Debt state (read once; used for both the debt row and status label)
  local debt_total   = math.floor((storage.technical_debt or {}).total or 0)
  local debt_penalty = storage.debt_penalty_fraction or 0
  local debt_level
  if     debt_total >= 800 then debt_level = "critical"
  elseif debt_total >= 500 then debt_level = "high"
  elseif debt_total >= 200 then debt_level = "moderate"
  else                          debt_level = "low"
  end

  -- Update main metrics
  metrics_table.value_monitored.caption = tostring(metrics.monitored_count or 0)
  metrics_table.value_throughput.caption = tostring(metrics.total_throughput or 0)
  metrics_table.value_data_rate.caption = tostring(metrics.data_rate or 0)
  metrics_table.value_utilization.caption = tostring(metrics.utilization or 0) .. "%"
  metrics_table.value_backlog.caption = tostring(metrics.data_backlog or 0)
  metrics_table.value_processed.caption = tostring(metrics.total_processed or 0)

  -- Update debt row with color coding
  local debt_label = metrics_table.value_debt
  local penalty_str = debt_penalty > 0
    and (" [-" .. math.floor(debt_penalty * 100) .. "% eff]")
    or ""
  debt_label.caption = debt_total .. " (" .. debt_level .. ")" .. penalty_str
  if     debt_level == "critical" then debt_label.style.font_color = {1,   0.2, 0.2}
  elseif debt_level == "high"     then debt_label.style.font_color = {1,   0.5, 0}
  elseif debt_level == "moderate" then debt_label.style.font_color = {1,   1,   0}
  else                                 debt_label.style.font_color = {0.6, 1,   0.6}
  end

  -- Update status label (debt overrides backlog warnings when higher severity)
  local status_frame = content.status_frame
  local status_label = status_frame.status_label
  local backlog = metrics.data_backlog or 0

  if storage.emergency_stop then
    status_label.caption = "System Status: EMERGENCY STOP"
    status_label.style.font_color = {1, 0, 0}
  elseif debt_level == "critical" then
    status_label.caption = "System Status: CRITICAL - Technical Debt at " .. debt_total
    status_label.style.font_color = {1, 0.2, 0.2}
  elseif debt_level == "high" then
    status_label.caption = "System Status: HIGH DEBT - Efficiency degraded"
    status_label.style.font_color = {1, 0.5, 0}
  elseif backlog >= 1000 then
    status_label.caption = "System Status: CRITICAL - High Backlog"
    status_label.style.font_color = {1, 0, 0}
  elseif backlog >= 500 then
    status_label.caption = "System Status: WARNING - Backlog Growing"
    status_label.style.font_color = {1, 0.8, 0}
  elseif backlog >= 100 then
    status_label.caption = "System Status: Caution - Processing Slow"
    status_label.style.font_color = {1, 1, 0}
  else
    status_label.caption = "System Status: Normal"
    status_label.style.font_color = {0, 1, 0}
  end

  -- Update infrastructure counts
  local infra = content.infra_flow
  infra.value_sensors.caption = tostring(table_size(storage.sensors or {}))
  infra.value_servers.caption = tostring(table_size(storage.servers or {}))
  infra.value_bridges.caption = tostring(table_size(storage.circuit_bridges or {}))
end

-- Destroy the dashboard GUI for a player
function Dashboard.destroy(player)
  local frame = player.gui.screen[GUI_FRAME]
  if frame then
    frame.destroy()
  end
end

-- Check if dashboard is open for a player
function Dashboard.is_open(player)
  return player.gui.screen[GUI_FRAME] ~= nil
end

-- Handle GUI click events
function Dashboard.on_gui_click(event)
  if event.element.name == "sysadmin_dashboard_close" then
    local player = game.players[event.player_index]
    Dashboard.destroy(player)
    return true
  end
  return false
end

-- Update all open dashboards
function Dashboard.update_all()
  for _, player in pairs(game.connected_players) do
    if Dashboard.is_open(player) then
      Dashboard.update(player)
    end
  end
end

return Dashboard
