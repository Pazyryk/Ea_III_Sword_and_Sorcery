-- EaImageScaling
-- Author: Pazyryk
-- DateCreated: 9/4/2011 8:42:43 PM

local IMAGE_SCALING_FACTOR = 1
local screenSizeX, screenSizeY = UIManager:GetScreenSizeVal()

--------------------------------------------------------------
--DynamicImageScaling
--------------------------------------------------------------

local allowedDimensions = {"404x1484","424x1416","448x1340","472x1272","492x1220","520x1152","548x1096","572x1048","604x992","636x944","668x900","700x856","736x816","772x776","816x736","856x700","900x668","944x636","996x604","1044x576","1100x544","1156x520","1216x492","1276x472","1344x448","1412x424","1484x404","1556x384"}
local dimensionsTable = {}
for _, dimensionsText in ipairs(allowedDimensions) do
	local _, _, x, y = string.find(dimensionsText, "^(%d+)x(%d+)$")
	dimensionsTable[dimensionsText] = {x = tonumber(x), y = tonumber(y)}
end

function ScaleImage(style, dds, textRows)
	--This function adjusts leader and popup grids/images for player's screen size while maintaining
	--original (before dds conversion) aspect ratio.
	--Player can adjust image_scaling_factor from 0.5 - 1 to personal preference. 1 uses as much screen as
	--possible, but never expands image beyond its dds resolution.

	--NOTE: Initial size in xml determines how any subsequent dds will be clipped or extended (regardless of
	--any subsequent SetSize, SetTexture or UnloadTexture). Subsequent size adjustments through Controls only
	--strech/warp that image. Therefore, initial xml size MUST exactly match any dds images ever using that
	--context element in the future (through SetTexture, UnloadTexture). However, the image can be dynamically
	--warped (back to original aspect before dds conversion) using SetSize. If these are mostly shrinkages,
	--then quality impact should be low.
	--
	--Mod dds names always have ending like this: "Segoy_0.70_604x860.dds" (or "Segoy_604x860.dds")
	--This means that the dds image is actually 604x860 and that the aspect ratio (before possible warping
	--to fit in standard dds dimensions) was 0.70. The dds dimensions MUST fit one of the ~18 allowed dimensions
	--defined at top of page. The aspect ratio is optional, but if used must be "0.00" format. It is used to
	--precisely warp the image back to its original (before dds conversion) aspect ratio. 
	--
	print ("Scaling image ",style, dds, textRows)

	local _, _, ddsSize = string.find(dds, "_(%d+x%d+)%.dds$")
	local _, _, aspectRatio = string.find(dds, "_(%d%.%d%d)_%d+x%d+%.dds$")	--if nil then keep dds proportions

	if not dimensionsTable[ddsSize] then
		print("!!!! ERROR !!!! Appended size of dds image not allowed", ddsSize)
		return
	end
	local x, y = dimensionsTable[ddsSize].x, dimensionsTable[ddsSize].y

	local imageFrame = "Image"..ddsSize	--this will pick which of the ~18 image elements is used (matches actual dds size)
	
	local scaleX, scaleY = 1, 1
	local scalingFactor = IMAGE_SCALING_FACTOR
	local gridSize, imageSize, imageOffset = {}, {}, {}
	if aspectRatio then
		local aspectAdjust = aspectRatio * y / x	--target versus current aspect
		if aspectAdjust > 1 then
			y = y / aspectAdjust	--reduce y to get target aspect
		else
			x = x * aspectAdjust	--reduce x to get target aspect
		end
	end

	if style == "Leader" then
		local maxX = screenSizeX - 120	--adjustments for this style
		local maxY = screenSizeY - 130
		local gridOffset = {x = 0, y = -50}
		local imageOffset = {x = 0, y = 0}	
		if x > maxX then scaleX = maxX / x end
		if y > maxY then scaleY = maxY / y end
		if scaleX < scalingFactor then scalingFactor = scaleX end
		if scaleY < scalingFactor then scalingFactor = scaleY end
		if scalingFactor < 1 then
			x = x * scalingFactor
			y = y * scalingFactor
		end
		x, y = math.floor(x + 0.5), math.floor(y + 0.5)
		imageSize.x, imageSize.y = x, y
		gridSize.x, gridSize.y = x + 35, y + 87		--adjust for this style
		return gridSize, gridOffset, imageFrame, imageSize, imageOffset
	elseif style == "TextBox" then
		local maxX = screenSizeX - 120	--adjustments for this style
		local maxY = screenSizeY - 50 - textRows * 24
		local gridOffset = {x = 0, y = 0}
		local imageOffset = {x = 0, y = 44}	
		if x > maxX then scaleX = maxX / x end
		if y > maxY then scaleY = maxY / y end
		if scaleX < scalingFactor then scalingFactor = scaleX end
		if scaleY < scalingFactor then scalingFactor = scaleY end
		if scalingFactor < 1 then
			x = x * scalingFactor
			y = y * scalingFactor
		end
		x, y = math.floor(x + 0.5), math.floor(y + 0.5)
		imageSize.x, imageSize.y = x, y
		gridSize.x, gridSize.y = x + 34, y + 96 + textRows * 24
		return gridSize, gridOffset, imageFrame, imageSize, imageOffset

	end
end

