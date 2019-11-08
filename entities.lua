zoo = {}

-- define entities
Entity = Object:extend()
function Entity:new(x, y)
	self.pos = Vector(x, y)
	table.insert(zoo, self)
end

Circle = Entity:extend()
Circle.radius = 4
Circle.color = {200, 200, 200, 255}
function Circle:draw()
	love.graphics.setLineWidth(1)
	love.graphics.setColor(self.color)
	love.graphics.circle('line', self.pos.x, self.pos.y, self.radius)
end
function Circle:update(dt)
	self.pos = self.pos + Vector(10, 0) * dt
end

Player = Entity:extend()
Player.radius = 4
Player.color = {61, 255, 0, 255}
Player.a = 10
Player.start_speed = 10
Player.max_speed = 120
function Player:new(x, y)
	Player.super.new(self, x, y)
	self.velocity = Vector()
end
function Player:draw()
	love.graphics.setLineWidth(1)
	love.graphics.setColor(self.color)
	love.graphics.circle('line', self.pos.x, self.pos.y, self.radius)
end
function Player:update(dt)
	local nv = Vector()
	if input:pressed('up') then
		nv = Vector(0, -1)
	elseif input:pressed('left') then
		nv = Vector(-1, 0)
	elseif input:pressed('down') then
		nv = Vector(0, 1)
	elseif input:pressed('right') then
		nv = Vector(1, 0)
	end
	if (not (nv == Vector())) and
	   ((self.velocity == Vector()) or (not (nv == self.velocity.normalized))) then
		self.velocity = nv * self.start_speed
		print('xxx')
	end

	self.velocity = self.velocity * (1 + self.a * dt)
	self.velocity = self.velocity:trim(self.max_speed)

	self.pos = self.pos + self.velocity * dt
	if self.pos.x < 0 or self.pos.y < 0 or self.pos.x > 99 or self.pos.y > 99 then
		self.pos = self.pos:clamp(Vector(0, 0), Vector(99, 99))
		self.velocity = Vector()
	end
end