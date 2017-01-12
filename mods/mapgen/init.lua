--
-- Aliases for map generator outputs
--

mapgen = {}

minetest.register_alias("mapgen_stone", "air")
minetest.register_alias("mapgen_dirt", "air")
minetest.register_alias("mapgen_dirt_with_grass", "air")
minetest.register_alias("mapgen_sand", "air")
minetest.register_alias("mapgen_water_source", "air")
minetest.register_alias("mapgen_river_water_source", "air")
minetest.register_alias("mapgen_lava_source", "air")
minetest.register_alias("mapgen_gravel", "air")
minetest.register_alias("mapgen_desert_stone", "air")
minetest.register_alias("mapgen_desert_sand", "air")
minetest.register_alias("mapgen_dirt_with_snow", "air")
minetest.register_alias("mapgen_snowblock", "air")
minetest.register_alias("mapgen_snow", "air")
minetest.register_alias("mapgen_ice", "air")
minetest.register_alias("mapgen_sandstone", "air")

-- Flora

minetest.register_alias("mapgen_tree", "air")
minetest.register_alias("mapgen_leaves", "air")
minetest.register_alias("mapgen_apple", "air")
minetest.register_alias("mapgen_jungletree", "air")
minetest.register_alias("mapgen_jungleleaves", "air")
minetest.register_alias("mapgen_junglegrass", "air")
minetest.register_alias("mapgen_pine_tree", "air")
minetest.register_alias("mapgen_pine_needles", "air")

-- Dungeons

minetest.register_alias("mapgen_cobble", "air")
minetest.register_alias("mapgen_stair_cobble", "air")
minetest.register_alias("mapgen_mossycobble", "air")
minetest.register_alias("mapgen_sandstonebrick", "air")
minetest.register_alias("mapgen_stair_sandstonebrick", "air")

minetest.set_mapgen_setting("mg_name", "singlenode", true)

minetest.register_on_generated(function(minp, maxp, seed)
	-- Set up voxel manip
	local t1 = os.clock()
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local a = VoxelArea:new{
			MinEdge={x=emin.x, y=emin.y, z=emin.z},
			MaxEdge={x=emax.x, y=emax.y, z=emax.z},
	}
	local data = vm:get_data()
	local c_observation = minetest.get_content_id("default:glass")
	local c_platform = minetest.get_content_id("default:sand")
	local c_lava     = minetest.get_content_id("default:lava_source")
	local ARENA_W = 30

	-- Loop through
	for y = minp.y, maxp.y do
		if y == 10 then
				for z = minp.z, maxp.z do
					for x = minp.x, maxp.x do
						if x < -10 and x > -50 and z < -10 and z > -50 then
							local vi = a:index(x, y, z)
							data[vi] = c_observation
						end
					end
				end
		elseif y == 0 then
			for z = minp.z, maxp.z do
				for x = minp.x, maxp.x do
					if x < ARENA_W/2 and x > -ARENA_W/2 and z < ARENA_W and z > 0 then
						local vi = a:index(x, y, z)
						data[vi] = c_platform
					end
				end
			end
		-- elseif y < -10 then
		-- 	for z = minp.z, maxp.z do
		-- 		for x = minp.x, maxp.x do
		-- 			local vi = a:index(x, y, z)
		-- 			data[vi] = c_lava
		-- 		end
		-- 	end
		end
	end

	vm:set_data(data)
	vm:write_to_map(data)
end)

function mapgen.regenerate()
	-- -- Set up voxel manip
	-- local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	-- local a = VoxelArea:new{
	-- 		MinEdge={x=-ARENA_W/2, y=0, z=0},
	-- 		MaxEdge={x=ARENA_W/2, y=1, z=ARENA_W},
	-- }
	-- local data = vm:get_data()
	-- local c_platform = minetest.get_content_id("default:sand")
	local ARENA_W = 30

	-- Loop through
	local y = 0
	for z = 0, ARENA_W do
		for x = -ARENA_W/2, ARENA_W do
			-- local vi = a:index(x, y, z)
			-- data[vi] = c_platform
			minetest.set_node({
				x = x,
				y = 0,
				z = z
			}, {
				name = "default:sand"
			})
		end
	end
	--
	-- vm:set_data(data)
	-- vm:write_to_map(data)
end
