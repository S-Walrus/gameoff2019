-- import
Object = require "modules/classic"
screen = require "modules/shack"
bar_shack = require "modules/shack1"
flux = require "modules/flux"
center = require "modules/center"
Vector = require "modules/brinevector"
Input = require "modules/Input"
Color = require "modules/hex2color"
tick = require "modules/tick"

-- constants
MANA_COLOR = Color('#5ce1e6')
ENEMY_COLOR = Color('#ff5757')
PLAYER_COLOR = Color('#ffde59')
BORDER_COLOR = Color('#ffffff')
BACKGROUND_COLOR = Color('#040404')

-- in-project extras
utils = require 'utils'
require "zoo"
require "functions"

-- set up modules
center:setupScreen(100, 100)
center:setMaxRelativeWidth(0.9)
center:setMaxRelativeHeight(0.9)
center:setBorders(60, 0, 0, 0)
center:apply()

screen:setDimensions(100, 100)
bar_shack:setDimensions(100, 100)

main_menu = require "modules/hover"
main_menu:addArea({14, 28, 86, 40})
	:onMouseEnter(function () flux.to(zoo[1], 0.1, {r=3}) end)
	:onMouseLeave(function () flux.to(zoo[1], 0.1, {r=1.5}) end)
	:onClick(function ()
		enter_sound:stop()
		enter_sound:play()
		gamestate = 's'
		flux.to(zoo[1], 0.6, {r=100})
			:ease('circinout')
			:after(_G, 0.4, {game_transparency=1})
			:ease('sineinout')
			:after({}, 0.8, {})
			:oncomplete(start_new_game)
	end)
main_menu:addArea({14, 41, 86, 53})
	:onMouseEnter(function () flux.to(zoo[2], 0.1, {r=3}) end)
	:onMouseLeave(function () flux.to(zoo[2], 0.1, {r=1.5}) end)
	:onClick(function ()
		enter_sound:stop()
		enter_sound:play()
		gamestate = 's'
		flux.to(zoo[2], 0.3, {r=1})
			:ease('sineout')
		flux.to(_G, 0.2, {game_transparency=1})
			:ease('sineinout')
			:after({}, 0, {})
			:oncomplete(load_shelf)
		end)
main_menu:addArea({14, 54, 86, 66})
	:onMouseEnter(function () flux.to(zoo[3], 0.1, {r=3}) end)
	:onMouseLeave(function () flux.to(zoo[3], 0.1, {r=1.5}) end)
	:onClick(function ()
		enter_sound:stop()
		enter_sound:play()
		gamestate = 's'
		flux.to(zoo[3], 0.3, {r=1})
			:ease('sineout')
		flux.to(_G, 0.2, {game_transparency=1})
			:ease('sineinout')
			:after({}, 0, {})
			:oncomplete(load_credits)
		end)
main_menu:addArea({14, 67, 86, 79})
	:onMouseEnter(function () flux.to(zoo[4], 0.1, {r=3}) end)
	:onMouseLeave(function () flux.to(zoo[4], 0.1, {r=1.5}) end)
	:onClick(function ()
		enter_sound:stop()
		enter_sound:play()
		gamestate = 's'
		flux.to(zoo[4], 0.3, {r=1})
			:ease('sineout')
		flux.to(_G, 0.2, {game_transparency=1})
			:ease('sineinout')
			:after({}, 0.4, {})
			:oncomplete(load_farewell)
		end)

shelf = require "modules/hover1"
shelf:addArea({-20, 0, 20, 100})
	:onClick(function ()
		if shelf_index > 1 then
			shelf_index = shelf_index - 1
			flux.to(_G, 0.2, {shelf_bias=-60*shelf_index})
				:ease('quadinout')
		end
	end)
	:onMouseEnter(function ()
		if shelf_index > 1 then
			flux.to(_G, 0.1, {shelf_bias=-60*shelf_index+5})
				:ease('quadinout')
		end
	end)
	:onMouseLeave(function ()
		flux.to(_G, 0.2, {shelf_bias=-60*shelf_index})
			:ease('quadinout')
	end)
shelf:addArea({80, 0, 120, 100})
	:onClick(function ()
		if shelf_index < #music_data then
			shelf_index = shelf_index + 1
			flux.to(_G, 0.2, {shelf_bias=-60*shelf_index})
				:ease('quadinout')
		end
	end)
	:onMouseEnter(function ()
		if shelf_index < #music_data then
			flux.to(_G, 0.1, {shelf_bias=-60*shelf_index-5})
				:ease('quadinout')
		end
	end)
	:onMouseLeave(function ()
		flux.to(_G, 0.2, {shelf_bias=-60*shelf_index})
			:ease('quadinout')
	end)
