dofile_once( "mods/art_first_wands/files/edit_files.lua" )
dofile_once( "mods/art_first_wands/files/test.lua" )

function OnPlayerSpawned( player_entity ) -- This runs when player entity has been created
	local init_check_flag = "art_first_wands_init_done"
	if GameHasFlagRun( init_check_flag ) then
		return
	end
	GameAddFlagRun( init_check_flag )

	afw_test( player_entity )
end

function OnMagicNumbersAndWorldSeedInitialized() -- this is the last point where the Mod* API is available. after this materials.xml will be loaded.
	afw_edit_files()
end

-- This code runs when all mods' filesystems are registered
ModLuaFileAppend( "data/scripts/gun/procedural/gun_procedural.lua", "mods/art_first_wands/files/gun_procedural.lua" )
ModLuaFileAppend( "data/scripts/gun/procedural/gun_procedural_better.lua", "mods/art_first_wands/files/gun_procedural.lua" )
