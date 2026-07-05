-- Sysadmin POC - Settings
-- Configuration options for the mod

data:extend({
  {
    type = "int-setting",
    name = "sysadmin-sensor-range",
    setting_type = "runtime-global",
    default_value = 5,
    minimum_value = 1,
    maximum_value = 20,
    order = "a"
  }
})
