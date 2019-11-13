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

-- global bariables
-- gamestate: {n: nothing, r: run (game started), h: home, p: pause}
gamestate = 'n'

function love.load(arg)
    input = Input()
    input:bind('mouse1', 'click')
    font = love.graphics.newFont("numerals.ttf", 256)
    love.graphics.setFont(font)
    shader = moonshine(moonshine.effects.desaturate)
    active = true
    played_indicator = false
    timescale_tween = nil

    start_new_game()
end



function start_new_game()
	slowmode = false
	bar_width = 100
	mana = 100
	max_mana = 100
	jumpmanacost = 20
	manacostpersec = 160
	score = 0
	active = true
	bar_color = MANA_COLOR
	gamestate = 'r'

	player = Player(Vector(50, 50), Vector(0, 0))
	zoo = {}
	table.insert(zoo, player)
	table.insert(zoo, Blob(Vector(20, 20), Vector(math.random()-0.5, math.random()-0.5)))
	table.insert(zoo, Blob(Vector(20, 80), Vector(math.random()-0.5, math.random()-0.5)))
	table.insert(zoo, Blob(Vector(80, 20), Vector(math.random()-0.5, math.random()-0.5)))
	table.insert(zoo, Blob(Vector(80, 80), Vector(math.random()-0.5, math.random()-0.5)))
	table.insert(zoo, Coin(Vector(love.math.random(80)+10, love.math.random(80)+10)))
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
	max_mana = max_mana - jumpmanacost
	bar_width = max_mana
	mana = max_mana
	played_indicator = true
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



function love.update(dt)
	screen:update(tick.dt)
	bar_shack:update(tick.dt*2)
	flux.update(tick.dt)

	if active then
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
			slowmode = true
		end
		if input:released('click') and slowmode then
			jump_to_mouse()
		end

		if mana <= 2 * jumpmanacost and not played_indicator then
			indicate_bar(Color('#e04646'), 0.1, 3)
			played_indicator = true
		end

		if mana < 0 and max_mana > 2*jumpmanacost then
			break_mana()
		end
	else
		if input:pressed('click') then
			start_new_game()
		end
	end
end

function draw()
    center:start()
	screen:apply()
    love.graphics.clear()
    for i, entity in ipairs(zoo) do
		entity:draw()
	end
	-- love.graphics.setColor(Color('#000000'))
	-- love.graphics.rectangle('fill', -1000, 0, 1000, 100)
	-- love.graphics.rectangle('fill', 100, 0, 1000, 100)
	-- love.graphics.rectangle('fill', -1000, -1000, 2000, 1000)
	-- love.graphics.rectangle('fill', -1000, 100, 2000, 1000)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(Color("#ffffff"))
    love.graphics.rectangle('line', 0, 0, 100, 100)
    love.graphics.setColor(Color('#ffffff', 0.2))
    love.graphics.printf(score, 100, 0, 300, 'left', 0, 0.2)
    love.graphics.push()
    bar_shack:apply()
	    love.graphics.setColor(bar_color)
	    love.graphics.rectangle('fill', 0, -10, mana, 8)
	    love.graphics.setColor(Color("#ffffff"))
	    love.graphics.rectangle('line', 0, -10, bar_width, 8)
    love.graphics.pop()
    center:finish()
end

function love.draw()
	shader(draw)
end

function love.resize(x, y)
	center:resize(x, y)
end