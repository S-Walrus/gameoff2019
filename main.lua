local Object = require "modules/classic"
local screen = require "modules/shack"
local flux = require "modules/flux"
local center = require "modules/center"
local Vector = require "modules/brinevector"
local Input = require "modules/Input"
local Color = require "modules/hex2color"
local tick = require "modules/tick"

center:setupScreen(100, 100)
center:setBorders(100, 60, 60, 60)
center:apply()

screen:setDimensions(love.graphics.getWidth(), love.graphics.getHeight())

tick.framerate = 60

function love.load(arg)
    input = Input()
    input:bind('mouse1', 'click')
end

slowmode = false
mana = 100
jumpmanacost = 20
manacostpersec = 160



Entity = Object:extend()
Entity.speed = 0
Entity.radius = 0
function Entity:new(pos, dir)
	self.pos = pos or Vector()
	self.dir = dir or Vector()
	if self.dir then
		self.dir = self.dir.normalized
	end
	self.lastpos = self.pos
end
function Entity:activate()
	love.window.close()
end
function Entity:update(dt)
	self.lastpos = self.pos
	self.pos = self.pos + self.dir * self.speed * dt
	if self.pos.x < self.radius then
		self.pos.x = self.radius - (self.pos.x - self.radius)
		self.dir.x = -self.dir.x
		if self:is(Player) then screen:setShake(1) end
	end
	if self.pos.y < self.radius then
		self.pos.y = self.radius - (self.pos.y - self.radius)
		self.dir.y = -self.dir.y
		if self:is(Player) then screen:setShake(1) end
	end
	if self.pos.x > 100-self.radius then
		self.pos.x = 100-self.radius - (self.pos.x - (100-self.radius))
		self.dir.x = -self.dir.x
		if self:is(Player) then screen:setShake(1) end
	end
	if self.pos.y > 100-self.radius then
		self.pos.y = 100-self.radius - (self.pos.y - (100-self.radius))
		self.dir.y = -self.dir.y
		if self:is(Player) then screen:setShake(1) end
	end
end
function Entity:draw()
	-- pass
end

Player = Entity:extend()
Player.speed = 100
Player.radius = 5
function Player:new(pos, dir)
	self.super.new(self, pos, dir)
	self.lastpos = self.pos
end
function Player:update(dt)
	self.super.update(self, dt)
	for i, entity in ipairs(zoo) do
		if not (entity == self) and (entity.pos - self.pos).length < entity.radius+self.radius then
			entity:activate()
		end
	end
end
function Player:draw()
	love.graphics.setColor(Color('#ffcc2f'))
	love.graphics.circle('fill', self.pos.x, self.pos.y, 5)
	love.graphics.circle('fill', self.lastpos.x, self.lastpos.y, 5)
	self.lastpos = self.pos
end

Blob = Entity:extend()
Blob.speed = 60
Blob.radius = 4
function Blob:draw()
	love.graphics.setColor(Color('#e04646'))
	love.graphics.circle('fill', self.pos.x, self.pos.y, 4)
	love.graphics.circle('fill', self.lastpos.x, self.lastpos.y, 4)
end

Coin = Object:extend()
Coin.radius = 2
function Coin:new(pos)
	self.pos = pos
end
function Coin:activate()
	mana = 100
	for i, item in ipairs(zoo) do
		if item == self then
			zoo[i] = nil
		end
	end
	table.insert(zoo, Coin(Vector(love.math.random(100), love.math.random(100))))
end
function Coin:update(dt)
	-- pass
end
function Coin:draw()
	love.graphics.setColor(Color('#39eafd'))
	love.graphics.circle('fill', self.pos.x, self.pos.y, 2)
end

player = Player(Vector(20, 40), Vector(-4, 1))
zoo = {}
table.insert(zoo, player)
table.insert(zoo, Blob(Vector(50, 50), Vector(-2, -1)))
table.insert(zoo, Blob(Vector(30, 90), Vector(-2, 7)))
table.insert(zoo, Blob(Vector(40, 10), Vector(-2, 2)))
table.insert(zoo, Coin(Vector(80, 30)))

function jump(x, y)
	player.speed = 200
	flux.to(player, 4, {speed = 100})
	player.dir = (Vector(x, y) - player.pos).normalized
end



function love.update(dt)
	screen:update(tick.dt)
	flux.update(tick.dt)

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

function love.draw()
    center:start()
	screen:apply()
    love.graphics.clear()
    love.graphics.setLineWidth(1)
    love.graphics.setColor(Color('#39eafd'))
    love.graphics.rectangle('fill', 0, -10, mana, 8)
    love.graphics.setColor(Color("#ffffff"))
    love.graphics.rectangle('line', 0, 0, 100, 100)
    love.graphics.rectangle('line', 0, -10, 100, 8)
    for i, entity in ipairs(zoo) do
		entity:draw()
	end
    center:finish()
end

function love.resize(x, y)
	center:resize(x, y)
end