shelf:addArea({20, 0, 80, 100})
	:onClick(function ()
		mana_sound:stop()
		mana_sound:play()
		selected_track = music_data[shelf_index].path
		selected_track_index = shelf_index
	end)

-- global bariables
--[[
gamestate: {
	s: scene --DON'T INTERRUPT--,
	r: run (game started) --GAMEPLAY--,
	m: menu --UI--
}
]]--
gamestate = 's'
game_transparency = 0
music_playing = false
music = nil
drawtarget = 'tutorial'
zoo = {}
selected_track = 'sb_vengeance.mp3'
selected_track_index = 4
shelf_index = 2
shelf_bias = -120


function love.load(arg)
    input = Input()
    input:bind('mouse1', 'click')
    input:bind('mouse2', 'back')
    input:bind('r2', 'power')
    numeric_font = love.graphics.newFont("numerals.ttf", 256)
    header_font = love.graphics.newFont("Spartan.ttf", 256)
    body_font = love.graphics.newFont("LibreBaskerville-Regular.ttf", 256)
    italic_font = love.graphics.newFont("LibreBaskerville-Italic.ttf", 256)
    logo_font = love.graphics.newFont("Oswald-Medium.ttf", 256)
    lmb_img = love.graphics.newImage("1.png")
    rmb_img = love.graphics.newImage("2.png")
    mouse_img = love.graphics.newImage("3.png")
    love_logo = love.graphics.newImage("love.jpg")
    gradient = love.graphics.newImage("gradient.png")
    enter_sound = love.audio.newSource("res/synth-cut-032_A_minor.wav", "static")
    leave_sound = love.audio.newSource("res/bellcrush_E_minor.wav", "static")
    mana_sound = love.audio.newSource("res/fingersnap_G#_major.wav", "static")
    mana_sound:setVolume(0.8)
    bump_sound = love.audio.newSource("res/digital-distorted-kick_A_minor.wav", "static")
    bump_sound:setVolume(0.3)
    fail_sound = love.audio.newSource("res/strong-keys_F#_major.wav", "static")
    fail_sound:setVolume(0.2)
    push_sound = love.audio.newSource("res/rock-kick-soft-1.wav", "static")
    active = true
    played_indicator = false
    timescale_tween = nil

    music_data = {
    {
		name = 'Silence',
		path = nil,
		unlock_score = 0,
		cover = love.graphics.newImage('cover_placeholder.png')
	},
    {
		name = 'Utopia',
		path = 'sb_utopia.mp3',
		unlock_score = 0,
		cover = love.graphics.newImage('Utopia-wide-700x329.jpg')
	},
	{
		name = 'Neon',
		path = 'sb_neon.mp3',
		unlock_score = 0,
		cover = love.graphics.newImage('cover_neon.jpg')
	},
	{
		name = 'Vengeance',
		path = 'sb_vengeance.mp3',
		unlock_score = 0,
		cover = love.graphics.newImage('Vengeance-wide-01-700x329.jpg')
	},
	{
		name = 'Sanctum',
		path = 'sb_sanctum.mp3',
		unlock_score = 0,
		cover = love.graphics.newImage('Sanctum-wide-01-700x329.jpg')
	},
	{
		name = 'Machinery of the Stars',
		path = 'sb_machineryofthestars.mp3',
		unlock_score = 0,
		cover = love.graphics.newImage('Machinery-of-the-Stars-wide-01-700x329.jpg')
	}
}

    -- game_transparency = 1
    -- flux.to(_G, 0.4, {game_transparency=0})
    -- 	:ease('sineinout')
    -- 	:after(0.4, {game_transparency=1})
    -- 	:ease('sineinout')
    -- 	:delay(0.2)
    -- 	:after({}, 0.4, {})
    -- 	:oncomplete(load_menu)

    load_welcome()

    -- start_new_game()
end


-- CALLBACKS


