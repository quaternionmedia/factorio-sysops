-- Sysadmin POC - Virtual Signal Definitions

data:extend({
  -- Subgroup for sysadmin signals
  {
    type = "item-subgroup",
    name = "sysadmin-signals",
    group = "signals",
    order = "z[sysadmin]"
  },

  -- Signal: Throughput - items per second monitored
  {
    type = "virtual-signal",
    name = "signal-throughput",
    icon = "__sysadmin-poc__/graphics/icons/signals/signal-throughput.png",
    icon_size = 32,
    subgroup = "sysadmin-signals",
    order = "a[throughput]"
  },

  -- Signal: Data Rate - packets per second generated
  {
    type = "virtual-signal",
    name = "signal-data-rate",
    icon = "__sysadmin-poc__/graphics/icons/signals/signal-data-rate.png",
    icon_size = 32,
    subgroup = "sysadmin-signals",
    order = "b[data-rate]"
  },

  -- Signal: Utilization - server load percentage
  {
    type = "virtual-signal",
    name = "signal-utilization",
    icon = "__sysadmin-poc__/graphics/icons/signals/signal-utilization.png",
    icon_size = 32,
    subgroup = "sysadmin-signals",
    order = "c[utilization]"
  },

  -- Signal: Monitored Count - number of assemblers being tracked
  {
    type = "virtual-signal",
    name = "signal-monitored-count",
    icon = "__sysadmin-poc__/graphics/icons/signals/signal-monitored-count.png",
    icon_size = 32,
    subgroup = "sysadmin-signals",
    order = "d[monitored-count]"
  },

  -- Signal: Data Backlog - unprocessed packets
  {
    type = "virtual-signal",
    name = "signal-data-backlog",
    icon = "__sysadmin-poc__/graphics/icons/signals/signal-data-backlog.png",
    icon_size = 32,
    subgroup = "sysadmin-signals",
    order = "e[data-backlog]"
  },

  -- Signal: IT Control - enable/disable monitored entities via circuit
  -- Positive value = enable, Negative value = disable, Zero = no override
  {
    type = "virtual-signal",
    name = "signal-it-control",
    icon = "__sysadmin-poc__/graphics/icons/signals/signal-it-control.png",
    icon_size = 32,
    subgroup = "sysadmin-signals",
    order = "f[it-control]"
  },

  -- Per-sensor signals for granular circuit control
  -- Signal: Sensor ID - unique identifier for each sensor (1, 2, 3, ...)
  {
    type = "virtual-signal",
    name = "signal-sensor-id",
    icon = "__sysadmin-poc__/graphics/icons/signals/signal-sensor-id.png",
    icon_size = 32,
    subgroup = "sysadmin-signals",
    order = "g[sensor-id]"
  },

  -- Signal: Sensor Entities - number of assemblers monitored by this sensor
  {
    type = "virtual-signal",
    name = "signal-sensor-entities",
    icon = "__sysadmin-poc__/graphics/icons/signals/signal-sensor-entities.png",
    icon_size = 32,
    subgroup = "sysadmin-signals",
    order = "h[sensor-entities]"
  },

  -- Signal: Sensor Backlog - data packets waiting in this sensor's inventory
  {
    type = "virtual-signal",
    name = "signal-sensor-backlog",
    icon = "__sysadmin-poc__/graphics/icons/signals/signal-sensor-backlog.png",
    icon_size = 32,
    subgroup = "sysadmin-signals",
    order = "i[sensor-backlog]"
  },

  -- Signal: Sensor Data Rate - packets generated per tick by this sensor
  {
    type = "virtual-signal",
    name = "signal-sensor-data-rate",
    icon = "__sysadmin-poc__/graphics/icons/signals/signal-sensor-data-rate.png",
    icon_size = 32,
    subgroup = "sysadmin-signals",
    order = "j[sensor-data-rate]"
  },

  -- Signal: Technical Debt - accumulated IT neglect (0-1000 scale)
  -- High values indicate efficiency penalties are active.
  {
    type = "virtual-signal",
    name = "signal-technical-debt",
    icon = "__sysadmin-poc__/graphics/icons/signals/signal-technical-debt.png",
    icon_size = 32,
    subgroup = "sysadmin-signals",
    order = "k[technical-debt]"
  }
})
