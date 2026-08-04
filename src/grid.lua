local Grid = {}
Grid.__index = Grid

-- Creates a new Grid from Tiled map data.
-- mapData is the table returned by a Tiled Lua export.

function Grid.new(mapData)
	local self = setmetatable({}, Grid)

	self.cols = mapData.width -- map width, in tiles
	self.rows = mapData.height -- map height, in tiles
	self.tileWidth = mapData.tilewidth
	self.tileHeight = mapData.tileheight

	self.pixelWidth = self.cols * self.tileWidth
	self.pixelHeight = self.rows * self.tileHeight

	return self
end

-- Converts a grid cell (1-indexed: col 1, row 1 = top-left)
-- to the pixel coordinates of that cell's top-left corner

function Grid:gridToPixel(gx, gy)
	local px = (gx - 1) * self.tileWidth
	local py = (gy - 1) * self.tileHeight
	return px, py
end

-- Converts pixel coordinates to the grid cell they fall inside
function Grid:pixelToGrid(px, py)
	local gx = math.floor(px / self.tileWidth) + 1
	local gy = math.floor(py / self.tileHeight) + 1
	return gx, gy
end

-- Returns true if (gx, gy) is a valid cell with the map bounds.
function Grid:isInBounds(gx, gy)
	return gx >= 1 and gx <= self.cols and gy >= 1 and gy <= self.rows
end

-- Debug drawing: draws grid lines only, no tiles.
-- Lets us visually verify the grid lines up with the map before we draw any art
function Grid:draw()
	love.graphics.setColor(1, 1, 1, 0.3)

	for col = 0, self.cols do
		local x = col * self.tileWidth
		love.graphics.line(x, 0, x, self.pixelHeight)
	end

	for row = 0, self.rows do
		local y = row * self.tileHeight
		love.graphics.line(0, y, self.pixelWidth, y)
	end

	love.graphics.setColor(1, 1, 1, 1) --reset color
end

return Grid