function love.update(dt)
	-- if tick.dt > 0.03 then tick.dt = 0.03 end
	screen:update(tick.dt)
	bar_shack:update(tick.dt*2)
	flux.update(tick.dt)

	if not (gamestate == 's') then
		if drawtarget == 'menu' then main_menu:update(center:toGame(love.mouse.getPosition())) end
		if drawtarget == 'shelf' then shelf:update(center:toGame(love.mouse.getPosition())) end

		if (drawtarget == 'credits' or drawtarget == 'shelf') and input:pressed('back') then
			leave_sound:stop()
			leave_sound:play()
			gamestate = 's'
			flux.to(_G, 0.2, {game_transparency=1})
				:ease('sineinout')
				:oncomplete(load_menu)
		end
		if gamestate == 'r' and input:pressed('back') then
			leave_sound:stop()
			leave_sound:play()
			gamestate = 's'
			flux.to(_G, 0.2, {game_transparency=1})
				:ease('sineinout')
				:oncomplete(load_menu)
		end
	end

	if active == true and gamestate == 'r' then
		for i, entity in ipairs(zoo) do
			entity:update(tick.dt)
		end

		if slowmode then
			mana = mana - manacostpersec * tick.dt
			if mana <= 0 and max_mana <= 2*jumpmanacost then jump_to_mouse() end
		end

		if input:pressed('click') and
				(mana > jumpmanacost or max_mana > 2*jumpmanacost) then
			mana = mana - jumpmanacost
			set_timescale(0.4)
			-- set_timescale(0.5) TODO add effect indicating slowmo
			-- timescale_tween = flux.to(tick, 0.2, {timescale=0.3})--:ease('quadout')
			slowmode = true
		end
		if input:released('click') and slowmode then
			jump_to_mouse()
		end

		if mana <= 2 * jumpmanacost and not played_indicator then
			-- indicate_bar(Color('#ff5757'), 0.1, 3)
			bar_color = Color('#ff5757')
			played_indicator = true
		end

		if mana < 0 and max_mana > 2*jumpmanacost then
			break_mana()
		end
	elseif gamestate == 'r' then
		if input:pressed('click') then
			gamestate = 's'
			flux.to(_G, 0.2, {game_transparency=1})
				:ease('sineinout')
				:oncomplete(start_new_game)
		end
	end
end

