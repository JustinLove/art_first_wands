local function edit_file(path, f, ...)
	local text = ModTextFileGetContent( path )
	if text then
		ModTextFileSetContent( path, f( text, ... ) )
	end
end

local function tweak_gun_procedural( text )
	text = string.gsub( text, 'shuffleTable%( variables_01 %);', 'gun["is_rare"] = is_rare;\r\nlocal wand = afw_art_first_wand( gun, level, variables_01, variables_02, variables_03, force_unshuffle );\r\nshuffleTable( variables_01 )' )
	text = string.gsub( text, 'if%( gun%["reload_time"%] >= 60 %) then', 'if( false ) then' )
	text = string.gsub( text, 'local wand = GetWand%( gun %)', 'local wand = gun.wand' )
	--print(text)
	return text
end

function afw_edit_files()
	edit_file( "data/scripts/gun/procedural/gun_procedural.lua", tweak_gun_procedural )
	edit_file( "data/scripts/gun/procedural/gun_procedural_better.lua", tweak_gun_procedural )
end
