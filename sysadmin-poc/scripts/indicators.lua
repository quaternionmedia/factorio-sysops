-- Sysadmin POC - Visual Indicators
-- Renders status indicators above monitored assemblers
-- Also handles radius indicators for sensors (like power pole coverage)

local Indicators = {}

local CircuitControl = require("scripts.circuit-control")

-- Initialize indicator tracking
function Indicators.init()
  storage.indicators = storage.indicators or {}
  storage.radius_indicators = storage.radius_indicators or {}  -- Per-player radius indicators
end

-- Update indicator for a specific assembler
function Indicators.update_indicator(assembler_id, assembler_data)
  if not assembler_data.entity or not assembler_data.entity.valid then
    Indicators.remove_indicator(assembler_id)
    return
  end

  local entity = assembler_data.entity
  local indicator_data = storage.indicators[assembler_id]

  -- Determine the status color based on circuit control state
  -- Green = monitored and active
  -- Red = emergency stop
  -- Yellow/Orange = circuit paused (disabled by circuit signal)
  -- Blue = circuit enabled (forced on by circuit signal)
  local status, color

  local cc = CircuitControl
  local display_state = cc.get_assembler_display_state(assembler_id)

  if display_state == "circuit_paused" then
    status = "circuit_paused"
    color = {r = 1, g = 0.7, b = 0, a = 0.8}  -- Yellow/Orange for circuit-paused
  elseif display_state == "circuit_enabled" then
    status = "circuit_enabled"
    color = {r = 0.3, g = 0.8, b = 1, a = 0.8}  -- Cyan/Blue for circuit-forced-on
  elseif display_state == "stopped" then
    status = "stopped"
    color = {r = 1, g = 0, b = 0, a = 0.8}  -- Red for emergency stop
  else
    status = "active"
    color = {r = 0, g = 1, b = 0, a = 0.8}  -- Green for normal active
  end

  -- Check if we need to update the indicator
  if indicator_data and indicator_data.status == status then
    return  -- No change needed
  end

  -- Remove old indicator if exists (Factorio 2.0 API: use object.valid and object.destroy())
  if indicator_data and indicator_data.render_id and indicator_data.render_id.valid then
    indicator_data.render_id.destroy()
  end

  -- Create new indicator
  local render_id = rendering.draw_sprite{
    sprite = "utility/indication_arrow",
    target = entity,
    target_offset = {0, -1.5},
    surface = entity.surface,
    tint = color,
    x_scale = 0.5,
    y_scale = 0.5,
    render_layer = "entity-info-icon"
  }

  storage.indicators[assembler_id] = {
    render_id = render_id,
    status = status,
    entity = entity
  }
end

-- Remove indicator for an assembler
function Indicators.remove_indicator(assembler_id)
  local indicator_data = storage.indicators[assembler_id]
  if indicator_data then
    -- Factorio 2.0 API: use object.valid and object.destroy()
    if indicator_data.render_id and indicator_data.render_id.valid then
      indicator_data.render_id.destroy()
    end
    storage.indicators[assembler_id] = nil
  end
end

-- Update all indicators
function Indicators.update_all()
  -- Clean up indicators for removed assemblers
  for assembler_id, indicator_data in pairs(storage.indicators) do
    if not storage.monitored_assemblers[assembler_id] then
      Indicators.remove_indicator(assembler_id)
    end
  end

  -- Update indicators for all monitored assemblers
  for assembler_id, assembler_data in pairs(storage.monitored_assemblers) do
    Indicators.update_indicator(assembler_id, assembler_data)
  end
end

-- Called when an assembler is added to monitoring
function Indicators.on_assembler_added(assembler_id, assembler_data)
  Indicators.update_indicator(assembler_id, assembler_data)
end

-- Called when an assembler is removed from monitoring
function Indicators.on_assembler_removed(assembler_id)
  Indicators.remove_indicator(assembler_id)
end

-- ============================================
-- SENSOR RADIUS INDICATORS
-- Shows detection range when sensor is selected
-- ============================================

-- Remove radius indicator for a player
function Indicators.remove_radius_indicator(player_index)
  local indicator = storage.radius_indicators[player_index]
  if indicator then
    if indicator.circle and indicator.circle.valid then
      indicator.circle.destroy()
    end
    if indicator.border and indicator.border.valid then
      indicator.border.destroy()
    end
    storage.radius_indicators[player_index] = nil
  end
end

-- Show radius indicator around a sensor for a specific player
function Indicators.show_sensor_radius(player_index, sensor)
  -- Remove any existing radius indicator for this player
  Indicators.remove_radius_indicator(player_index)

  if not sensor or not sensor.valid then return end

  -- Get sensor detection range from settings
  local range = 5  -- Default
  if settings.global["sysadmin-sensor-range"] then
    range = settings.global["sysadmin-sensor-range"].value
  end

  -- Determine color based on sensor control state
  local fill_color, border_color
  local cc = CircuitControl
  local sensor_state = cc.get_sensor_state(sensor.unit_number)

  if sensor_state.state == cc.STATES.CIRCUIT_DISABLED then
    -- Yellow/Orange for circuit-paused
    fill_color = {r = 1, g = 0.7, b = 0, a = 0.15}
    border_color = {r = 1, g = 0.8, b = 0.2, a = 0.6}
  elseif sensor_state.state == cc.STATES.CIRCUIT_ENABLED then
    -- Blue for circuit-forced-on
    fill_color = {r = 0.2, g = 0.6, b = 1, a = 0.15}
    border_color = {r = 0.3, g = 0.7, b = 1, a = 0.6}
  elseif storage.emergency_stop then
    -- Red for emergency stop
    fill_color = {r = 1, g = 0.2, b = 0.2, a = 0.15}
    border_color = {r = 1, g = 0.3, b = 0.3, a = 0.6}
  else
    -- Cyan for normal active
    fill_color = {r = 0.2, g = 0.8, b = 1, a = 0.15}
    border_color = {r = 0.3, g = 0.9, b = 1, a = 0.6}
  end

  -- Draw filled circle (area of influence)
  local circle = rendering.draw_circle{
    color = fill_color,
    radius = range,
    filled = true,
    target = sensor.position,
    surface = sensor.surface,
    players = {player_index},
    draw_on_ground = true
  }

  -- Draw border circle for visibility
  local border = rendering.draw_circle{
    color = border_color,
    radius = range,
    width = 2,
    filled = false,
    target = sensor.position,
    surface = sensor.surface,
    players = {player_index}
  }

  storage.radius_indicators[player_index] = {
    circle = circle,
    border = border,
    sensor = sensor
  }
end

-- Handle player selecting a different entity
function Indicators.on_selected_entity_changed(player_index, entity)
  -- If selected entity is a data sensor, show radius
  if entity and entity.valid and entity.name == "data-sensor" then
    Indicators.show_sensor_radius(player_index, entity)
  else
    -- Hide radius indicator when not selecting a sensor
    Indicators.remove_radius_indicator(player_index)
  end
end

-- Clean up radius indicators for disconnected players
function Indicators.cleanup_radius_indicators()
  for player_index, indicator in pairs(storage.radius_indicators) do
    local player = game.get_player(player_index)
    if not player or not player.connected then
      Indicators.remove_radius_indicator(player_index)
    elseif indicator.sensor and not indicator.sensor.valid then
      Indicators.remove_radius_indicator(player_index)
    end
  end
end

return Indicators
