function start_tutorial()
	utils.stop_tweens()

	slowmode = false
	bar_width = 100
	mana = 100
	max_mana = 100
	jumpmanacost = 20
	manacostpersec = 160
	score = 0
	active = true
	bar_color = Color('#5ce1e6')
	gamestate = 's'
	drawtarget = 'tutorial'
	center_score_opacity = 0
	set_timescale(1)
	play_first = true

	player = Player(Vector(50, 50), Vector(0, 0))
	zoo = {}
	table.insert(zoo, player)
	-- table.insert(zoo, Blob(Vector(20, 80), Vector(math.random()-0.5, math.random()-0.5)))
	-- table.insert(zoo, Blob(Vector(80, 20), Vector(math.random()-0.5, math.random()-0.5)))
	-- table.insert(zoo, Blob(Vector(80, 80), Vector(math.random()-0.5, math.random()-0.5)))

	game_transparency = 1
	flux.to(_G, 0.8, {game_transparency=0})
		:ease('sineinout')
		:oncomplete(function ()
			gamestate = 'r'
		end)
end

function load_welcome()
	utils.stop_tweens()
	drawtarget = 'welcome'
	gamestate = 'm'
	zoo = {}
	game_transparency = 1
	flux.to(_G, 0.4, {game_transparency=0})
		:ease('sineinout')
		:after({}, 1, {})
		:after(_G, 0.4, {game_transparency=1})
		:after({}, 0.8, {})
		:oncomplete(start_tutorial)
end

function load_farewell()
	utils.stop_tweens()
	drawtarget = 'farewell'
	gamestate = 's'
	zoo = {}
	game_transparency = 1
	flux.to(_G, 0.4, {game_transparency=0})
		:ease('sineinout')
		:after({}, 0.6, {})
		:after(_G, 0.4, {game_transparency=1})
		:after({}, 0.4, {})
		:oncomplete(love.event.quit)
end

function load_shelf()
	utils.stop_tweens()
	drawtarget = 'shelf'
	gamestate = 'm'
	zoo = {}
	game_transparency = 1
	flux.to(_G, 0.4, {game_transparency=0}):ease('sineinout')
end

function load_credits()
	utils.stop_tweens()
	drawtarget = 'credits'
	gamestate = 'm'
	zoo = {}
	game_transparency = 1
	flux.to(_G, 0.4, {game_transparency=0}):ease('sineinout')
end

function load_menu()
	utils.stop_tweens()
	if music_playing then
		music_playing = false
		music:stop()
	end
	drawtarget = 'menu'
	gamestate = 'm'
	zoo = {}
	table.insert(zoo, Circle(Vector(6, 34), 1.5, Color('#ffde59'), 'fill'))
	table.insert(zoo, Circle(Vector(6, 47), 1.5, Color('#ff5757'), 'fill'))
	table.insert(zoo, Circle(Vector(6, 60), 1.5, Color('#5ce1e6'), 'fill'))
	table.insert(zoo, Circle(Vector(6, 73), 1.5, Color('#737373'), 'fill'))
	game_transparency = 1
	flux.to(_G, 0.4, {game_transparency=0}):ease('sineinout')
end

