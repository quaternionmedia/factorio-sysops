-- Sysadmin POC - Circuit Control System
-- Handles reading circuit signals from sensors to control monitored assemblers
-- signal-it-control: positive = enable, negative = disable, zero = no override

local CircuitControl = {}

local DataSystem = require("scripts.data-system")
local TechnicalDebt = require("scripts.technical-debt")

-- Control states for indicators
CircuitControl.STATES = {
  NORMAL = "normal",           -- No circuit control (operating based on emergency_stop)
  CIRCUIT_ENABLED = "enabled", -- Circuit signal > 0, actively enabled
  CIRCUIT_DISABLED = "disabled" -- Circuit signal < 0, paused by circuit
}

-- Initialize control tracking
function CircuitControl.init()
  storage.circuit_control = storage.circuit_control or {}
  -- Per-sensor control state: sensor_id -> { state, controlled_assemblers }
  storage.sensor_control_state = storage.sensor_control_state or {}
end

-- Get the current control state for a sensor
function CircuitControl.get_sensor_state(sensor_id)
  return storage.sensor_control_state[sensor_id] or {
    state = CircuitControl.STATES.NORMAL,
    signal_value = 0
  }
end

-- Read circuit signal from a sensor entity
local function read_sensor_control_signal(sensor)
  if not sensor or not sensor.valid then
    return 0
  end

  local signal_value = 0

  -- Check red wire network
  local red_network = sensor.get_circuit_network(defines.wire_type.red)
  if red_network then
    local signal = red_network.get_signal({type = "virtual", name = "signal-it-control"})
    if signal then
      signal_value = signal_value + signal
    end
  end

  -- Check green wire network
  local green_network = sensor.get_circuit_network(defines.wire_type.green)
  if green_network then
    local signal = green_network.get_signal({type = "virtual", name = "signal-it-control"})
    if signal then
      signal_value = signal_value + signal
    end
  end

  return signal_value
end

-- entity.speed_bonus is assumed writable on assembling-machine entities (the
-- same mechanism beacons/modules use internally). Guarded with pcall so a
-- wrong assumption logs once instead of erroring every control tick.
local warned_speed_bonus_unsupported = false

-- Apply control state to an assembler: on/off via .active, and net IT
-- efficiency (coverage bonus minus debt penalty, see CircuitControl.update())
-- via .speed_bonus.
local function apply_assembler_control(assembler, should_be_active, net_bonus)
  if not assembler or not assembler.valid then
    return
  end

  assembler.active = should_be_active

  local ok = pcall(function()
    assembler.speed_bonus = net_bonus or 0
  end)
  if not ok and not warned_speed_bonus_unsupported then
    warned_speed_bonus_unsupported = true
    log("[sysadmin-poc] entity.speed_bonus assignment failed -- IT efficiency bonus/penalty will not apply on this Factorio version.")
  end
end

