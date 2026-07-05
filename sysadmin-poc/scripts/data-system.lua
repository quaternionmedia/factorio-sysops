-- Sysadmin POC - Data System
-- Handles data generation, collection, and monitoring

local DataSystem = {}

-- Configuration
local SENSOR_RANGE_DEFAULT = 5 -- tiles in each direction (overridden by runtime setting)

-- Get the sensor range from runtime settings, falling back to default
local function get_sensor_range()
  if settings and settings.global and settings.global["sysadmin-sensor-range"] then
    return settings.global["sysadmin-sensor-range"].value
  end
  return SENSOR_RANGE_DEFAULT
end

-- Backlog thresholds for alerts/display
local BACKLOG_WARNING = 100
local BACKLOG_CRITICAL = 500
local BACKLOG_SEVERE = 1000

-- Server entity names (all tiers process data packets)
local SERVER_NAMES = {
  ["basic-server"] = true,
  ["advanced-server"] = true,
  ["hp-server"] = true
}

-- Network cable entity names
local CABLE_NAMES = {
  ["network-cable"] = true,
  ["network-cable-underground"] = true,
  ["network-cable-splitter"] = true
}

-- Helper to check if an entity is a server
local function is_server(entity)
  return SERVER_NAMES[entity.name] == true
end

-- Helper to check if an entity is a network cable
local function is_cable(entity)
  return CABLE_NAMES[entity.name] == true
end

-- Register a network cable for tracking (so we can filter ALL cables)
local function register_cable(cable)
  storage.cables = storage.cables or {}
  storage.cables[cable.unit_number] = {
    entity = cable
  }
end

-- Unregister a network cable
local function unregister_cable(cable)
  if storage.cables then
    storage.cables[cable.unit_number] = nil
  end
end

-- Track sensor placement and find nearby assemblers
function DataSystem.on_entity_built(entity)
  if entity.name == "data-sensor" then
    DataSystem.register_sensor(entity)
  elseif is_server(entity) then
    DataSystem.register_server(entity)
  elseif is_cable(entity) then
    -- Track cable so we can filter items on ALL cables
    register_cable(entity)
  elseif entity.type == "assembling-machine" and not is_server(entity) then
    -- Check if any existing sensor covers this assembler
    DataSystem.check_assembler_coverage(entity)
  end
end

-- Handle entity removal
function DataSystem.on_entity_removed(entity)
  if entity.name == "data-sensor" then
    DataSystem.unregister_sensor(entity)
  elseif is_server(entity) then
    DataSystem.unregister_server(entity)
  elseif is_cable(entity) then
    unregister_cable(entity)
  elseif entity.type == "assembling-machine" and not is_server(entity) then
    DataSystem.unregister_assembler(entity)
  end
end

-- Register a new sensor and find assemblers in range
function DataSystem.register_sensor(sensor)
  local unit_number = sensor.unit_number

  -- Assign a unique sensor ID (human-readable, incrementing)
  local sensor_id = storage.next_sensor_id or 1
  storage.next_sensor_id = sensor_id + 1

  storage.sensors[unit_number] = {
    entity = sensor,
    monitored_assemblers = {},
    throughput = 0,
    data_generated = 0,
    last_tick_data = 0,     -- Data generated in last tick (for rate calculation)
    sensor_id = sensor_id   -- Human-readable sensor ID
  }

  -- Create the hidden circuit interface for per-sensor signal output
  local interface = sensor.surface.create_entity{
    name = "sensor-circuit-interface",
    position = sensor.position,
    force = sensor.force,
    create_build_effect_smoke = false
  }
  if interface then
    storage.sensor_interfaces = storage.sensor_interfaces or {}
    storage.sensor_interfaces[unit_number] = {
      entity = interface,
      sensor_id = sensor_id
    }
  end

  -- Find all assemblers in range
  local surface = sensor.surface
  local position = sensor.position
  local range = get_sensor_range()
  local area = {
    {position.x - range, position.y - range},
    {position.x + range, position.y + range}
  }

  local assemblers = surface.find_entities_filtered{
    area = area,
    type = "assembling-machine"
  }

  for _, assembler in pairs(assemblers) do
    if not is_server(assembler) then
      DataSystem.link_assembler_to_sensor(assembler, unit_number)
    end
  end

  -- Update metrics
  DataSystem.update_metrics()
end

