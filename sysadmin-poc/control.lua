-- Sysadmin POC - Control Phase
-- Runtime logic for data collection, processing, and circuit integration

local DataSystem = require("scripts.data-system")
local CircuitInterface = require("scripts.circuit-interface")
local CircuitControl = require("scripts.circuit-control")
local TechnicalDebt = require("scripts.technical-debt")
local Dashboard = require("gui.dashboard")
local Indicators = require("scripts.indicators")
local Alerts = require("scripts.alerts")

-- Initialize storage tables on new game
script.on_init(function()
  storage.sensors = {}
  storage.servers = {}
  storage.cables = {}  -- Track all network cables for item filtering
  storage.dashboards = {}  -- Track dashboard terminals for the IT coverage bonus tier
  storage.circuit_bridges = {}
  storage.monitored_assemblers = {}
  storage.sensor_interfaces = {}  -- Per-sensor circuit output entities
  storage.next_sensor_id = 1      -- Incrementing sensor ID counter
  storage.metrics = {
    total_throughput = 0,
    data_rate = 0,
    utilization = 0,
    monitored_count = 0,
    data_backlog = 0,
    total_processed = 0
  }
  storage.emergency_stop = false
  Indicators.init()
  Alerts.init()
  CircuitControl.init()
  TechnicalDebt.init()
end)

-- Handle save migration
script.on_configuration_changed(function(data)
  storage.sensors = storage.sensors or {}
  storage.servers = storage.servers or {}
  storage.circuit_bridges = storage.circuit_bridges or {}
  storage.monitored_assemblers = storage.monitored_assemblers or {}
  storage.sensor_interfaces = storage.sensor_interfaces or {}
  storage.next_sensor_id = storage.next_sensor_id or 1
  storage.metrics = storage.metrics or {
    total_throughput = 0,
    data_rate = 0,
    utilization = 0,
    monitored_count = 0,
    data_backlog = 0,
    total_processed = 0
  }
  storage.emergency_stop = storage.emergency_stop or false
  Indicators.init()
  Alerts.init()
  CircuitControl.init()
  TechnicalDebt.init()

  -- Migration: Create circuit interfaces for existing sensors that don't have them
  for sensor_unit_number, sensor_data in pairs(storage.sensors) do
    if sensor_data.entity and sensor_data.entity.valid then
      if not sensor_data.sensor_id then
        -- Assign sensor ID if missing
        sensor_data.sensor_id = storage.next_sensor_id
        storage.next_sensor_id = storage.next_sensor_id + 1
      end
      if not storage.sensor_interfaces[sensor_unit_number] then
        -- Create circuit interface for existing sensor
        local interface = sensor_data.entity.surface.create_entity{
          name = "sensor-circuit-interface",
          position = sensor_data.entity.position,
          force = sensor_data.entity.force,
          create_build_effect_smoke = false
        }
        if interface then
          storage.sensor_interfaces[sensor_unit_number] = {
            entity = interface,
            sensor_id = sensor_data.sensor_id
          }
        end
      end
    end
  end

  -- Migration: Track all existing network cables for item filtering
  -- This ensures no non-data-packet items can stay on any cable
  storage.cables = storage.cables or {}
  local cable_names = {"network-cable", "network-cable-underground", "network-cable-splitter"}
  for _, surface in pairs(game.surfaces) do
    local cables = surface.find_entities_filtered{name = cable_names}
    for _, cable in pairs(cables) do
      if cable.valid and not storage.cables[cable.unit_number] then
        storage.cables[cable.unit_number] = {
          entity = cable
        }
      end
    end
  end
end)

-- Entity built events
local function on_entity_built(event)
  local entity = event.entity or event.created_entity
  if not entity or not entity.valid then return end

  DataSystem.on_entity_built(entity)
  CircuitInterface.on_entity_built(entity)
end

script.on_event(defines.events.on_built_entity, on_entity_built)
script.on_event(defines.events.on_robot_built_entity, on_entity_built)
script.on_event(defines.events.script_raised_built, on_entity_built)
script.on_event(defines.events.script_raised_revive, on_entity_built)

-- Entity removed events
local function on_entity_removed(event)
  local entity = event.entity
  if not entity or not entity.valid then return end

  -- Clean up circuit control state for sensors
  if entity.name == "data-sensor" then
    CircuitControl.on_sensor_removed(entity.unit_number)
  end

  DataSystem.on_entity_removed(entity)
  CircuitInterface.on_entity_removed(entity)
end

script.on_event(defines.events.on_player_mined_entity, on_entity_removed)
script.on_event(defines.events.on_robot_mined_entity, on_entity_removed)
script.on_event(defines.events.on_entity_died, on_entity_removed)
script.on_event(defines.events.script_raised_destroy, on_entity_removed)

-- Main tick handler - every 60 ticks (1 second)
script.on_nth_tick(60, function(event)
  DataSystem.tick()
  TechnicalDebt.tick()
  CircuitInterface.update_signals()
  Dashboard.update_all()
  Indicators.update_all()
  Alerts.tick()
end)

