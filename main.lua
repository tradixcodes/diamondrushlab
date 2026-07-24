local Grid = require("src.grid")

local mapData
local grid

function love.load()
	mapData = require("assets.maps.ankgor_watt_intro_level")
	grid = Grid.new(mapData)
	-- Size the window to exactly fit the map, so the whole grid is visible
	love.window.setMode(grid.pixelWidth, grid.pixelHeight)
end

function love.draw()
	grid:draw()
end