-- Unregister a sensor and clean up linked assemblers
function DataSystem.unregister_sensor(sensor)
  local unit_number = sensor.unit_number
  local sensor_data = storage.sensors[unit_number]

  if sensor_data then
    -- Clean up linked assemblers
    for assembler_id, _ in pairs(sensor_data.monitored_assemblers) do
      storage.monitored_assemblers[assembler_id] = nil
    end
  end

  -- Destroy the associated circuit interface
  if storage.sensor_interfaces and storage.sensor_interfaces[unit_number] then
    local interface_data = storage.sensor_interfaces[unit_number]
    if interface_data.entity and interface_data.entity.valid then
      interface_data.entity.destroy()
    end
    storage.sensor_interfaces[unit_number] = nil
  end

  storage.sensors[unit_number] = nil
  DataSystem.update_metrics()
end

-- Register a server
function DataSystem.register_server(server)
  storage.servers[server.unit_number] = {
    entity = server,
    utilization = 0,
    packets_processed = 0
  }
  DataSystem.update_metrics()
end

-- Unregister a server
function DataSystem.unregister_server(server)
  storage.servers[server.unit_number] = nil
  DataSystem.update_metrics()
end

-- Link an assembler to a sensor
function DataSystem.link_assembler_to_sensor(assembler, sensor_id)
  local assembler_id = assembler.unit_number

  -- Skip if already monitored
  if storage.monitored_assemblers[assembler_id] then
    return
  end

  storage.monitored_assemblers[assembler_id] = {
    entity = assembler,
    sensor_id = sensor_id,
    last_products_finished = assembler.products_finished or 0
  }

  -- Add to sensor's list
  if storage.sensors[sensor_id] then
    storage.sensors[sensor_id].monitored_assemblers[assembler_id] = true
  end
end

-- Check if a newly placed assembler is covered by any sensor
function DataSystem.check_assembler_coverage(assembler)
  local position = assembler.position
  local surface = assembler.surface

  for sensor_id, sensor_data in pairs(storage.sensors) do
    if sensor_data.entity and sensor_data.entity.valid then
      local sensor_pos = sensor_data.entity.position
      local dx = math.abs(position.x - sensor_pos.x)
      local dy = math.abs(position.y - sensor_pos.y)
      local range = get_sensor_range()

      if dx <= range and dy <= range then
        DataSystem.link_assembler_to_sensor(assembler, sensor_id)
        return
      end
    end
  end
end

-- Unregister an assembler
function DataSystem.unregister_assembler(assembler)
  local assembler_id = assembler.unit_number
  local assembler_data = storage.monitored_assemblers[assembler_id]

  if assembler_data then
    -- Remove from sensor's list
    local sensor_id = assembler_data.sensor_id
    if storage.sensors[sensor_id] then
      storage.sensors[sensor_id].monitored_assemblers[assembler_id] = nil
    end
  end

  storage.monitored_assemblers[assembler_id] = nil
  DataSystem.update_metrics()
end

-- Main tick function - called every 60 ticks
function DataSystem.tick()
  local total_throughput = 0
  local data_generated = 0

  -- Reset per-sensor tick data (for rate calculation)
  for sensor_unit_number, sensor_data in pairs(storage.sensors) do
    sensor_data.last_tick_data = 0
  end

  -- Check each monitored assembler for completed products
  for assembler_id, data in pairs(storage.monitored_assemblers) do
    if data.entity and data.entity.valid then
      local current_products = data.entity.products_finished or 0
      local products_delta = current_products - data.last_products_finished
      data.last_products_finished = current_products

      if products_delta > 0 then
        total_throughput = total_throughput + products_delta

        -- Generate data packets in sensor inventory
        local sensor_id = data.sensor_id
        if storage.sensors[sensor_id] then
          local sensor = storage.sensors[sensor_id].entity
          if sensor and sensor.valid then
            local inventory = sensor.get_inventory(defines.inventory.chest)
            if inventory then
              local inserted = inventory.insert({name = "data-packet", count = products_delta})
              data_generated = data_generated + inserted
              storage.sensors[sensor_id].data_generated =
                (storage.sensors[sensor_id].data_generated or 0) + inserted
              -- Track per-sensor data rate for this tick
              storage.sensors[sensor_id].last_tick_data =
                (storage.sensors[sensor_id].last_tick_data or 0) + inserted
            end
          end
        end
      end
    else
      -- Clean up invalid assemblers
      storage.monitored_assemblers[assembler_id] = nil
    end
  end

  -- Calculate server utilization and backlog
  local total_backlog = 0
  local active_servers = 0

  for sensor_id, sensor_data in pairs(storage.sensors) do
    if sensor_data.entity and sensor_data.entity.valid then
      local inventory = sensor_data.entity.get_inventory(defines.inventory.chest)
      if inventory then
        local count = inventory.get_item_count("data-packet")
        total_backlog = total_backlog + count
      end
    end
  end

  for server_id, server_data in pairs(storage.servers) do
    if server_data.entity and server_data.entity.valid then
      active_servers = active_servers + 1

      -- Check if server is crafting (processing data)
      if server_data.entity.is_crafting() then
        server_data.utilization = 100
      else
        server_data.utilization = 0
      end
    end
  end

  -- Calculate overall utilization
  local utilization = 0
  if active_servers > 0 then
    local total_utilization = 0
    for _, server_data in pairs(storage.servers) do
      total_utilization = total_utilization + server_data.utilization
    end
    utilization = math.floor(total_utilization / active_servers)
  end

  -- Update storage metrics
  storage.metrics.total_throughput = total_throughput
  storage.metrics.data_rate = data_generated
  storage.metrics.utilization = utilization
  storage.metrics.data_backlog = total_backlog
  storage.metrics.monitored_count = table_size(storage.monitored_assemblers)
  storage.metrics.total_processed = (storage.metrics.total_processed or 0) + data_generated