function draw()
    center:start()
	screen:apply()
    love.graphics.clear(Color('#040404'))
    if drawtarget == 'menu' then
		love.graphics.setColor(Color('#ffffff'))
		love.graphics.setFont(header_font)
		love.graphics.printf("BORDERED", 0, 10, 100 * 20, 'center', 0, 0.05)
		love.graphics.setFont(body_font)
		love.graphics.printf("Dive into", 14, 28, 100 * 20/0.75, "left", 0, 0.05*0.75)
		love.graphics.printf("Music shelf", 14, 41, 100 * 20/0.75, "left", 0, 0.05*0.75)
		love.graphics.printf("Credits", 14, 54, 100 * 20/0.75, "left", 0, 0.05*0.75)
		love.graphics.printf("Leave", 14, 67, 100 * 20/0.75, "left", 0, 0.05*0.75)
		-- love.graphics.setLineWidth(3)
		-- love.graphics.line(92, 52, 92, 84)
		-- love.graphics.line(93.5, 84, 60, 84)
	end
	if drawtarget == 'credits' then
		love.graphics.setColor(Color('#ffffff'))
		love.graphics.setFont(body_font)
		love.graphics.printf("Semyon Entsov", 14, 18, 100*20/0.75, "left", 0, 0.05*0.66)
		love.graphics.printf("Music by Scott Buckley", 14, 46, 100*20*3, "left", 0, 0.05*0.66)
		love.graphics.setFont(italic_font)
		love.graphics.printf("game by", 14, 10, 100*20/0.75, "left", 0, 0.05*0.50)
		love.graphics.printf("right click to return", 14, 76, 100*20/0.75, "left", 0, 0.05*0.50)
		love.graphics.setFont(header_font)
		love.graphics.setColor(Color('#ffde59'))
		love.graphics.printf("a.k.a. swalrus", 35, 30, 100*20/0.75, "left", 0, 0.05*0.50)
		love.graphics.setColor(Color('#5ce1e6'))
		love.graphics.printf("– www.scottbuckley.com.au", 14, 58, 100*20*3, "left", 0, 0.05*0.50)
	end
	if drawtarget == 'welcome' then
		love.graphics.setColor(Color('#ffffff'))
		love.graphics.draw(lmb_img, 30, 30, 0, 0.04, 0.04, 250, 250)
		love.graphics.draw(rmb_img, 30, 55, 0, 0.04, 0.04, 250, 250)
		love.graphics.setFont(header_font)
		love.graphics.setColor(Color('#ffde59'))
		love.graphics.printf("JUMP", 50, 28, 100*20/0.75, "left", 0, 0.05*0.50)
		love.graphics.setColor(Color('#5ce1e6'))
		love.graphics.printf("LEAVE", 50, 53, 100*20/0.75, "left", 0, 0.05*0.50)
	end
	if drawtarget == 'farewell' then
		love.graphics.setColor(Color('#ffffff'))
		love.graphics.setFont(body_font)
		love.graphics.printf("Good luck!", 0, 18, 100*20/0.75, "center", 0, 0.05*0.75)
	end
	if drawtarget == 'shelf' then
		love.graphics.setColor(Color('#ffffff'))
		for i, track in ipairs(music_data) do
			love.graphics.setColor(Color('#ffffff'))
			love.graphics.draw(track.cover, 25 + 60 * i + shelf_bias, 15, 0, 50/track.cover:getWidth())
			love.graphics.setFont(body_font)
			love.graphics.setColor(Color('#ffffff', 0.8))
			love.graphics.printf(track.name, 25 + 60 * i + shelf_bias, 70, 50*20/0.50, "center", 0, 0.05*0.50)
			love.graphics.setColor(Color('#5ce1e6'))
			love.graphics.setFont(header_font)
			if track.name == "Machinery of the Stars" then
				love.graphics.printf("SCOTT BUCKLEY", 25 + 60 * i + shelf_bias, 88, 50*20/0.25, "center", 0, 0.05*0.25)
			elseif track.name == "Silence" then
				love.graphics.printf("Nobody", 25 + 60 * i + shelf_bias, 80, 50*20/0.25, "center", 0, 0.05*0.25)
			else
				love.graphics.printf("SCOTT BUCKLEY", 25 + 60 * i + shelf_bias, 80, 50*20/0.25, "center", 0, 0.05*0.25)
			end
		end
		love.graphics.setColor(Color('#ffde59'))
		love.graphics.setLineWidth(3)
		love.graphics.rectangle('line', 26.5 + 60 * selected_track_index + shelf_bias, 16.5, 47, 47)
		love.graphics.draw(gradient, 25, 0, 0, -25/gradient:getWidth(), 100/gradient:getHeight())
		love.graphics.draw(gradient, 75, 0, 0, 25/gradient:getWidth(), 100/gradient:getHeight())
		love.graphics.setColor(Color('#040404'))
		love.graphics.rectangle('fill', -1000, 0, 1000, 100)
		love.graphics.rectangle('fill', 100, 0, 1000, 100)
	end
    for i, entity in ipairs(zoo) do
		entity:draw()
	end
	-- love.graphics.setColor(Color('#040404'))
	-- love.graphics.rectangle('fill', -1000, 0, 1000, 100)
	-- love.graphics.rectangle('fill', 100, 0, 1000, 100)
	-- love.graphics.rectangle('fill', -1000, -1000, 2000, 1000)
	-- love.graphics.rectangle('fill', -1000, 100, 2000, 1000)
	if drawtarget == 'field' then
	    love.graphics.setLineWidth(1)
	    love.graphics.setColor(Color("#ffffff"))
	    love.graphics.rectangle('line', 0, 0, 100, 100)
	    love.graphics.setFont(numeric_font)
	    love.graphics.setColor(Color('#ffffff', 0.2))
	    love.graphics.printf(score, 100, 0, 300, 'left', 0, 0.2)
	    love.graphics.setColor(Color('#ffffff', center_score_opacity))
		love.graphics.draw(lmb_img, 30, 30, 0, 0.04, 0.04, 250, 250)
		love.graphics.draw(rmb_img, 30, 65, 0, 0.04, 0.04, 250, 250)
		love.graphics.setFont(header_font)
		love.graphics.printf("RESTART", 50, 28, 100*20/0.75, "left", 0, 0.05*0.50)
		love.graphics.printf("LEAVE", 50, 63, 100*20/0.75, "left", 0, 0.05*0.50)
	    love.graphics.push()
	    bar_shack:apply()
		    love.graphics.setColor(bar_color)
		    love.graphics.rectangle('fill', 0, -10, mana, 8)
		    love.graphics.setColor(Color("#ffffff"))
		    love.graphics.rectangle('line', 0, -10, bar_width, 8)
	    love.graphics.pop()
	end
	if drawtarget == 'logo' then
		love.graphics.setFont(logo_font)
		love.graphics.setColor(Color('#ffffff'))
		love.graphics.printf('swalrus', 0, 38, 100/0.04, "center", 0, 0.04)
	end
    love.graphics.setColor(Color('#040404', game_transparency))
    love.graphics.rectangle('fill', -1000, -1000, 2000, 2000)
    center:finish()
end

function love.draw()
	draw()
end

function love.resize(x, y)
	center:resize(x, y)
end