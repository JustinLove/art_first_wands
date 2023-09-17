local afw_print_logs = ModIsEnabled('EnableLogger')

function afw_log( ... )
	if afw_print_logs then
		print( ... )
	end
end

afw_unshuffle_wands = {}

local function art_cost_at_cost(base_cost, force_unshuffle)
	local selectionValue = math.min(1.0, (base_cost - 20) / 120)
	if force_unshuffle then
		local i = math.max(1, math.min(#afw_unshuffle_wands, math.floor(#afw_unshuffle_wands*selectionValue)))
		return afw_unshuffle_wands[i]
	else
		local i = math.max(1, math.min(#wands, math.floor(#wands*selectionValue)))
		return wands[i]
	end
end

function afw_setup()
	if ModSettingGet('art_first_wands.bias_art_selection') then
		for w = 1,#wands do
			afw_rate_wand( wands[w] )
		end

		local function compare_wands(a, b)
			return a.rating < b.rating
		end

		table.sort(wands, compare_wands)

		if ModSettingGet('art_first_wands.wand_gen_logging') then
			for i = 1,#wands,100 do
				print(i, wands[i].rating)
			end
			print(#wands, wands[#wands].rating)
		end
	end

	for w = 1,#wands do
		local wand = wands[w]
		if wand.shuffle_deck_when_empty == 0 then
			afw_unshuffle_wands[#afw_unshuffle_wands+1] = wand
		end
	end

	afw_log( 'unshuffle wands', #afw_unshuffle_wands, #wands )

	if ModSettingGet('art_first_wands.wand_gen_logging') then
		local points = {30,40,60,80,100,120,200}
		for i = 1,#points do
			local p = points[i]
			local base = art_cost_at_cost(p, false)
			local unshuffle = art_cost_at_cost(p, true)
			print(p, base.rating, unshuffle.rating)
			p = p + 65
			base = art_cost_at_cost(p, false)
			unshuffle = art_cost_at_cost(p, true)
			print(p, base.rating, unshuffle.rating)
		end
	end
end

function afw_rate_wand( wand )
	local gun = {}
	afw_static_gun_from_wand( gun, wand )
	wand.rating = afw_gun_cost( gun )
end

function afw_static_gun_from_wand( t_gun, wand )
	-- shuffle_deck_when_empty:   0  -  1 	/
	t_gun["shuffle_deck_when_empty"] = wand["shuffle_deck_when_empty"]

	-- fire_rate_wait:            0  -  4   / 1 - 30 (50)
	t_gun["fire_rate_wait"] = 10 * wand["fire_rate_wait"] - 10

	-- deck_capacity:             0  -  7 	/ 3 - 10 / 20
	--t_gun["deck_capacity"] = 3 * wand["deck_capacity"] + 3
	local cap = wand["deck_capacity"] + 0.5
	-- min: we'll probably get limited by vanilla code, so no point in paying points for extra slots we won't get.
	t_gun["deck_capacity"] = math.min(26, math.floor(math.pow(0.68*cap, 2) + 2.5))

	-- actions_per_round:         0  -  2 	/  1 - 3
	local cap = t_gun['deck_capacity']
	local actions = wand["actions_per_round"]
	if actions == 0 then
		t_gun["actions_per_round"] = 1
	elseif actions == 1 then
		t_gun["actions_per_round"] = 2
	else
		t_gun["actions_per_round"] = math.max(3, cap/2)
	end
	t_gun["actions_per_round"] = math.floor(clamp(t_gun["actions_per_round"], 1, cap))

	-- spread_degrees:            0  -  2 	/ -5 - 10 / -35 - 35
	t_gun["spread_degrees"] = 7 * wand["spread_degrees"] - 5

	-- reload_time:               0  -  2 	/ 5 - 100
	local rel = wand["reload_time"]
	if rel == 0 then
		t_gun["reload_time"] = 10
	elseif rel == 1 then
		t_gun["reload_time"] = 45
	else
		t_gun["reload_time"] = 120
	end

	t_gun["speed_multiplier"] = 1.0
end

function afw_gun_from_wand( t_gun, wand, net )
	local factor = math.atan(net/60)

	-- shuffle_deck_when_empty:   0  -  1 	/
	t_gun["shuffle_deck_when_empty"] = wand["shuffle_deck_when_empty"]

	-- fire_rate_wait:            0  -  4   / 1 - 30 (50)
	t_gun["fire_rate_wait"] = 10 * wand["fire_rate_wait"] - 10
	t_gun["fire_rate_wait"] = t_gun["fire_rate_wait"] + RandomDistribution( -10, 10, factor*-10, 1)
	-- deck_capacity:             0  -  7 	/ 3 - 10 / 20
	--t_gun["deck_capacity"] = 3 * wand["deck_capacity"] + 3
	local cap = wand["deck_capacity"] + RandomDistributionf( 0, 1, factor+0.5, 0)
	-- min: we'll probably get limited by vanilla code, so no point in paying points for extra slots we won't get.
	t_gun["deck_capacity"] = math.min(26, math.floor(math.pow(0.68*cap, 2) + 2.5))

	-- actions_per_round:         0  -  2 	/  1 - 3
	local cap = t_gun['deck_capacity']
	local actions = wand["actions_per_round"]
	if actions == 0 then
		t_gun["actions_per_round"] = 1
	elseif actions == 1 then
		t_gun["actions_per_round"] = RandomDistribution( 2, 5, 2+factor*2, 2)
	else
		t_gun["actions_per_round"] = RandomDistribution( 3, cap, (1+factor)*cap/2, 2)
	end
	t_gun["actions_per_round"] = math.floor(clamp(t_gun["actions_per_round"], 1, cap))

	-- spread_degrees:            0  -  2 	/ -5 - 10 / -35 - 35
	t_gun["spread_degrees"] = 7 * wand["spread_degrees"] - 5
	t_gun["spread_degrees"] = t_gun["spread_degrees"] + RandomDistribution( -7, 7, factor*-7, 1)

	-- reload_time:               0  -  2 	/ 5 - 100
	local rel = wand["reload_time"]
	if rel == 0 then
		t_gun["reload_time"] = RandomDistribution( -10, 30, (1-factor)*10, 1)
	elseif rel == 1 then
		t_gun["reload_time"] = RandomDistribution( 30, 60, (1-factor)*45, 1)
	else
		t_gun["reload_time"] = RandomDistribution( 60, 240, (1-factor)*120, 1)
	end

	local probs = get_gun_probs( "speed_multiplier" )
	t_gun["speed_multiplier"] = RandomDistributionf( probs.min, probs.max, probs.mean, probs.sharpness )
end

function afw_gun_cost( t_gun )
	local variable
	local cost
	local total_cost = 0

	-- shuffle_deck_when_empty(cost):   0  -  1 	/
	-- cost is paid in increased slot cost
	if( t_gun["shuffle_deck_when_empty"] == 1 ) then
		cost = 0
		if( t_gun["actions_per_round"] < 2 ) then
			--cost = -45
		else
			--cost = -15
		end
	else
		cost = 15 + ((t_gun["deck_capacity"] - 0) * 4)
	end
	total_cost = total_cost + cost
	variable = "shuffle_deck_when_empty"
	afw_log( variable, t_gun[variable], cost )

	-- deck_capacity:             0  -  7 	/ 3 - 10 / 20
	cost = ((t_gun["deck_capacity"] - 6) * 4)
	total_cost = total_cost + cost
	variable = "deck_capacity"
	afw_log( variable, t_gun[variable], cost )

	-- actions_per_round:         0  -  2 	/  1 - 3
	cost = t_gun["actions_per_round"] * 2
	total_cost = total_cost + cost
	variable = "actions_per_round"
	afw_log( variable, t_gun[variable], cost )

	-- fire_rate_wait:            0  -  4   / 1 - 30 (50)
	cost = math.floor( 16 - t_gun["fire_rate_wait"] )
	total_cost = total_cost + cost
	variable = "fire_rate_wait"
	afw_log( variable, t_gun[variable], cost )

	-- reload_time:               0  -  2 	/ 5 - 100
	cost = math.floor( (60 - t_gun["reload_time"]) / 2 )
	total_cost = total_cost + cost
	variable = "reload_time"
	afw_log( variable, t_gun[variable], cost )

	-- spread_degrees:            0  -  2 	/ -5 - 10 / -35 - 35
	cost = math.floor( -0.1 *  t_gun["spread_degrees"] + -5 * math.atan( 0.3 * t_gun["spread_degrees"] ) )
	total_cost = total_cost + cost
	variable = "spread_degrees"
	afw_log( variable, t_gun[variable], cost )


	variable = "speed_multiplier"
	afw_log( variable, t_gun[variable], 0 )

	return math.floor(total_cost)
end

function afw_mana_sponge( t_gun )
	local variable
	local fraction = Random()
	afw_log( 'mana sponge in', t_gun['cost'] )
	local points = math.floor(t_gun["cost"] * fraction)
	local offset = 10
	local minimum = tonumber(ModSettingGet('art_first_wands.min_mana_charge_speed')) or 10
	if points < 0 then
		t_gun["mana_charge_speed"] = math.floor(clamp( offset + points*1.35, minimum, 5000 ))
		t_gun["cost"] = t_gun["cost"] - math.floor( (t_gun["mana_charge_speed"]-offset) / 1.35 )
	else
		t_gun["mana_charge_speed"] = math.floor(clamp( offset + points*11, minimum, 5000 ))
		t_gun["cost"] = t_gun["cost"] - math.floor( (t_gun["mana_charge_speed"]-offset) / 11 )
	end
	variable = "mana_charge_speed"
	afw_log( variable, t_gun[variable], t_gun['cost'] )

	local points = t_gun["cost"]
	local offset = 50
	local minimum = tonumber(ModSettingGet('art_first_wands.min_mana_max')) or 50
	t_gun["mana_max"] = math.floor(clamp( offset + points*35, minimum,  6000 ))
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

function afw_pick_wand( base_cost, force_unshuffle )
	if GlobalsGetValue( "PERK_NO_MORE_SHUFFLE_WANDS", "0" ) == "1" then
		force_unshuffle = true
	end
	if ModSettingGet('art_first_wands.bias_art_selection') then
		local selectionValue = math.min(1.0, (base_cost - 20) / 120)
		if force_unshuffle then
			local i = RandomDistribution( 1, #afw_unshuffle_wands, #afw_unshuffle_wands*selectionValue, 2)
			return afw_unshuffle_wands[i]
		else
			local i = RandomDistribution( 1, #wands, #wands*selectionValue, 2)
			return wands[i]
		end
	else
		if force_unshuffle then
			return afw_unshuffle_wands[Random(1, #afw_unshuffle_wands)]
		else
			return wands[Random(1, #wands)]
		end
	end
end

function afw_art_first_wand( gun, level, variables_01, variables_02, variables_03, force_unshuffle )
	if #afw_unshuffle_wands < 1 then
		afw_print_logs = false
		afw_setup()
	end
	afw_print_logs = ModIsEnabled('EnableLogger') and ModSettingGet('art_first_wands.wand_gen_logging')
	if force_unshuffle then
		gun["cost"] = gun["cost"] + 40 -- unshuffle wands are typically spawned at two levels lower
	end
	local base_cost = gun['cost']
	afw_log( 'initial cost----', base_cost)
	local wand = afw_pick_wand( base_cost, force_unshuffle )

	if not wand.rating then
		afw_rate_wand(wand)
	end
	local net = gun["cost"] - wand.rating
	afw_gun_from_wand( gun, wand, net )
	local art_cost = afw_gun_cost( gun )
	gun["cost"] = gun["cost"] - art_cost
	gun["cost"] = math.floor( gun["cost"] * 0.3 + level * 9 )
	local mana_setup = gun["cost"]
	afw_mana_sponge( gun, wand )
	local final_cost = gun["cost"]
	afw_log( 'final cost', base_cost, art_cost, mana_setup, final_cost)

	while #variables_01 > 0 do
		table.remove(variables_01)
	end
	while #variables_02 > 0 do
		table.remove(variables_02)
	end
	while #variables_03 > 0 do
		table.remove(variables_03)
	end

	if ModSettingGet('art_first_wands.wand_names') then
		local entity_id = GetUpdatedEntityID()
		local item = EntityGetFirstComponent( entity_id, "ItemComponent" )
		if item then
			local rare = ''
			if gun["is_rare"] == 1 then
				rare = 'r'
			end
			local unshuf = ''
			if force_unshuffle then
				unshuf = 'u'
			end
			local rating = ''
			if ModSettingGet('art_first_wands.bias_art_selection') then
				rating = wand.rating
			end
			ComponentSetValue2( item, "item_name", table.concat({tostring(level), rare, unshuf, base_cost, rating, art_cost, mana_setup, final_cost }, ' ') )
			ComponentSetValue2( item, "always_use_item_name_in_ui", true )
		end
	end

	--gun["cost"] = 0
	gun["wand"] = wand
	return wand
end
