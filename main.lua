-- import
Object = require "modules/classic"
screen = require "modules/shack"
bar_shack = dofile "modules/shack.lua"
flux = require "modules/flux"
center = require "modules/center"
Vector = require "modules/brinevector"
Input = require "modules/Input"
Color = require "modules/hex2color"
tick = require "modules/tick"
moonshine = require 'moonshine'
main_menu = dofile "modules/hover.lua"

-- constants
MANA_COLOR = Color('#39eafd')
ENEMY_COLOR = Color('#e04646')
PLAYER_COLOR = Color('#ffcc2f')
BORDER_COLOR = Color('#ffffff')
BACKGROUND_COLOR = Color('#000000')

-- in-project extras
utils = require 'utils'
require "zoo"

-- set up modules
center:setupScreen(100, 100)
center:setMaxRelativeWidth(0.9)
center:setMaxRelativeHeight(0.9)
center:setBorders(60, 0, 0, 0)
center:apply()

screen:setDimensions(100, 100)
bar_shack:setDimensions(100, 100)

tick.framerate = 60

main_menu:addArea({14, 28, 86, 40})
	:onMouseEnter(function () flux.to(zoo[1], 0.1, {r=3}) end)
	:onMouseLeave(function () flux.to(zoo[1], 0.1, {r=1.5}) end)
	:onClick(function ()
		gamestate = 's'
		flux.to(zoo[1], 0.6, {r=100})
			:ease('circinout')
			:after(_G, 0.4, {game_transparency=1})
			:ease('sineinout')
			:after({}, 1, {})
			:oncomplete(start_new_game)
	end)
main_menu:addArea({14, 41, 86, 53})
	:onMouseEnter(function () flux.to(zoo[2], 0.1, {r=3}) end)
	:onMouseLeave(function () flux.to(zoo[2], 0.1, {r=1.5}) end)
main_menu:addArea({14, 54, 86, 66})
	:onMouseEnter(function () flux.to(zoo[3], 0.1, {r=3}) end)
	:onMouseLeave(function () flux.to(zoo[3], 0.1, {r=1.5}) end)
	:onClick(function ()
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
drawtarget = 'credits'
zoo = {}

function love.load(arg)
    input = Input()
    input:bind('mouse1', 'click')
    input:bind('r2', 'power')
    numeric_font = love.graphics.newFont("numerals.ttf", 256)
    header_font = love.graphics.newFont("Spartan.ttf", 256)
    body_font = love.graphics.newFont("LibreBaskerville-Regular.ttf", 256)
    italic_font = love.graphics.newFont("LibreBaskerville-Italic.ttf", 256)
    logo_font = love.graphics.newFont("Oswald-Medium.ttf", 256)
    shader = moonshine(moonshine.effects.vignette)
    active = true
    played_indicator = false
    timescale_tween = nil

    -- game_transparency = 1
    -- flux.to(_G, 0.4, {game_transparency=0})
    -- 	:ease('sineinout')
    -- 	:after(0.4, {game_transparency=1})
    -- 	:ease('sineinout')
    -- 	:delay(0.2)
    -- 	:after({}, 0.4, {})
    -- 	:oncomplete(load_menu)

    load_menu()

    -- start_new_game()
end


-- IN-GAME FUNCTOIONS


function load_credits()
	drawtarget = 'credits'
	gamestate = 'm'
	zoo = {}
	game_transparency = 1
	flux.to(_G, 0.4, {game_transparency=0}):ease('sineinout')
end

function load_menu()
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
	bar_color = MANA_COLOR
	gamestate = 's'
	drawtarget = 'field'
	set_timescale(1)

	player = Player(Vector(50, 50), Vector(0, 0))
	zoo = {}
	table.insert(zoo, player)
	table.insert(zoo, Blob(Vector(20, 20), Vector(math.random()-0.5, math.random()-0.5)))
	-- table.insert(zoo, Blob(Vector(20, 80), Vector(math.random()-0.5, math.random()-0.5)))
	-- table.insert(zoo, Blob(Vector(80, 20), Vector(math.random()-0.5, math.random()-0.5)))
	-- table.insert(zoo, Blob(Vector(80, 80), Vector(math.random()-0.5, math.random()-0.5)))
	local circle = Circle(Vector(20, 80), 4, Color('#e04646'), 'fill', 0, 1)
	table.insert(zoo, circle)
	flux.to(circle, 2, {opacity=0})
		:ease('quartinout')
		:oncomplete(function() utils.remove(zoo, circle) end)
	local circle = Circle(Vector(80, 80), 4, Color('#e04646'), 'fill', 0, 1)
	table.insert(zoo, circle)
	flux.to(circle, 2, {opacity=0})
		:ease('quartinout')
		:oncomplete(function() utils.remove(zoo, circle) end)
	local circle = Circle(Vector(80, 20), 4, Color('#e04646'), 'fill', 0, 1)
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
		music = love.audio.newSource("sb_neon.mp3", "stream")
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
    indicate_bar(Color('#e04646'), 0.2)
    -- bar_color = MANA_COLOR
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
			:onstart(function () bar_color = MANA_COLOR end)
			:oncomplete(function () change_color(color, interval, n - 1) end)
	end
	change_color(color, interval, count or 4)
end

function place_blob(pos)
	local circle = Circle(pos, 4, Color('#e04646'), 'fill', 0, 0)
	table.insert(zoo, circle)
	flux.to(circle, 2, {opacity=1})
		:ease('quartin')
		:oncomplete(function ()
			utils.remove(zoo, circle)
			table.insert(zoo, Blob(pos, Vector(math.random()-0.5, math.random()-0.5)))
			local circle = Circle(pos, 4, Color('#e04646'), 'line', 0.5, 1)
			table.insert(zoo, circle)
			flux.to(circle, 1, {r = 6, opacity = 0})
				:ease('circout')
				:oncomplete(function () utils.remove(zoo, circle) end)
		end)
end


-- CALLBACKS


function love.update(dt)
	screen:update(tick.dt)
	bar_shack:update(tick.dt*2)
	flux.update(tick.dt)
	if drawtarget == 'menu' then main_menu:update(center:toGame(love.mouse.getPosition())) end

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
			-- indicate_bar(Color('#e04646'), 0.1, 3)
			bar_color = ENEMY_COLOR
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
    for i, entity in ipairs(zoo) do
		entity:draw()
	end
	-- love.graphics.setColor(Color('#000000'))
	-- love.graphics.rectangle('fill', -1000, 0, 1000, 100)
	-- love.graphics.rectangle('fill', 100, 0, 1000, 100)
	-- love.graphics.rectangle('fill', -1000, -1000, 2000, 1000)
	-- love.graphics.rectangle('fill', -1000, 100, 2000, 1000)
	if drawtarget == 'field' then
	    love.graphics.setLineWidth(1)
	    love.graphics.setColor(Color("#ffffff"))
	    love.graphics.rectangle('line', 0, 0, 100, 100)
	    love.graphics.setColor(Color('#ffffff', 0.2))
	    love.graphics.setFont(numeric_font)
	    love.graphics.printf(score, 100, 0, 300, 'left', 0, 0.2)
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
    love.graphics.setColor(Color('000000', game_transparency))
    love.graphics.rectangle('fill', -1000, -1000, 2000, 2000)
    center:finish()
end

function love.draw()
	-- shader(draw)
	draw()
end

function love.resize(x, y)
	center:resize(x, y)
	shader.resize(x, y)
end