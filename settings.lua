data:extend({
	{
		type = "int-setting",
		name = "min-fuel-amount",
		setting_type = "runtime-global",
		default_value = 20,
		minimum_value = 0
	},
	{
		type = "bool-setting",
		name = "auto_updor",
		setting_type = "runtime-global",
		default_value = true,
		minimum_value = 0
	},
	{
		type = "bool-setting",
		name = "turbo_ups",
		setting_type = "runtime-global",
		default_value = false,
		minimum_value = 0
	},
	{
		type = "bool-setting",
		name = "ps-tooltip",
		setting_type = "runtime-per-user",
		default_value = true,
		minimum_value = 0
	},
	{
		type = "bool-setting",
		name = "edit_admin",
		setting_type = "startup",
		default_value = true,
		minimum_value = 0
	},
	{
		type = "string-setting",
		name = "fuelstop_name",
		setting_type = "startup",
		default_value = "FuelStop",
		description = "fuelstop_name"
	},
	{
		type = "bool-setting",
		name = "requester_stop_circuits",
		setting_type = "startup",
		default_value = true,
		minimum_value = 0
	},
	{
		type = "int-setting",
		name = "max-priority-height",
		setting_type = "runtime-per-user",
		default_value = 500,
		minimum_value = 200
	},
	{
		type = "int-setting",
		name = "max-priority-width",
		setting_type = "runtime-per-user",
		default_value = 700,
		minimum_value = 200
	},
	{
		type = "int-setting",
		name = "max-supplier-height",
		setting_type = "runtime-per-user",
		default_value = 500,
		minimum_value = 200
	},
	{
		type = "int-setting",
		name = "max-requester-height",
		setting_type = "runtime-per-user",
		default_value = 500,
		minimum_value = 200
	},
	{
		type = "int-setting",
		name = "max-outstandingrequester-height",
		setting_type = "runtime-per-user",
		default_value = 800,
		minimum_value = 200
	},
	{
		type = "int-setting",
		name = "max-supplierstations-height",
		setting_type = "runtime-per-user",
		default_value = 500,
		minimum_value = 200
	},
	{
		type = "int-setting",
		name = "max-keytrain-height",
		setting_type = "runtime-per-user",
		default_value = 800,
		minimum_value = 200
	},
	{
		type = "bool-setting",
		name = "fuel-stop-loco-count",
		setting_type = "startup",
		default_value = true,
		minimum_value = 0
	},
	{
		type = "int-setting",
		name = "ticks-per-cycle",
		setting_type = "runtime-global",
		default_value = 20,
		minimum_value = 5
	},
	{
		type = "bool-setting",
		name = "full_bp_mode",
		setting_type = "runtime-global",
		default_value = false,
		minimum_value = 0
	},
	{
		type = "int-setting",
		name = "outstanding-threshold",
		setting_type = "runtime-per-user",
		default_value = 0,
		minimum_value = 0
	},
})
