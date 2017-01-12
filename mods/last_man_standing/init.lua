dofile(minetest.get_modpath("last_man_standing") .. "/api.lua")

local OBSERVATION_PLATFORM_POS = {
	x = -15,
	y = 11,
	z = -15
}

-- Make sure player doesn't leave observation platform
local function restrict_to_observation_platform(player)
	if player:getpos().y < OBSERVATION_PLATFORM_POS.y - 2 then
		player:setpos(OBSERVATION_PLATFORM_POS)
	end
end

last_man_standing.register_state("waiting_for_players", {
	on_joinplayer = function(self, player)
		if #minetest.get_connected_players() > 1 then
			last_man_standing.set_state("prematch")
		else
			minetest.after(0.2, function()
				minetest.chat_send_player(player:get_player_name(),
					"Waiting for players to join before starting game...")
			end)
		end

		player:setpos(OBSERVATION_PLATFORM_POS)
	end,

	player_step = function(self, player)
		restrict_to_observation_platform(player)
	end,
})

last_man_standing.register_state("prematch", {
	init = function(self)
		self.count_down = 20
	end,

	on_joinplayer = function(self, player)
		player:setpos(OBSERVATION_PLATFORM_POS)
	end,

	on_leaveplayer = function(self, player)
		if #minetest.get_connected_players() < 2 then
			last_man_standing.set_state("waiting_for_players")
		end
	end,

	player_step = function(self, player)
		restrict_to_observation_platform(player)
	end,

	step = function(self, dtime)
		local last = self.count_down
		self.count_down = self.count_down - dtime
		if math.floor(last) ~= math.floor(self.count_down) then
			minetest.chat_send_all(math.round(self.count_down) ..
				"s until start")
		end
	end
})

last_man_standing.set_state("waiting_for_players")
