local afw_print_logs = ModIsEnabled('EnableLogger')

function afw_log( ... )
	if afw_print_logs then
		print( ... )
	end
end

afw_unshuffle_wands = {}

function afw_setup()
	if ModSettingGet('art_first_wands.bias_art_selection') then
		for w = 1,#wands do
			afw_rate_wand( wands[w] )
		end

		local function compare_wands(a, b)
			return a.rating < b.rating
		end

		table.sort(wands, compare_wands)

		--[[
		for i = 1,#wands,100 do
			print(i, wands[i].rating)
		end
		print(#wands, wands[#wands].rating)
		]]
	end

	for w = 1,#wands do
		local wand = wands[w]
		if wand.shuffle_deck_when_empty == 0 then
			afw_unshuffle_wands[#afw_unshuffle_wands+1] = wand
		end
	end

	afw_log( 'unshuffle wands', #afw_unshuffle_wands, #wands )
end

function afw_rate_wand( wand )
	local variable
	local rating = 0

	-- fire_rate_wait:            0  -  4   / 1 - 30 (50)
	rating = rating + (wand["fire_rate_wait"] / 4) * -0.5

	-- shuffle_deck_when_empty(cost):   0  -  1 	/ 
	-- deck_capacity:             0  -  7 	/ 3 - 10 / 20 
	local cap = math.floor(math.pow(0.68*wand["deck_capacity"], 2)) + 2
	if( wand["shuffle_deck_when_empty"] == 0 ) then
		rating = rating + (cap / 26) * 3.0
	else
		rating = rating + ((cap - 6) / 26) * 1.0
	end

	-- actions_per_round:         0  -  2 	/  1 - 3
	rating = rating + (wand["actions_per_round"] / 2) * 0.5

	-- spread_degrees:            0  -  2 	/ -5 - 10 / -35 - 35
	rating = rating + (wand["spread_degrees"] / 7) * -0.5

	-- reload_time:               0  -  2 	/ 5 - 100
	rating = rating + (wand["reload_time"] / 2) * -1.0
	local rel = wand["reload_time"]
	if rel == 0 then
		rating = rating + 0.5
	elseif rel == 1 then
		rating = rating + -0.5
	else
		rating = rating + -2.0
	end

	wand.rating = rating
	return rating
end

function afw_gun_from_wand( t_gun, wand )
	local variable

	-- other cost calculations depend on this
	-- shuffle_deck_when_empty(value):   0  -  1 	/ 
	t_gun["shuffle_deck_when_empty"] = wand["shuffle_deck_when_empty"]
	-- fire_rate_wait:            0  -  4   / 1 - 30 (50)
	t_gun["fire_rate_wait"] = 10 * wand["fire_rate_wait"] - 10
	t_gun["fire_rate_wait"] = t_gun["fire_rate_wait"] + RandomDistribution( -10, 10, 0, 1)
	t_gun["cost"] = t_gun["cost"] - ( 16 - t_gun["fire_rate_wait"] )
	variable = "fire_rate_wait"
	afw_log( variable, t_gun[variable], t_gun['cost'] )

	-- deck_capacity:             0  -  7 	/ 3 - 10 / 20 
	--t_gun["deck_capacity"] = 3 * wand["deck_capacity"] + 3
	local cap = wand["deck_capacity"] + RandomDistributionf( 0, 1, 0.5, 0)
	t_gun["deck_capacity"] = math.floor(math.pow(0.68*cap, 2)) + 2
	if( t_gun["shuffle_deck_when_empty"] == 0 ) then
		t_gun["cost"] = t_gun["cost"] - ((t_gun["deck_capacity"] - 0) * 10)
	else
		t_gun["cost"] = t_gun["cost"] - ((t_gun["deck_capacity"] - 6) * 5)
	end
	variable = "deck_capacity"
	afw_log( variable, t_gun[variable], t_gun['cost'], wand[variable] )

	-- actions_per_round:         0  -  2 	/  1 - 3
	local cap = t_gun['deck_capacity']
	local actions = wand["actions_per_round"]
	if actions == 0 then
		t_gun["actions_per_round"] = 1
	elseif actions == 1 then
		t_gun["actions_per_round"] = RandomDistribution( 2, 5, 2, 2)
	else
		t_gun["actions_per_round"] = RandomDistribution( 3, cap, cap/2, 2)
	end
	t_gun["actions_per_round"] = math.floor(clamp(t_gun["actions_per_round"], 1, cap))
	variable = "actions_per_round"
	afw_log( variable, t_gun[variable], t_gun['cost'], wand[variable] )

	-- shuffle_deck_when_empty(cost):   0  -  1 	/ 
	if( t_gun["shuffle_deck_when_empty"] == 1 ) then
		if( t_gun["actions_per_round"] < 2 ) then
			t_gun["cost"] = t_gun["cost"] + 60
		else
			t_gun["cost"] = t_gun["cost"] + 30
			t_gun["cost"] = t_gun["cost"] - t_gun["actions_per_round"] * 10
		end
	else
		-- cost is paid in increased slot cost
		t_gun["cost"] = t_gun["cost"] - t_gun["actions_per_round"] * 5
	end
	variable = "shuffle_deck_when_empty"
	afw_log( variable, t_gun[variable], t_gun['cost'] )

	-- spread_degrees:            0  -  2 	/ -5 - 10 / -35 - 35
	t_gun["spread_degrees"] = 7 * wand["spread_degrees"] - 5
	t_gun["spread_degrees"] = t_gun["spread_degrees"] + RandomDistribution( -7, 7, 0, 1)
	t_gun["cost"] = t_gun["cost"] - math.floor( -0.1 *  t_gun["spread_degrees"] + -5 * math.atan( 0.3 * t_gun["spread_degrees"] ) )
	variable = "spread_degrees"
	afw_log( variable, t_gun[variable], t_gun['cost'] )

	-- reload_time:               0  -  2 	/ 5 - 100
	local rel = wand["reload_time"]
	if rel == 0 then
		t_gun["reload_time"] = RandomDistribution( -10, 30, 10, 1)
	elseif rel == 1 then
		t_gun["reload_time"] = RandomDistribution( 30, 60, 45, 1)
	else
		t_gun["reload_time"] = RandomDistribution( 60, 240, 120, 1)
	end
	t_gun["cost"] = t_gun["cost"] - ( (60 - t_gun["reload_time"]) / 2 )
	variable = "reload_time"
	afw_log( variable, t_gun[variable], t_gun['cost'] )

	local probs = get_gun_probs( "speed_multiplier" )
	t_gun["speed_multiplier"] = RandomDistributionf( probs.min, probs.max, probs.mean, probs.sharpness )
	variable = "speed_multiplier"
	afw_log( variable, t_gun[variable], t_gun['cost'] )
end

function afw_mana_sponge( t_gun )
	local variable
	local fraction = Random()
	afw_log( 'mana sponge in', t_gun['cost'] )
	local points = math.floor(t_gun["cost"] * fraction)
	local offset = 50
	if points < 0 then
		t_gun["mana_charge_speed"] = math.floor(clamp( offset + points*1.35, 10, 5000 ))
		t_gun["cost"] = t_gun["cost"] - math.floor( (t_gun["mana_charge_speed"]-offset) / 1.35 )
	else
		t_gun["mana_charge_speed"] = math.floor(clamp( offset + points*11, 10, 5000 ))
		t_gun["cost"] = t_gun["cost"] - math.floor( (t_gun["mana_charge_speed"]-offset) / 11 )
	end
	variable = "mana_charge_speed"
	afw_log( variable, t_gun[variable], t_gun['cost'] )

	local points = t_gun["cost"]
	local offset = 200
	t_gun["mana_max"] = math.floor(clamp( offset + points*35, 50, 6000 ))
	t_gun["cost"] = t_gun["cost"] - math.floor( (t_gun["mana_max"]-offset) / 35 )
	variable = "mana_max"
	afw_log( 'mana_max       ', t_gun[variable], t_gun['cost'] )
end

function afw_wand_stats()
	local variables = { "reload_time", "fire_rate_wait", "spread_degrees", "shuffle_deck_when_empty", "deck_capacity", "actions_per_round" }
	local stats = {}
	for i, var in ipairs(variables) do
		stats[var] = {min = 100, max = 0}
	end
	for w, wand in ipairs(wands) do
		for i, var in ipairs(variables) do
			stats[var].min = math.min(stats[var].min, wand[var])
			stats[var].max = math.max(stats[var].max, wand[var])
		end
	end
	for i, var in ipairs(variables) do
		afw_log( var .. ": " .. stats[var].min .. "-" .. stats[var].max )
	end
end

function afw_art_first_wand( gun, level, variables_01, variables_02, variables_03, force_unshuffle )
	if #afw_unshuffle_wands < 1 then
		afw_setup()
	end
	if GlobalsGetValue( "PERK_NO_MORE_SHUFFLE_WANDS", "0" ) == "1" then
		force_unshuffle = true
	end
	local base_cost = gun['cost']
	afw_log( 'initial cost----', gun['cost'])
	local wand
	if ModSettingGet('art_first_wands.bias_art_selection') then
		local selectionValue = math.min(1.0, (base_cost - 30) / 90)
		if force_unshuffle then
			local i = RandomDistribution( 1, #afw_unshuffle_wands, afw_unshuffle_wands*selectionValue, 2)
			wand = afw_unshuffle_wands[i]
		else
			local i = RandomDistribution( 1, #wands, #wands*selectionValue, 2)
			wand = wands[i]
		end
	else
		if force_unshuffle then
			wand = afw_unshuffle_wands[Random(1, #afw_unshuffle_wands)]
		else
			wand = wands[Random(1, #wands)]
		end
	end

	afw_gun_from_wand( gun, wand )
	gun["cost"] = math.floor( gun["cost"] * 0.3 + level * 9 )
	afw_mana_sponge( gun, wand )
	afw_log( 'final cost', gun['cost'] )

	while #variables_01 > 0 do
		table.remove(variables_01)
	end
	while #variables_02 > 0 do
		table.remove(variables_02)
	end
	while #variables_03 > 0 do
		table.remove(variables_03)
	end

	if false then
		local entity_id = GetUpdatedEntityID()
		local item = EntityGetFirstComponent( entity_id, "ItemComponent" )
		if item then
			local rare = ''
			if gun["is_rare"] == 1 then
				rare = 'r'
			end
			ComponentSetValue2( item, "item_name", table.concat({tostring(level), rare, " ", gun["cost"], string.format(" %0.2f", wand.rating) }) )
			ComponentSetValue2( item, "always_use_item_name_in_ui", true )
		end
	end

	--gun["cost"] = 0
	gun["wand"] = wand
	return wand
end