end

-- Update metric counts
function DataSystem.update_metrics()
  storage.metrics.monitored_count = table_size(storage.monitored_assemblers)
end

-- Get metrics for a specific sensor
function DataSystem.get_sensor_metrics(sensor)
  local unit_number = sensor.unit_number
  local sensor_data = storage.sensors[unit_number]
  if not sensor_data then return nil end

  return {
    monitored_count = table_size(sensor_data.monitored_assemblers),
    throughput = sensor_data.throughput or 0,
    data_generated = sensor_data.data_generated or 0
  }
end

-- Get storage metrics
function DataSystem.get_storage_metrics()
  return storage.metrics
end

-- Emergency stop control
function DataSystem.set_emergency_stop(stop)
  storage.emergency_stop = stop
end

-- Get current backlog status for display
function DataSystem.get_backlog_status()
  local backlog = storage.metrics.data_backlog or 0
  if backlog >= BACKLOG_SEVERE then
    return "severe", "SEVERE: Backlog critical!"
  elseif backlog >= BACKLOG_CRITICAL then
    return "critical", "CRITICAL: Backlog growing fast"
  elseif backlog >= BACKLOG_WARNING then
    return "warning", "WARNING: Backlog accumulating"
  else
    return "normal", "Normal operation"
  end
end

-- Find entities of specific types within a radius of an entity
-- Uses area search which is more reliable than point-based search
local function find_nearby_entities(entity, names, radius)
  local surface = entity.surface
  local pos = entity.position
  radius = radius or 1.5  -- Default to slightly more than 1 tile

  -- Convert single name to table for uniform handling
  local name_filter = names
  if type(names) == "string" then
    name_filter = {names}
  end

  local area = {
    {pos.x - radius, pos.y - radius},
    {pos.x + radius, pos.y + radius}
  }

  local entities = surface.find_entities_filtered{
    area = area,
    name = name_filter
  }

  -- Filter out the entity itself if it somehow matches
  local results = {}
  for _, found in pairs(entities) do
    if found.unit_number ~= entity.unit_number then
      table.insert(results, found)
    end
  end

  return results
end

-- All network cable entity types
local NETWORK_CABLE_TYPES = {"network-cable", "network-cable-underground", "network-cable-splitter"}

-- Items allowed on network cables (only data packets)
local ALLOWED_CABLE_ITEMS = {["data-packet"] = true}

-- Helper to remove disallowed items from a transport line
-- Strategy: Count data-packets, clear line, re-insert data-packets, spill the rest
local function remove_disallowed_from_line(line, cable)
  if not line then return end

  -- First pass: collect what's on the line
  local data_packet_count = 0
  local items_to_spill = {}

  for i = 1, #line do
    local stack = line[i]
    if stack and stack.valid_for_read then
      if stack.name == "data-packet" then
        data_packet_count = data_packet_count + stack.count
      else
        -- Collect non-allowed items to spill
        local quality_name = "normal"
        if stack.quality and stack.quality.name then
          quality_name = stack.quality.name
        end
        table.insert(items_to_spill, {name = stack.name, count = stack.count, quality = quality_name})
      end
    end
  end

  -- If there are items to remove, clear and rebuild
  if #items_to_spill > 0 then
    -- Clear the entire line
    line.clear()

    -- Re-insert data-packets
    for i = 1, data_packet_count do
      if line.can_insert_at_back() then
        line.insert_at_back({name = "data-packet", count = 1})
      end
    end

    -- Spill removed items to ground
    for _, item in pairs(items_to_spill) do
      cable.surface.spill_item_stack{
        position = cable.position,
        stack = item,
        enable_looted = true
      }
    end
  end
