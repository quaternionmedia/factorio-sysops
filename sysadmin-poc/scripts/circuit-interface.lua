-- Sysadmin POC - Circuit Interface
-- Handles circuit bridge signal output and input reading

local CircuitInterface = {}
local DataSystem = require("scripts.data-system")

-- CircuitControl is loaded lazily to avoid circular dependency
local CircuitControl = nil

local function get_circuit_control()
  if not CircuitControl then
    CircuitControl = require("scripts.circuit-control")
  end
  return CircuitControl
end

-- Track circuit bridge entities
function CircuitInterface.on_entity_built(entity)
  if entity.name == "circuit-bridge" then
    storage.circuit_bridges[entity.unit_number] = {
      entity = entity
    }
  end
end

function CircuitInterface.on_entity_removed(entity)
  if entity.name == "circuit-bridge" then
    storage.circuit_bridges[entity.unit_number] = nil
  end
end

-- Update circuit bridge signal outputs - called every 60 ticks
function CircuitInterface.update_signals()
  local metrics = storage.metrics or {}

  -- Update global metrics on circuit bridges
  for unit_number, bridge_data in pairs(storage.circuit_bridges) do
    local bridge = bridge_data.entity
    if bridge and bridge.valid then
      -- Get the combinator's control behavior
      local control = bridge.get_or_create_control_behavior()
      if control then
        -- Set signals based on IT metrics
        -- Note: constant-combinator uses sections in 2.0
        local section = control.get_section(1)
        if section then
          -- Clear existing signals first
          for i = 1, section.filters_count do
            section.clear_slot(i)
          end

          -- Set new signals
          section.set_slot(1, {
            value = {
              type = "virtual",
              name = "signal-throughput",
              quality = "normal"
            },
            min = metrics.total_throughput or 0
          })

          section.set_slot(2, {
            value = {
              type = "virtual",
              name = "signal-data-rate",
              quality = "normal"
            },
            min = metrics.data_rate or 0
          })

          section.set_slot(3, {
            value = {
              type = "virtual",
              name = "signal-utilization",
              quality = "normal"
            },
            min = metrics.utilization or 0
          })

          section.set_slot(4, {
            value = {
              type = "virtual",
              name = "signal-monitored-count",
              quality = "normal"
            },
            min = metrics.monitored_count or 0
          })

          section.set_slot(5, {
            value = {
              type = "virtual",
              name = "signal-data-backlog",
              quality = "normal"
            },
            min = metrics.data_backlog or 0
          })

          section.set_slot(6, {
            value = {
              type = "virtual",
              name = "signal-technical-debt",
              quality = "normal"
            },
            min = math.floor((storage.technical_debt or {}).total or 0)
          })
        end
      end
    else
      -- Clean up invalid bridges
      storage.circuit_bridges[unit_number] = nil
    end
  end

  -- Update per-sensor metrics on sensor circuit interfaces
  CircuitInterface.update_sensor_signals()
end

-- Update per-sensor circuit signals on sensor interfaces
function CircuitInterface.update_sensor_signals()
  if not storage.sensor_interfaces then return end

  for sensor_unit_number, interface_data in pairs(storage.sensor_interfaces) do
    local interface = interface_data.entity
    if interface and interface.valid then
      -- Get the sensor data for this interface
      local sensor_data = storage.sensors[sensor_unit_number]
      if sensor_data and sensor_data.entity and sensor_data.entity.valid then
        -- Calculate per-sensor metrics
        local sensor_id = sensor_data.sensor_id or 0
        local monitored_count = table_size(sensor_data.monitored_assemblers or {})
        local data_rate = sensor_data.last_tick_data or 0

        -- Calculate sensor backlog (packets in sensor inventory)
        local backlog = 0
        local inventory = sensor_data.entity.get_inventory(defines.inventory.chest)
        if inventory then
          backlog = inventory.get_item_count("data-packet")
        end

        -- Get the combinator's control behavior
        local control = interface.get_or_create_control_behavior()
        if control then
          local section = control.get_section(1)
          if section then
            -- Clear existing signals
            for i = 1, section.filters_count do
              section.clear_slot(i)
            end

            -- Set per-sensor signals
            section.set_slot(1, {
              value = {
                type = "virtual",
                name = "signal-sensor-id",
                quality = "normal"
              },
              min = sensor_id
            })

            section.set_slot(2, {
              value = {
                type = "virtual",
                name = "signal-sensor-entities",
                quality = "normal"
              },
              min = monitored_count
            })

            section.set_slot(3, {
              value = {
                type = "virtual",
                name = "signal-sensor-backlog",
                quality = "normal"
              },
              min = backlog
            })

            section.set_slot(4, {
              value = {
                type = "virtual",
                name = "signal-sensor-data-rate",
                quality = "normal"
              },
              min = data_rate
            })
          end
        end
      end
    else
      -- Clean up invalid interfaces
      storage.sensor_interfaces[sensor_unit_number] = nil
    end
  end
end

-- Read circuit network conditions - called every 10 ticks
function CircuitInterface.read_circuit_conditions()
  for unit_number, bridge_data in pairs(storage.circuit_bridges) do
    local bridge = bridge_data.entity
    if bridge and bridge.valid then
      local emergency_stop = false
      local resume = false

      -- Check red wire network
      local red_network = bridge.get_circuit_network(defines.wire_type.red)
      if red_network then
        local red_signal = red_network.get_signal({type = "virtual", name = "signal-red"})
        local green_signal = red_network.get_signal({type = "virtual", name = "signal-green"})

        if red_signal and red_signal > 0 then
          emergency_stop = true
        end
        if green_signal and green_signal > 0 then
          resume = true
        end
      end

      -- Check green wire network
      local green_network = bridge.get_circuit_network(defines.wire_type.green)
      if green_network then
        local red_signal = green_network.get_signal({type = "virtual", name = "signal-red"})
        local green_signal = green_network.get_signal({type = "virtual", name = "signal-green"})

        if red_signal and red_signal > 0 then
          emergency_stop = true
        end
        if green_signal and green_signal > 0 then
          resume = true
        end
      end

      -- Process emergency stop/resume
      -- Resume takes precedence over stop if both are present
      if resume then
        if storage.emergency_stop then
          DataSystem.set_emergency_stop(false)
          -- Notify circuit control of emergency stop change
          get_circuit_control().on_emergency_stop_changed()
        end
      elseif emergency_stop then
        if not storage.emergency_stop then
          DataSystem.set_emergency_stop(true)
          -- Notify circuit control of emergency stop change
          get_circuit_control().on_emergency_stop_changed()
        end
      end
    end
  end
end

return CircuitInterface
