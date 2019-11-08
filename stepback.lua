local Object = require "modules/classic"
local screen = require "modules/shack"
local tick = require "modules/tick"
local flux = require "modules/flux"
local center = require "modules/center"
local Vector = require "modules/brinevector"
local Input = require "modules/Input"

require "entities"

-- init center
center:setupScreen(100, 100)
center:setBorders(100, 100, 100, 100)
center:setMaxWidth(1000)
center:setMaxHeight(1000)
center:apply()
-- init Input
input = Input()
input:bind('w', 'up')
input:bind('a', 'left')
input:bind('s', 'down')
input:bind('d', 'right')


Circle(10, 10)
Circle(20, 30)
Circle(30, 50)
Player(50, 50)


function love.load()
	
end

function love.update(dt)
	for i, item in ipairs(zoo) do
		item:update(dt)
	end
end

function love.draw()
	center:start()
	love.graphics.setLineWidth(4)
	love.graphics.setColor({200, 200, 200, 127})
	love.graphics.rectangle('line', 2, 2, 97, 97)
	for i, item in ipairs(zoo) do
		item:draw()
	end
	center:finish()
end