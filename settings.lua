dofile("data/scripts/lib/mod_settings.lua") -- see this file for documentation on some of the features.

local mod_id = "art_first_wands" -- This should match the name of your mod's folder.
mod_settings_version = 1 -- This is a magic global that can be used to migrate settings to new mod versions. call mod_settings_get_version() before mod_settings_update() to get the old value. 
mod_settings = 
{
	{
		id = "bias_art_selection",
		ui_name = "Bias Art Selection",
		ui_description = "Try to pick art somewhat appopriate to the wand level.\nOtherwise, art is completely random and mana will likely be wild to make up for it.\nRequires restart.",
		value_default = true,
		scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
	},
	{
		category_id = "min_mana",
		ui_name = "Minimum Mana",
		settings = {
			{
				id = "min_mana_max",
				ui_name = "Mana max",
				ui_description = "The lowest allowed level of mana storage",
				value_default = "50",
				values = { {"150", "150"}, {"100", "100"}, {"50","50"}, {"30", "30"}, {"10", "10"}, {"5","5"}, {"2", "2"}, {"0", "0"} },
				scope = MOD_SETTING_SCOPE_RUNTIME,
			},
			{
				id = "min_mana_charge_speed",
				ui_name = "Mana chg. Spd",
				ui_description = "The lowest allowed level of manage charge speed",
				value_default = "10",
				values = { {"50","50"}, {"30", "30"}, {"10", "10"}, {"5","5"}, {"1", "1"}, {"0", "0"} },
				scope = MOD_SETTING_SCOPE_RUNTIME,
			},
		},
	},
}

function ModSettingsUpdate( init_scope )
	local old_version = mod_settings_get_version( mod_id ) -- This can be used to migrate some settings between mod versions.
	mod_settings_update( mod_id, mod_settings, init_scope )
end

function ModSettingsGuiCount()
	return mod_settings_gui_count( mod_id, mod_settings )
end

function ModSettingsGui( gui, in_main_menu )
	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end
