last_man_standing = {
	states = {},
	current_state = nil
}

function last_man_standing.get_state()
	return last_man_standing.states[last_man_standing.current_state]
end

function last_man_standing.set_state(name)
	assert(last_man_standing.states[name], "State " .. name .. " does not exist!")
	local old_state = last_man_standing.get_state()
	if old_state and old_state.deinit then
		old_state:deinit()
	end

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
	if state.step then
		state:step(0.5)
	end
	if state.player_step then
		for _, player in pairs(minetest.get_connected_players()) do
			state:player_step(player)
		end
	end
	minetest.after(0.5, last_man_standing.step)
end
minetest.after(0.5, last_man_standing.step)

minetest.register_on_joinplayer(function(...)
	last_man_standing.get_state():on_joinplayer(...)
end)

minetest.register_on_leaveplayer(function(...)
	last_man_standing.get_state():on_leaveplayer(...)
end)
