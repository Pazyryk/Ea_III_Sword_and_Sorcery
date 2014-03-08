-- EaPlotUtils
-- Author: Pazyryk
-- DateCreated: 8/16/2011 7:43:19 PM
--------------------------------------------------------------

-- this file can be included from multiple states, avoid any Context references

local iW, iH = Map.GetGridSize()

function GetPlotIndexFromXY(x, y)
	return y * iW + x
end

function GetXYFromPlotIndex(iPlot)
	local Floor = math.floor
	return iPlot % iW, Floor(iPlot / iW)
end

local bWrapX, bWrapY = Map.IsWrapX(), Map.IsWrapY()
local yOffsets, xOffsetsEvenY, xOffsetsOddY = {}, {}, {}	--contain tables indexed by radius; created and kept as needed
local tempIdx, sortedOffsetsX, sortedOffsetsY = {}, {}, {}	--used for sorting when approach plot given (indexed by radius; created and kept as needed)

function PlotToRadiusIterator(x, y, radius, myX, myY, bExcludeCenter)
	--  myX, myY (optional & expensive) specify an "approach" coordinate that will cause return values to be sorted by nearest-first
	local Distance = Map.PlotDistance
	local Floor = math.floor
	local yOffset = yOffsets[radius]
	if not yOffset then	--calculate and keep offsets for this radius (radius up to half map size)
		local centerX = Floor(iW / 2)
		local centerYeven = Floor(iH / 4) * 2
		local centerYodd = centerYeven + 1
		local evenPos, oddPos = 1, 1
		yOffsets[radius], xOffsetsEvenY[radius], xOffsetsOddY[radius] = {}, {}, {}
		for testYoffset = -radius, radius do
			local testYeven = centerYeven + testYoffset
			local testYodd = centerYodd + testYoffset
			for textXoffset = -radius, radius do
				local testX = centerX + textXoffset
				if Distance(centerX, centerYeven, testX, testYeven) <= radius then
					xOffsetsEvenY[radius][evenPos] = textXoffset
					yOffsets[radius][evenPos] = testYoffset
					evenPos = evenPos + 1
				end
				if Distance(centerX, centerYodd, testX, testYodd) <= radius then
					xOffsetsOddY[radius][oddPos] = textXoffset
					oddPos = oddPos + 1
				end
			end
		end
		yOffset = yOffsets[radius]
	end

	local xOffset
	if y % 2 == 0 then -- y is even
		xOffset = xOffsetsEvenY[radius]
	else				 -- y is odd
		xOffset = xOffsetsOddY[radius]
	end

	local number = #yOffset
	if myX then		--sort returned values by direction I am comming from
		local Sort = table.sort
		local sortIdx, sortX, sortY = tempIdx[radius], sortedOffsetsX[radius], sortedOffsetsY[radius]
		if not sortIdx then
			sortIdx, sortX, sortY = {}, {}, {}
			tempIdx[radius], sortedOffsetsX[radius], sortedOffsetsY[radius] = sortIdx, sortX, sortY
			for i = 1, number do
				sortIdx[i] = i
			end
		end

		Sort(sortIdx, function(a, b)
							local Distance = Map.PlotDistance
							local myX, myY, xOffset, yOffset = myX, myY, xOffset, yOffset
							return Distance(myX, myY, x + xOffset[a], y + yOffset[a]) < Distance(myX, myY, x + xOffset[b], y + yOffset[b])
						end)
		for i = 1, number do
			local sortIndex = sortIdx[i]
			sortX[i] = xOffset[sortIndex]
			sortY[i] = yOffset[sortIndex]
		end
		xOffset, yOffset = sortX, sortY		--use sorted table instead of unsorted table
	end

	local i = 0
	return function()
		local x, y, bWrapY, bWrapY, number, xOffest, yOffset = x, y, bWrapY, bWrapY, number, xOffest, yOffset	--for speed
		while i < number do
			i = i + 1
			local xAdj = x + xOffset[i]
			local yAdj = y + yOffset[i]
			if bWrapX then
				if xAdj < 0 then
					xAdj = xAdj + iW
				elseif xAdj >= iW then
					xAdj = xAdj - iW
				end
			end
			if bWrapY then
				if yAdj < 0 then
					yAdj = yAdj + iH
				elseif yAdj >= iH then
					yAdj = yAdj - iH
				end
			end
			if yAdj >= 0 and yAdj < iH and xAdj >= 0 and xAdj < iW and (not bExcludeCenter or x ~= xAdj or y ~= yAdj) then		--only return a valid map coordinant
				return xAdj, yAdj
			end
		end
	end
end

