local Camera = {}
Camera.__index = Camera

function Camera.new(screenWidth, screenHeight)
	local self = setmetatable({}, Camera)
	self.x, self.y = 0, 0
	self.screenWidth = screenWidth
	self.screenHeight = screenHeight

	-- What the camera is currently looking at (player, or a cutscene point)
	self.targetX, self.targetY = 0, 0

	-- Shake state
	self.shakeTimer = 0
	self.shakeDuration = 0
	self.shakeMagnitude = 0
	self.shakeOffsetX, self.shakeOffsetY = 0, 0

	return self
end

-- Call every frame with whatever the camera should currently look at.
function Camera:setTarget(x, y)
	self.targetX, self.targetY = x, y
end

-- Moves the camera toward its target, clamps to world bounds, and
-- advances any active shake. worldWidth/worldHeight = grid.pixelWidth/pixelHeight.
-- smoothing (optional): higher = snappier follow, nil = instant snap.
function Camera:update(dt, worldWidth, worldHeight, smoothing)
	local desiredX = self.targetX - self.screenWidth / 2
	local desiredY = self.targetY - self.screenHeight / 2

	if smoothing then
		local t = 1 - math.exp(-smoothing * dt)
		self.x = self.x + (desiredX - self.x) * t
		self.y = self.y + (desiredY - self.y) * t
	else
		self.x, self.y = desiredX, desiredY
	end

	-- Clamp so we never scroll past the map edges
	self.x = math.max(0, math.min(self.x, worldWidth - self.screenWidth))
	self.y = math.max(0, math.min(self.y, worldHeight - self.screenHeight))

	-- Guard: if the world is smaller than the screen, the clamp above
	-- would invert (min > max). Force to 0 in that case.
	if worldWidth < self.screenWidth then
		self.x = 0
	end
	if worldHeight < self.screenHeight then
		self.y = 0
	end

	self:updateShake(dt)
end

-- Starts a shake: lasts `duration` seconds, wobbling up to `magnitude` pixels.
function Camera:shake(duration, magnitude)
	self.shakeDuration = duration
	self.shakeTimer = duration
	self.shakeMagnitude = magnitude
end

function Camera:updateShake(dt)
	if self.shakeTimer > 0 then
		self.shakeTimer = self.shakeTimer - dt

		-- Magnitude decays over the shake's lifetime so it eases out
		local strength = self.shakeMagnitude * math.max(self.shakeTimer / self.shakeDuration, 0)

		self.shakeOffsetX = (love.math.random() * 2 - 1) * strength
		self.shakeOffsetY = (love.math.random() * 2 - 1) * strength
	else
		self.shakeOffsetX, self.shakeOffsetY = 0, 0
	end
end

function Camera:attach()
	love.graphics.push()
	love.graphics.translate(-math.floor(self.x + self.shakeOffsetX), -math.floor(self.y + self.shakeOffsetY))
end

function Camera:detach()
	love.graphics.pop()
end

return Camera
