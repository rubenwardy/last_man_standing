dofile(minetest.get_modpath("last_man_standing") .. "/api.lua")

local OBSERVATION_PLATFORM_POS = {
	x = -15,
	y = 11,
	z = -15
}

local MIN_PLAYERS = 2

-- Make sure player doesn't leave observation platform
local function restrict_to_observation_platform(player)
	if player:getpos().y < OBSERVATION_PLATFORM_POS.y - 2 then
		player:setpos(OBSERVATION_PLATFORM_POS)
	end
end

last_man_standing.register_state("waiting_for_players", {
	on_joinplayer = function(self, player)
		if #minetest.get_connected_players() >= MIN_PLAYERS then
			last_man_standing.set_state("prematch")
		else
			minetest.after(0.2, function()
				minetest.chat_send_player(player:get_player_name(),
					"Waiting for players to join before starting game...")
			end)
			player:setpos(OBSERVATION_PLATFORM_POS)
		end
	end,

	player_step = function(self, player)
		restrict_to_observation_platform(player)
	end,
})

last_man_standing.register_state("prematch", {
	init = function(self)
		self.count_down = 3
	end,

	on_joinplayer = function(self, player)
		player:setpos(OBSERVATION_PLATFORM_POS)
	end,

	on_leaveplayer = function(self, player)
		if #minetest.get_connected_players() < MIN_PLAYERS then
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

		if self.count_down <= 0 then
			last_man_standing.set_state("game")
		end
	end
})

last_man_standing.register_state("game", {
	init = function(self)
		minetest.chat_send_all("Knock or dig your oponents off the platform!")
		self.is_player_alive = {}
		for _, player in pairs(minetest.get_connected_players()) do
			self.is_player_alive[player:get_player_name()] = true
			player:setpos({
				x = 0,
				y = 1,
				z = 10
			})
			-- TODO: random placement
		end
	end,

	get_winner = function(self)
		local winner_name = nil
		for name, is_alive in pairs(self.is_player_alive) do
			if is_alive then
				if winner_name then
					return nil
				else
					winner_name = name
				end
			end
		end
		return winner_name
	end,

	check_for_gameover_conditions = function(self)
		local winner = self:get_winner()
		if winner then
			minetest.chat_send_all(winner .. " won the game!")
			if #minetest.get_connected_players() < MIN_PLAYERS then
				last_man_standing.set_state("waiting_for_players")
			else
				last_man_standing.set_state("prematch")
			end
		end
	end,

	player_step = function(self, player)
		local name = player:get_player_name()
		if self.is_player_alive[name] then
			local pos = player:getpos()
			if pos.y < -4 then
				self.is_player_alive[name] = false
				restrict_to_observation_platform(player)
				minetest.chat_send_all(name .. " has been knocked out the game!")
				self:check_for_gameover_conditions()
			end

			-- TODO: anti cheat for flying high
		else
			restrict_to_observation_platform(player)
		end
	end,
})

last_man_standing.set_state("waiting_for_players")
