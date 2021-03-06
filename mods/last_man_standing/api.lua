last_man_standing = {
	states = {},
	current_state = nil
}

function math.round(x)
	return math.floor(x + 0.5)
end

function last_man_standing.get_state()
	return last_man_standing.states[last_man_standing.current_state]
end

function last_man_standing.set_state(name)
	assert(last_man_standing.states[name], "State " .. name .. " does not exist!")
	local old_state = last_man_standing.get_state()
	if old_state and old_state.deinit then
		old_state:deinit()
	end

	print("State set to " .. name)
	last_man_standing.current_state = name

	local new_state = last_man_standing.get_state()
	if new_state and new_state.init then
		new_state:init()
	end
end

function last_man_standing.register_state(name, def)
	assert(not last_man_standing.states[name], "State already defined!")
	last_man_standing.states[name] = def
end

function last_man_standing.step()
	local state = last_man_standing.get_state()
	if state.player_step then
		for _, player in pairs(minetest.get_connected_players()) do
			state:player_step(player)
		end
	end
	if state.step then
		state:step(0.5)
	end
	minetest.after(0.5, last_man_standing.step)
end
minetest.after(0.5, last_man_standing.step)

minetest.register_on_joinplayer(function(...)
	local state = last_man_standing.get_state()
	if state.on_joinplayer then
		state:on_joinplayer(...)
	end
end)

minetest.register_on_leaveplayer(function(...)
	local state = last_man_standing.get_state()
	if state.on_leaveplayer then
		state:on_leaveplayer(...)
	end
end)