-- Fast tick handler - every 2 ticks for auto-transfer
-- At belt speed 1.0, items move 1 tile/tick, so we need frequent checks
-- Moves data packets: sensor → cable, cable → server (no inserters needed)
script.on_nth_tick(2, function(event)
  DataSystem.auto_transfer()
end)

-- Circuit condition reading - every 10 ticks
-- Reads circuit signals from sensors and circuit bridges
script.on_nth_tick(10, function(event)
  CircuitControl.update()  -- Read sensor control signals and apply to assemblers
  CircuitInterface.read_circuit_conditions()  -- Read bridge emergency stop signals
end)

-- Slow maintenance tasks - every 600 ticks (10 seconds)
script.on_nth_tick(600, function(event)
  Indicators.cleanup_radius_indicators()  -- Clean up orphaned radius indicators
end)

-- GUI: Open dashboard when clicking dashboard terminal
script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  if entity and entity.valid and entity.name == "dashboard-terminal" then
    local player = game.players[event.player_index]
    -- Close the default GUI and open our custom one
    player.opened = nil
    Dashboard.create(player)
  end
end)

-- GUI: Handle clicks
script.on_event(defines.events.on_gui_click, function(event)
  Dashboard.on_gui_click(event)
end)

-- Entity selection: Show radius indicator for sensors
script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index)
  if player then
    -- Get the player's currently selected entity (not last_entity which is the deselected one)
    local selected = player.selected
    Indicators.on_selected_entity_changed(event.player_index, selected)
  end
end)

-- Debug commands
commands.add_command("sysadmin-stats", "Show IT infrastructure stats", function(cmd)
  local player = game.players[cmd.player_index]
  if not player then return end

  local metrics = storage.metrics or {}
  player.print("=== Sysadmin POC Stats ===")
  player.print("Sensors: " .. table_size(storage.sensors or {}))
  player.print("Servers: " .. table_size(storage.servers or {}))
  player.print("Bridges: " .. table_size(storage.circuit_bridges or {}))
  player.print("Monitored Assemblers: " .. (metrics.monitored_count or 0))
  player.print("Throughput: " .. (metrics.total_throughput or 0) .. " items/sec")
  player.print("Data Rate: " .. (metrics.data_rate or 0) .. " packets/sec")
  player.print("Utilization: " .. (metrics.utilization or 0) .. "%")
  player.print("Data Backlog: " .. (metrics.data_backlog or 0))
  player.print("Total Processed: " .. (metrics.total_processed or 0))
  player.print("Emergency Stop: " .. tostring(storage.emergency_stop or false))
end)

