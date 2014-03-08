-- EaTableUtils
-- Author: Pazyryk
-- DateCreated: 1/22/2013 6:48:59 PM
--------------------------------------------------------------

--Tables
function Clone(table)
	local newTable = {}
	for key, value in pairs(table) do
		newTable[key] = value
	end
	return newTable
end

function NRArrayAdd(table, value)		--add value to array if not redundant
	local size = #table
	for i = 1, size do
		if table[i] == value then
			return
		end
	end
	table[size + 1] = value
end

function NRArrayRemove(table, value)	--remove value from array if present, assuming all non-redundant values
	local size = #table
	for i = 1, size do
		if table[i] == value then
			for j = i, size - 1 do
				table[j] = table[j + 1]
			end
			table[size] = nil
			return
		end
	end
end

local Rand = Map.Rand
local randomizedArrayIndexes = {}
local integerList = {}
function GetRandomizedArrayIndexes(len)
	for i = 1, len do
		integerList[i] = i
	end
	for i = len, 2, -1 do
		local integerIndex = Rand(i, "hello") + 1
		randomizedArrayIndexes[i] = integerList[integerIndex]
		for j = integerIndex, i - 1 do
			integerList[j] = integerList[j + 1]
		end
	end
	randomizedArrayIndexes[1] = integerList[1]
	for i = #randomizedArrayIndexes, len + 1, -1 do		--trim extras from last call, if any
		randomizedArrayIndexes[i] = nil
	end
	return randomizedArrayIndexes
end

function GetBestOne(list, bReturnKey, bEvaluateKeys, ValueFunction)
	--returns best item or key from list, where ValueFunction generates a value given an item or key
	--if ValueFunction is nil then list items are compared
	local bestKey
	local bestValue = -1000000
	for key, item in pairs(list) do
		local value = ValueFunction and ValueFunction(bEvaluateKeys and key or item) or item
		if bestValue < value then
			bestValue = value
			bestKey = key
		end
	end
	if bReturnKey then
		return bestKey
	end
	return list[bestKey]
end

function GetBestTwo(list, bReturnKeys, bEvaluateKeys, ValueFunction)
	--returns best item (by key) from list, where ValueFunction generates a value given an item
	local firstKey, secondKey
	local firstValue, secondValue = -1000000, -1000000
	for key, item in pairs(list) do
		local value = ValueFunction and ValueFunction(bEvaluateKeys and key or item) or item
		if secondValue < value then
			secondValue = value
			secondKey = key
			if firstValue < secondValue then
				firstValue, secondValue = secondValue, firstValue
				firstKey, secondKey = secondKey, firstKey
			end
		end
	end
	if bReturnKeys then
		return firstKey, secondKey
	end
	return list[firstKey], list[secondKey]
end

function GetBestAsTable(list, number, bReturnKeys, bEvaluateKeys, ValueFunction)
	--returns best number of items (by key) from list, where ValueFunction generates a value given an item; return is a table!
	local keys = {}
	local values = {}
	local index = 0
	local bGrow, bResort = true, true
	for key, item in pairs(list) do
		local value = ValueFunction and ValueFunction(bEvaluateKeys and key or item) or item
		if bGrow then
			index = index + 1
			bGrow = index < number
			keys[index], values[index] = key, value
		elseif values[index] < value then
			keys[index], values[index] = key, value
			bResort = true
		else
			bResort = false
		end
		if bResort then	
			for i = index, 2, -1 do
				local leftShift = i - 1
				if values[leftShift] < values[i] then
					keys[leftShift], keys[i] = keys[i], keys[leftShift]
					values[leftShift], values[i] = values[i], values[leftShift]
				else
					break
				end
			end
		end
	end
	if bReturnKeys then
		return keys
	end
	for i = 1, number do	--reuse values table rather than init new table
		values[i] = list[keys[i] ]
	end
	return values
end

--Sets Operations (all expect arrays)
local Clone = Clone
function Union(table1, table2)
	local newTable = Clone(table1)
	local size1 = #table1
	local size2 = #table2	
	local pos = size1
	for i = 1, size2 do
		local bAdd = true
		for j = 1, size1 do
			if table2[i] == table1[j] then
				bAdd = false
				break
			end
		end
		if bAdd then
			pos = pos + 1
			newTable[pos] = table2[i]
		end
	end
	return newTable
end