end

-- Auto-transfer: Move data packets from sensors to cables, and from cables to servers
-- Called every 2 ticks for responsive data flow
local TRANSFER_RATE = 4  -- Items per entity per tick
local cable_filter_counter = 0
local CABLE_FILTER_INTERVAL = 15  -- Filter cables every 15 auto-transfer cycles (30 ticks)

function DataSystem.auto_transfer()
  -- Periodically clean all tracked cables to remove non-data-packet items
  -- Throttled to every ~30 ticks to reduce overhead on large networks
  cable_filter_counter = cable_filter_counter + 1
  if cable_filter_counter >= CABLE_FILTER_INTERVAL and storage.cables then
    cable_filter_counter = 0
    for unit_number, cable_data in pairs(storage.cables) do
      local cable = cable_data.entity
      if cable and cable.valid then
        local line1 = cable.get_transport_line(1)
        local line2 = cable.get_transport_line(2)
        remove_disallowed_from_line(line1, cable)
        remove_disallowed_from_line(line2, cable)
      else
        -- Clean up invalid cables
        storage.cables[unit_number] = nil
      end
    end
  end

  -- Sensor → Network Cable
  for sensor_id, sensor_data in pairs(storage.sensors) do
    local sensor = sensor_data.entity
    if sensor and sensor.valid then
      local inventory = sensor.get_inventory(defines.inventory.chest)
      if inventory then
        local packet_count = inventory.get_item_count("data-packet")
        if packet_count > 0 then
          -- Find nearby network cables (any type)
          local cables = find_nearby_entities(sensor, NETWORK_CABLE_TYPES, 1.5)
          local transferred = 0
          for _, cable in pairs(cables) do
            if cable.valid and transferred < TRANSFER_RATE then
              -- Get the belt's transport lines
              local line1 = cable.get_transport_line(1)
              local line2 = cable.get_transport_line(2)

              -- Try to insert on line 1 first, then line 2
              if line1 and line1.can_insert_at_back() then
                if line1.insert_at_back({name = "data-packet", count = 1}) then
                  inventory.remove({name = "data-packet", count = 1})
                  transferred = transferred + 1
                end
              end
              if transferred < TRANSFER_RATE and line2 and line2.can_insert_at_back() then
                if line2.insert_at_back({name = "data-packet", count = 1}) then
                  inventory.remove({name = "data-packet", count = 1})
                  transferred = transferred + 1
                end
              end
            end
          end
        end
      end
    end
  end

  -- Network Cable → Server
  for server_id, server_data in pairs(storage.servers) do
    local server = server_data.entity
    if server and server.valid then
      -- Find nearby network cables (any type)
      local cables = find_nearby_entities(server, NETWORK_CABLE_TYPES, 1.5)
      local transferred = 0

      -- Get server's input inventory once
      local server_input = server.get_inventory(defines.inventory.assembling_machine_input)
      if not server_input then goto continue_server end

      for _, cable in pairs(cables) do
        if cable.valid and transferred < TRANSFER_RATE then
          local line1 = cable.get_transport_line(1)
          local line2 = cable.get_transport_line(2)

          -- Transfer from line 1
          if line1 and transferred < TRANSFER_RATE then
            local item_count = line1.get_item_count("data-packet")
            while item_count > 0 and transferred < TRANSFER_RATE do
              if server_input.can_insert({name = "data-packet", count = 1}) then
                if line1.remove_item({name = "data-packet", count = 1}) > 0 then
                  server_input.insert({name = "data-packet", count = 1})
                  transferred = transferred + 1
                  item_count = item_count - 1
                else
                  break
                end
              else
                break  -- Server input full
              end
            end
          end

          -- Transfer from line 2
          if line2 and transferred < TRANSFER_RATE then
            local item_count = line2.get_item_count("data-packet")
            while item_count > 0 and transferred < TRANSFER_RATE do
              if server_input.can_insert({name = "data-packet", count = 1}) then
                if line2.remove_item({name = "data-packet", count = 1}) > 0 then
                  server_input.insert({name = "data-packet", count = 1})
                  transferred = transferred + 1
                  item_count = item_count - 1
                else
                  break
                end
              else
                break  -- Server input full
              end
            end
          end
        end
      end

      ::continue_server::
    end
  end
end

return DataSystem