commands.add_command("sysadmin-transfer", "Debug auto-transfer system", function(cmd)
  local player = game.players[cmd.player_index]
  if not player then return end

  player.print("=== Auto-Transfer Debug ===")

  -- Check sensors
  for sensor_id, sensor_data in pairs(storage.sensors or {}) do
    if sensor_data.entity and sensor_data.entity.valid then
      local inv = sensor_data.entity.get_inventory(defines.inventory.chest)
      local packets = inv and inv.get_item_count("data-packet") or 0
      player.print("Sensor #" .. sensor_id .. " at " .. serpent.line(sensor_data.entity.position) .. " has " .. packets .. " packets")

      -- Check for nearby cables
      local pos = sensor_data.entity.position
      local cables = sensor_data.entity.surface.find_entities_filtered{
        area = {{pos.x - 1.5, pos.y - 1.5}, {pos.x + 1.5, pos.y + 1.5}},
        name = {"network-cable", "network-cable-underground", "network-cable-splitter"}
      }
      player.print("  Found " .. #cables .. " nearby cables")
    end
  end

  -- Check servers
  for server_id, server_data in pairs(storage.servers or {}) do
    if server_data.entity and server_data.entity.valid then
      local inv = server_data.entity.get_inventory(defines.inventory.assembling_machine_input)
      local packets = inv and inv.get_item_count("data-packet") or 0
      local can_insert = inv and inv.can_insert({name = "data-packet", count = 1}) or false
      player.print("Server #" .. server_id .. " at " .. serpent.line(server_data.entity.position) .. " has " .. packets .. " packets (can_insert: " .. tostring(can_insert) .. ")")

      -- Check for nearby cables
      local pos = server_data.entity.position
      local cables = server_data.entity.surface.find_entities_filtered{
        area = {{pos.x - 1.5, pos.y - 1.5}, {pos.x + 1.5, pos.y + 1.5}},
        name = {"network-cable", "network-cable-underground", "network-cable-splitter"}
      }
      player.print("  Found " .. #cables .. " nearby cables")
      for _, cable in pairs(cables) do
        local line1 = cable.get_transport_line(1)
        local line2 = cable.get_transport_line(2)
        local count1 = line1 and line1.get_item_count("data-packet") or 0
        local count2 = line2 and line2.get_item_count("data-packet") or 0
        player.print("    Cable at " .. serpent.line(cable.position) .. " line1=" .. count1 .. " line2=" .. count2)
      end
    end
  end

  -- Force one transfer cycle
  player.print("Running manual transfer cycle...")
  DataSystem.auto_transfer()
  player.print("Done.")
end)

commands.add_command("sysadmin-circuit", "Show circuit bridge readings", function(cmd)
  local player = game.players[cmd.player_index]
  if not player then return end

  player.print("=== Circuit Bridge Readings ===")
  for unit_number, bridge_data in pairs(storage.circuit_bridges or {}) do
    if bridge_data.entity and bridge_data.entity.valid then
      player.print("Bridge #" .. unit_number .. " at " .. serpent.line(bridge_data.entity.position))
      local red = bridge_data.entity.get_circuit_network(defines.wire_type.red)
      local green = bridge_data.entity.get_circuit_network(defines.wire_type.green)
      if red then
        player.print("  Red network signals: " .. (red.signals and #red.signals or 0))
      end
      if green then
        player.print("  Green network signals: " .. (green.signals and #green.signals or 0))
      end
    end
  end
end)

commands.add_command("sysadmin-sensors", "Show per-sensor circuit signals", function(cmd)
  local player = game.players[cmd.player_index]
  if not player then return end

  player.print("=== Per-Sensor Circuit Signals ===")
  player.print("Next Sensor ID: " .. (storage.next_sensor_id or 1))

  for sensor_unit_number, sensor_data in pairs(storage.sensors or {}) do
    if sensor_data.entity and sensor_data.entity.valid then
      local pos = sensor_data.entity.position
      local sensor_id = sensor_data.sensor_id or 0
      local monitored_count = table_size(sensor_data.monitored_assemblers or {})
      local data_rate = sensor_data.last_tick_data or 0
      local total_data = sensor_data.data_generated or 0

      -- Get backlog from inventory
      local backlog = 0
      local inventory = sensor_data.entity.get_inventory(defines.inventory.chest)
      if inventory then
        backlog = inventory.get_item_count("data-packet")
      end

      player.print("Sensor #" .. sensor_id .. " (unit: " .. sensor_unit_number .. ") at " .. serpent.line(pos))
      player.print("  Entities: " .. monitored_count)
      player.print("  Backlog: " .. backlog)
      player.print("  Data Rate (last tick): " .. data_rate)
      player.print("  Total Data Generated: " .. total_data)

      -- Check circuit interface
      local interface_data = storage.sensor_interfaces and storage.sensor_interfaces[sensor_unit_number]
      if interface_data and interface_data.entity and interface_data.entity.valid then
        player.print("  Circuit Interface: OK")
        local red = interface_data.entity.get_circuit_network(defines.wire_type.red)
        local green = interface_data.entity.get_circuit_network(defines.wire_type.green)
        player.print("    Wired: Red=" .. tostring(red ~= nil) .. ", Green=" .. tostring(green ~= nil))
      else
        player.print("  Circuit Interface: MISSING")
      end
    end
  end
end)

commands.add_command("sysadmin-control", "Show sensor circuit control state", function(cmd)
  local player = game.players[cmd.player_index]
  if not player then return end

  player.print("=== Sensor Circuit Control ===")
  player.print("Global Emergency Stop: " .. tostring(storage.emergency_stop or false))

  for sensor_id, sensor_data in pairs(storage.sensors or {}) do
    if sensor_data.entity and sensor_data.entity.valid then
      local state = CircuitControl.get_sensor_state(sensor_id)
      local pos = sensor_data.entity.position
      player.print("Sensor #" .. sensor_id .. " at " .. serpent.line(pos))
      player.print("  Control State: " .. (state.state or "normal"))
      player.print("  Signal Value: " .. (state.signal_value or 0))

      -- Check wire connections
      local red = sensor_data.entity.get_circuit_network(defines.wire_type.red)
      local green = sensor_data.entity.get_circuit_network(defines.wire_type.green)
      local has_red = red and true or false
      local has_green = green and true or false
      player.print("  Wires: Red=" .. tostring(has_red) .. ", Green=" .. tostring(has_green))

      -- Show controlled assemblers
      local assembler_count = 0
      if sensor_data.monitored_assemblers then
        for assembler_id, _ in pairs(sensor_data.monitored_assemblers) do
          local assembler_data = storage.monitored_assemblers[assembler_id]
          if assembler_data and assembler_data.entity and assembler_data.entity.valid then
            assembler_count = assembler_count + 1
            local display_state = CircuitControl.get_assembler_display_state(assembler_id)
            local active = assembler_data.entity.active and "yes" or "no"
            player.print("    Assembler #" .. assembler_id .. ": state=" .. display_state .. ", active=" .. active)
          end
        end
      end
      player.print("  Monitored Assemblers: " .. assembler_count)
    end
  end
end)
