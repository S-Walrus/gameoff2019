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
Body.target_speed = 0
Body.radius = 0
function Body:new(pos, dir)
	self.pos = pos or Vector()
	self.dir = dir or Vector()
	if self.dir then
		self.dir = self.dir.normalized
	end
	self.lastpos = self.pos
	self.speed = 0
	flux.to(self, 1, {speed = self.target_speed}):ease('circin')
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
Player.target_speed = 100
Player.radius = 5
function Player:new(pos, dir)
	self.super.new(self, pos, dir)
	self.lastpos = self.pos
	self.history = {}
	for i=1,4 do table.insert(self.history, self.pos) end
end
function Player:update(dt)
	self.super.update(self, dt)
	for i, Body in ipairs(zoo) do
		if not (Body == self) and (Body.pos - self.pos).length < Body.radius+self.radius then
			Body:activate()
		end
	end
	self:update_history()
end
function Player:draw()
	for i, pos in ipairs(self.history) do
		love.graphics.setColor(Color('#ffcc2f', i/#self.history * 0.6, true))
		love.graphics.circle('fill', pos.x, pos.y, 5)
	end
	love.graphics.setColor(Color('#ffcc2f'))
	love.graphics.circle('fill', self.pos.x, self.pos.y, 5)
	love.graphics.circle('fill', self.lastpos.x, self.lastpos.y, 5)
	self.lastpos = self.pos
end
function Player:update_history()
		table.remove(self.history, 1)
		table.insert(self.history, self.pos)
end

Blob = Body:extend()
Blob.target_speed = 60
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
	flux.to(filler, 0.6, {r=80}):ease('circinout')
end

Coin = Body:extend()
Coin.radius = 2
function Coin:activate()
	score = score + 1
	mana = math.min(max_mana, mana+40)
	played_indicator = false
	utils.remove(zoo, self)
	local circle = Circle(self.pos, self.r, Color('#39eafd'), 'line', 0.5, 1)
	table.insert(zoo, circle)
	local tmp = {}
	flux.to(circle, 0.8, {r = 6, opacity = 0})
		:ease('circout')
		:oncomplete(function () utils.remove(zoo, circle) end)
	tmp = {}
	table.insert(zoo, Coin(Vector(love.math.random(100), love.math.random(100)),
		Vector(love.math.random(80)+10, love.math.random(80)+10)))
	-- timescale_tween = flux.to(tick, 0.02, {timescale = 0.4}):ease('quadinout')
	-- 	:after(0.04, {timescale = 1}):ease('quadin')
	if score == 2 then
		place_blob(Vector(80, 20))
	elseif score == 8 then
		place_blob(Vector(20, 80))
	elseif score == 18 then
		place_blob(Vector(80, 80))
	end
end
function Coin:draw()
	love.graphics.setColor(Color('#39eafd'))
	love.graphics.circle('fill', self.pos.x, self.pos.y, 2)
end

Circle = Entity:extend()
Circle.radius = 0
function Circle:new(pos, r, color, type, width, opacity)
	self.pos = pos or Vector()
	self.r = r or 0
	self.color = color or Color('ffffff')
	self.type = type or 'fill'
	self.width = width or 1
	self.opacity = opacity
end
function Circle:draw()
	love.graphics.setLineWidth(self.width)
	if self.opacity then self.color[4] = self.opacity end
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