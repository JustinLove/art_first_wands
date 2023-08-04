local function test_wands( wands )
	x = 400
	y = -110
	for i, v in ipairs(wands) do
		EntityLoadCameraBound( v, x, y )
		x = x + 10
		y = y + 1
	end
	for i, v in ipairs(wands) do
		EntityLoadCameraBound( v, x, y )
		x = x + 10
		y = y + 1
	end
	for i, v in ipairs(wands) do
		EntityLoadCameraBound( v, x, y )
		x = x + 10
	end
	for i, v in ipairs(wands) do
		EntityLoadCameraBound( v, x, y )
		x = x + 10
	end
end

local function test_wands_level_1()
	test_wands({
		"data/entities/items/wand_level_01.xml",
		"data/entities/items/wand_level_01.xml",
		"data/entities/items/wand_level_01.xml",
		"data/entities/items/wand_level_01.xml",
		"data/entities/items/wand_level_01.xml",
		"data/entities/items/wand_level_01.xml",
		"data/entities/items/wand_level_01.xml",
	})
end

local function test_wands_level_6()
	test_wands({
		"data/entities/items/wand_level_06.xml",
		"data/entities/items/wand_level_06.xml",
		"data/entities/items/wand_level_06.xml",
		"data/entities/items/wand_level_06.xml",
		"data/entities/items/wand_level_06.xml",
		"data/entities/items/wand_level_06.xml",
		"data/entities/items/wand_level_06.xml",
	})
end

local function test_wands_level()
	test_wands({
		"data/entities/items/wand_level_01.xml",
		"data/entities/items/wand_level_02.xml",
		"data/entities/items/wand_level_03.xml",
		"data/entities/items/wand_level_04.xml",
		"data/entities/items/wand_level_05.xml",
		"data/entities/items/wand_level_06.xml",
		"data/entities/items/wand_level_10.xml",
	})
end

local function test_wands_unshuffle()
	test_wands({
		"data/entities/items/wand_unshuffle_01.xml",
		"data/entities/items/wand_unshuffle_02.xml",
		"data/entities/items/wand_unshuffle_03.xml",
		"data/entities/items/wand_unshuffle_04.xml",
		"data/entities/items/wand_unshuffle_05.xml",
		"data/entities/items/wand_unshuffle_06.xml",
		"data/entities/items/wand_unshuffle_10.xml",
	})
end

local function test_wands_better()
	test_wands({
		"data/entities/items/wand_level_01_better.xml",
		"data/entities/items/wand_level_02_better.xml",
		"data/entities/items/wand_level_03_better.xml",
		"data/entities/items/wand_level_04_better.xml",
		"data/entities/items/wand_level_05_better.xml",
		"data/entities/items/wand_level_06_better.xml",
	})
end

function afw_test( player_entity )
	--EntitySetTransform( player_entity, 1540, 6050 )
	--local x, y = EntityGetTransform( player_entity )
	--test_wands_level_6()
	--test_wands_level()
	--test_wands_unshuffle()
	--test_wands_better()
end

