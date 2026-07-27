local Grid = require("src.grid")
local Camera = require("src.camera")

local mapData
local grid
local camera

-- Temporary stand-in for the player's position until Step 5 gives us
-- a real player entity. The camera just needs *something* to follow.
local focusX, focusY = 100, 100

-- nil = camera follows `focusX, focusY` normally.
-- otherwise = a cutscene override: { x, y, timer }
local cameraOverride = nil

-- Call this to make the camera pan to a fixed point for `duration` seconds,
-- then automatically return to following the player again.
function focusCameraOn(x, y, duration)
	cameraOverride = { x = x, y = y, timer = duration }
end

function love.load()
	mapData = require("assets.maps.ankgor_watt_intro_level")
	grid = Grid.new(mapData)

	local screenW, screenH = 800, 600
	love.window.setMode(screenW, screenH)
	camera = Camera.new(screenW, screenH)

	-- Quick manual test: press "f" in love.keypressed below to trigger
	-- a cutscene-style focus shift, and "s" to trigger a shake.
end

function love.update(dt)
	if cameraOverride then
		cameraOverride.timer = cameraOverride.timer - dt
		camera:setTarget(cameraOverride.x, cameraOverride.y)
		if cameraOverride.timer <= 0 then
			cameraOverride = nil
		end
	else
		camera:setTarget(focusX, focusY)
	end

	camera:update(dt, grid.pixelWidth, grid.pixelHeight, 5)
end

function love.draw()
	camera:attach()
	grid:draw()
	camera:detach()
end

-- Temporary manual triggers so we can test the camera before the player
-- and any real cutscene triggers exist.
function love.keypressed(key)
	if key == "f" then
		focusCameraOn(1000, 96, 1.5) -- pan somewhere else on the map for 1.5s
	elseif key == "s" then
		camera:shake(0.4, 8)
	end
end