function start_new_game()
	utils.stop_tweens()

	slowmode = false
	bar_width = 100
	mana = 100
	max_mana = 100
	jumpmanacost = 20
	manacostpersec = 160
	score = 0
	active = true
	bar_color = Color('#5ce1e6')
	gamestate = 's'
	drawtarget = 'field'
	center_score_opacity = 0
	set_timescale(1)

	player = Player(Vector(50, 50), Vector(0, 0))
	zoo = {}
	table.insert(zoo, player)
	table.insert(zoo, Blob(Vector(20, 20), Vector(math.random()-0.5, math.random()-0.5)))
	-- table.insert(zoo, Blob(Vector(20, 80), Vector(math.random()-0.5, math.random()-0.5)))
	-- table.insert(zoo, Blob(Vector(80, 20), Vector(math.random()-0.5, math.random()-0.5)))
	-- table.insert(zoo, Blob(Vector(80, 80), Vector(math.random()-0.5, math.random()-0.5)))
	local circle = Circle(Vector(20, 80), 4, Color('#ff5757'), 'fill', 0, 1)
	table.insert(zoo, circle)
	flux.to(circle, 2, {opacity=0})
		:ease('quartinout')
		:oncomplete(function() utils.remove(zoo, circle) end)
	local circle = Circle(Vector(80, 80), 4, Color('#ff5757'), 'fill', 0, 1)
	table.insert(zoo, circle)
	flux.to(circle, 2, {opacity=0})
		:ease('quartinout')
		:oncomplete(function() utils.remove(zoo, circle) end)
	local circle = Circle(Vector(80, 20), 4, Color('#ff5757'), 'fill', 0, 1)
	table.insert(zoo, circle)
	flux.to(circle, 2, {opacity=0})
		:ease('quartinout')
		:oncomplete(function() utils.remove(zoo, circle) end)
	table.insert(zoo, Coin(Vector(love.math.random(80)+10, love.math.random(80)+10)))

	game_transparency = 1
	flux.to(_G, 0.8, {game_transparency=0})
		:ease('sineinout')
		:oncomplete(function ()
			gamestate = 'r'
		end)

	if not music_playing then
		music = love.audio.newSource(selected_track, "stream")
		music:setLooping(true)
		music:play()
		music_playing = true
	end
end

function set_timescale(x)
	if timescale_tween then
		timescale_tween:stop()
	end
	tick.timescale = x
end

function jump_to_mouse()
	if play_first == true then
		play_first = false
		enter_sound:stop()
		enter_sound:play()
	end
	set_timescale(1)
	slowmode = false
	local x, y = love.mouse.getPosition()
	local x, y = center:toGame(x, y)
	jump(x, y)
end

function jump(x, y)
	player.speed = 180
	flux.to(player, 4, {speed = 80})
	player.dir = (Vector(x, y) - player.pos).normalized
end

function break_mana()
    bar_shack:setShake(2)
    indicate_bar(Color('#ff5757'), 0.2)
    -- bar_color = Color('#5ce1e6')
	max_mana = max_mana - jumpmanacost
	bar_width = max_mana
	mana = max_mana
	played_indicator = true
	-- played_indicator = false
end

function indicate_bar(color, interval, count)
	function change_color(color, interval, n)
		if n == 0 then return end
		bar_color = color
		flux.to({}, interval, {}):delay(interval)
			:onstart(function () bar_color = Color('#5ce1e6') end)
			:oncomplete(function () change_color(color, interval, n - 1) end)
	end
	change_color(color, interval, count or 4)
end

function place_blob(pos)
	local circle = Circle(pos, 4, Color('#ff5757'), 'fill', 0, 0)
	table.insert(zoo, circle)
	flux.to(circle, 2, {opacity=1})
		:ease('quartin')
		:oncomplete(function ()
			utils.remove(zoo, circle)
			table.insert(zoo, Blob(pos, Vector(math.random()-0.5, math.random()-0.5)))
			local circle = Circle(pos, 4, Color('#ff5757'), 'line', 0.5, 1)
			table.insert(zoo, circle)
			flux.to(circle, 1, {r = 6, opacity = 0})
				:ease('circout')
				:oncomplete(function () utils.remove(zoo, circle) end)
		end)
end

function touchBorder()
	screen:setShake(1)
	bump_sound:stop()
	bump_sound:play()
	if drawtarget == 'tutorial' then
		drawtarget = 'field'
		flux.to({}, 1, {})
			:oncomplete(function ()
				local circle = Circle(Vector(50, 50), 2, Color('#ffde59'), 'line', 0.5, 1)
				table.insert(zoo, circle)
				local tmp = {}
				flux.to(circle, 0.8, {r = 6, opacity = 0})
					:ease('circout')
					:oncomplete(function () utils.remove(zoo, circle) end)
				tmp = {}
				table.insert(zoo, Coin(Vector(50, 50), Vector(0, 0)))
			end)
	end
end