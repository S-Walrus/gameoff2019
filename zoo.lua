Entity = Object:extend()
function Entity:draw()
	-- pass
end
function Entity:update(dt)
	-- pass
end
function Entity:activate()
	-- pass
end

Body = Entity:extend()
Body.speed = 0
Body.radius = 0
function Body:new(pos, dir)
	self.pos = pos or Vector()
	self.dir = dir or Vector()
	if self.dir then
		self.dir = self.dir.normalized
	end
	self.lastpos = self.pos
end
function Body:update(dt)
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

Player = Body:extend()
Player.speed = 100
Player.radius = 5
function Player:new(pos, dir)
	self.super.new(self, pos, dir)
	self.lastpos = self.pos
end
function Player:update(dt)
	self.super.update(self, dt)
	for i, Body in ipairs(zoo) do
		if not (Body == self) and (Body.pos - self.pos).length < Body.radius+self.radius then
			Body:activate()
		end
	end
end
function Player:draw()
	love.graphics.setColor(Color('#ffcc2f'))
	love.graphics.circle('fill', self.pos.x, self.pos.y, 5)
	love.graphics.circle('fill', self.lastpos.x, self.lastpos.y, 5)
	self.lastpos = self.pos
end

Blob = Body:extend()
Blob.speed = 60
Blob.radius = 4
function Blob:draw()
	love.graphics.setColor(Color('#e04646'))
	love.graphics.circle('fill', self.pos.x, self.pos.y, 4)
	love.graphics.circle('fill', self.lastpos.x, self.lastpos.y, 4)
end
function Blob:activate()
	slowmode = false
	tick.timescale = 1
	active = false
	filler = Circle(player.pos, 0, Color('#e04646'), 'fill')
	table.insert(zoo, filler)
	flux.to(filler, 0.8, {r=100}):ease('quadinout'):oncomplete(start_new_game)
end

Coin = Body:extend()
Coin.radius = 2
function Coin:activate()
	score = score + 1
	mana = math.min(100, mana+40)
	for i, item in ipairs(zoo) do
		if item == self then
			zoo[i] = nil
		end
	end
	table.insert(zoo, Coin(Vector(love.math.random(100), love.math.random(100)),
		Vector(love.math.random(100), love.math.random(100))))
end
function Coin:draw()
	love.graphics.setColor(Color('#39eafd'))
	love.graphics.circle('fill', self.pos.x, self.pos.y, 2)
end

Circle = Entity:extend()
Circle.radius = 0
function Circle:new(pos, r, color, type)
	self.pos = pos or Vector()
	self.r = r or 0
	self.color = color or Color('ffffff')
	self.type = type or 'fill'
end
function Circle:draw()
	love.graphics.setColor(self.color)
	love.graphics.circle(self.type, self.pos.x, self.pos.y, self.r)
end

Rect = Entity:extend()
Rect.radius = 0
function Rect:new(pos, size, color, width, type)
	self.pos = pos or Vector()
	self.size = size or Vector
	self.color = color or Color('ffffff')
	self.width = width or 1
	self.type = type or 'fill'
end
function Rect:draw()
	love.graphics.setColor(self.color)
	love.graphics.setLineWidth(self.width)
	love.graphics.rectangle(self.type, self.pos.x-self.size.x/2,
		self.pos.y-self.size.y/2, self.size.x, self.size.y)
end