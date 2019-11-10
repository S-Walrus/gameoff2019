Object = require "modules/classic"
screen = require "modules/shack"
flux = require "modules/flux"
center = require "modules/center"
Vector = require "modules/brinevector"
Input = require "modules/Input"
Color = require "modules/hex2color"
tick = require "modules/tick"
moonshine = require 'moonshine'

require "zoo"

center:setupScreen(100, 100)
center:setMaxRelativeWidth(0.9)
center:setMaxRelativeHeight(0.9)
center:setBorders(60, 0, 0, 0)
center:apply()

screen:setDimensions(love.graphics.getWidth(), love.graphics.getHeight())

tick.framerate = 60

bar_width = 100

function love.load(arg)
    input = Input()
    input:bind('mouse1', 'click')
    font = love.graphics.newFont("numerals.ttf", 98)
    love.graphics.setFont(font)
    effect = moonshine(moonshine.effects.desaturate)
    active = true

    start_new_game()
end



function start_new_game()
	slowmode = false
	mana = 100
	jumpmanacost = 20
	manacostpersec = 160
	score = 0
	active = true

	player = Player(Vector(20, 40), Vector(-4, 1))
	zoo = {}
	table.insert(zoo, player)
	table.insert(zoo, Blob(Vector(50, 50), Vector(-2, -1)))
	table.insert(zoo, Blob(Vector(30, 90), Vector(-2, 7)))
	table.insert(zoo, Blob(Vector(40, 10), Vector(-2, 2)))
	table.insert(zoo, Coin(Vector(80, 30)))
end

function jump(x, y)
	player.speed = 180
	flux.to(player, 4, {speed = 80})
	player.dir = (Vector(x, y) - player.pos).normalized
end



function love.update(dt)
	screen:update(tick.dt)
	flux.update(tick.dt)

	if active then
		for i, entity in ipairs(zoo) do
			entity:update(tick.dt)
		end

		if slowmode then
			mana = mana - manacostpersec * tick.dt
			if mana < 0 then
				tick.timescale = 1
				slowmode = false
				x, y = love.mouse.getPosition()
				x, y = center:toGame(x, y)
				jump(x, y)
			end
		end

		if input:pressed('click') and mana >= jumpmanacost then
			mana = mana - jumpmanacost
			tick.timescale = 0.4
			slowmode = true
		end
		if input:released('click') and slowmode then
			tick.timescale = 1
			slowmode = false
			x, y = love.mouse.getPosition()
			x, y = center:toGame(x, y)
			jump(x, y)
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
    love.graphics.setLineWidth(1)
    love.graphics.setColor(Color('#ffffff', 0.2))
    -- love.graphics.printf(score, 0, 0, 100, 'center')
    love.graphics.setColor(Color('#39eafd'))
    love.graphics.rectangle('fill', 0, -10, mana/100*bar_width, 8)
    love.graphics.setColor(Color("#ffffff"))
    love.graphics.rectangle('line', 0, 0, 100, 100)
    love.graphics.rectangle('line', 0, -10, bar_width, 8)
    center:finish()
end

function love.draw()
	effect(draw)
end

function love.resize(x, y)
	center:resize(x, y)
end