-- Update control for all sensors - called periodically
function CircuitControl.update()
  if not storage.sensors then return end

  for sensor_id, sensor_data in pairs(storage.sensors) do
    local sensor = sensor_data.entity
    if sensor and sensor.valid then
      local signal_value = read_sensor_control_signal(sensor)
      local old_state = CircuitControl.get_sensor_state(sensor_id)
      local new_state

      if signal_value > 0 then
        new_state = CircuitControl.STATES.CIRCUIT_ENABLED
      elseif signal_value < 0 then
        new_state = CircuitControl.STATES.CIRCUIT_DISABLED
      else
        new_state = CircuitControl.STATES.NORMAL
      end

      -- Store the state
      storage.sensor_control_state[sensor_id] = {
        state = new_state,
        signal_value = signal_value
      }

      -- Apply control to all assemblers monitored by this sensor
      local should_be_active
      if new_state == CircuitControl.STATES.CIRCUIT_DISABLED then
        -- Circuit says disable
        should_be_active = false
      elseif new_state == CircuitControl.STATES.CIRCUIT_ENABLED then
        -- Circuit says enable (override emergency stop for this sensor's assemblers)
        should_be_active = true
      else
        -- Normal: respect global emergency stop
        should_be_active = not storage.emergency_stop
      end

      -- Apply to monitored assemblers under this sensor. Net efficiency is
      -- one continuous curve: the IT coverage bonus (data-system.lua) minus
      -- the debt penalty in NORMAL state. CIRCUIT_ENABLED keeps the coverage
      -- bonus but is immune to the debt penalty, same immunity as before.
      if sensor_data.monitored_assemblers then
        local net_bonus = 0
        if should_be_active then
          local coverage_bonus = DataSystem.get_coverage_bonus()
          local debt_penalty = (new_state == CircuitControl.STATES.NORMAL)
            and TechnicalDebt.get_penalty() or 0
          net_bonus = coverage_bonus - debt_penalty
        end

        for assembler_id, _ in pairs(sensor_data.monitored_assemblers) do
          local assembler_data = storage.monitored_assemblers[assembler_id]
          if assembler_data and assembler_data.entity and assembler_data.entity.valid then
            apply_assembler_control(assembler_data.entity, should_be_active, net_bonus)
          end
        end
      end
    else
      -- Clean up invalid sensor state
      storage.sensor_control_state[sensor_id] = nil
    end
  end
end

-- Get the effective control state for an assembler (for indicator display)
-- Returns: "active", "stopped", "circuit_paused", "circuit_enabled", "debt_paused"
function CircuitControl.get_assembler_display_state(assembler_id)
  local assembler_data = storage.monitored_assemblers[assembler_id]
  if not assembler_data then
    return "unknown"
  end

  local sensor_id = assembler_data.sensor_id
  if not sensor_id then
    return storage.emergency_stop and "stopped" or "active"
  end

  local sensor_state = CircuitControl.get_sensor_state(sensor_id)

  if sensor_state.state == CircuitControl.STATES.CIRCUIT_DISABLED then
    return "circuit_paused"
  elseif sensor_state.state == CircuitControl.STATES.CIRCUIT_ENABLED then
    return "circuit_enabled"
  elseif storage.emergency_stop then
    return "stopped"
  else
    -- "debt_paused" now means net-negative efficiency (debt penalty exceeds
    -- the IT coverage bonus), not a literal pause -- name kept for minimal
    -- ripple. Every NORMAL monitored assembler shares the same net_bonus
    -- (see CircuitControl.update()), so this is a factory-wide state, not
    -- a per-assembler one.
    if TechnicalDebt.get_penalty() > DataSystem.get_coverage_bonus() then
      return "debt_paused"
    end
    return "active"
  end
end

-- Clean up when sensor is removed
function CircuitControl.on_sensor_removed(sensor_id)
  storage.sensor_control_state[sensor_id] = nil
end

-- Re-enable all assemblers when their sensor control returns to normal
-- (useful when wire is disconnected)
function CircuitControl.restore_normal_state(sensor_id)
  local sensor_data = storage.sensors[sensor_id]
  if not sensor_data then return end

  local should_be_active = not storage.emergency_stop

  if sensor_data.monitored_assemblers then
    for assembler_id, _ in pairs(sensor_data.monitored_assemblers) do
      local assembler_data = storage.monitored_assemblers[assembler_id]
      if assembler_data and assembler_data.entity and assembler_data.entity.valid then
        apply_assembler_control(assembler_data.entity, should_be_active)
      end
    end
  end
end

-- When emergency stop changes, update all assemblers respecting circuit overrides
function CircuitControl.on_emergency_stop_changed()
  for sensor_id, sensor_data in pairs(storage.sensors or {}) do
    local sensor_state = CircuitControl.get_sensor_state(sensor_id)

    -- Only affect assemblers under sensors with NORMAL control state
    if sensor_state.state == CircuitControl.STATES.NORMAL then
      local should_be_active = not storage.emergency_stop

      if sensor_data.monitored_assemblers then
        for assembler_id, _ in pairs(sensor_data.monitored_assemblers) do
          local assembler_data = storage.monitored_assemblers[assembler_id]
          if assembler_data and assembler_data.entity and assembler_data.entity.valid then
            apply_assembler_control(assembler_data.entity, should_be_active)
          end
        end
      end
    end
    -- Sensors with CIRCUIT_ENABLED or CIRCUIT_DISABLED keep their current state
  end
end

return CircuitControl
