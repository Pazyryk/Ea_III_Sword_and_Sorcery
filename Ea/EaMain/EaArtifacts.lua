-- EaArtifacts
-- Author: Pazyryk
-- DateCreated: 9/16/2012 7:13:33 AM
--------------------------------------------------------------
print("Loading EaArtifacts.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end



---------------------------------------------------------------
-- Local defines
---------------------------------------------------------------
local gArtifacts = gArtifacts
local MapModData = MapModData
local fullCivs =			MapModData.fullCivs


local Floor = math.floor

local Gain = {}		-- Function holders (indexed by artifactID)
local Lose = {}


function UpdateAllArtifacts()
	print("UpdateAllArtifacts")
	for artifactID, artifact in pairs(gArtifacts) do	--cycles through all that have been created
		UpdateArtifact(artifactID)
	end
end

function UpdateArtifact(artifactID)		--must be in city or on person to be "owned" (more complex conditions later)
	Dprint("UpdateArtifact ", artifactID)
	--Test actual ownership based on location; test for ownership change
	local artifact = gArtifacts[artifactID]
	local mod = artifact.mod
	--local artifactInfo = GameInfo.EaArtifacts[artifactID]

	local iOldOwner = artifact.iPlayer
	local iOwner = -1

	if artifact.locationType == "iPerson" then
		local eaPerson = gPeople[iPerson]
		local iPlayer = eaPerson.iPlayer
		if fullCivs[iPlayer] then		--could be barb
			iOwner = iPlayer
		end
	end

	if artifact.locationType == "iPlot" then
		local plot = Map.GetPlotByIndex(artifact.locationIndex)
		local city = plot:GetPlotCity()
		if city then
			iOwner = city:GetOwner()
		end
	end

	artifact.iPlayer = iOwner

	--specific effects
	if iOwner ~= iOldOwner then
		if Gain[artifactID] and iOwner ~= -1 then Gain[artifactID](iOwner, mod) end
		if Lose[artifactID] and iOldOwner ~= -1 then Lose[artifactID](iOldOwner, mod) end
	end

end
LuaEvents.EaArtifactsUpdateArtifact.Add(UpdateArtifact)

---------------------------------------------------------------
-- Specific artifact functions below
---------------------------------------------------------------

local xpValues = {64,32,16,8,4,2,1}
local equusTomePolicyID = {	GameInfoTypes.POLICY_EQUUS_TOME_XP_0064,
							GameInfoTypes.POLICY_EQUUS_TOME_XP_0032,
							GameInfoTypes.POLICY_EQUUS_TOME_XP_0016,
							GameInfoTypes.POLICY_EQUUS_TOME_XP_0008,
							GameInfoTypes.POLICY_EQUUS_TOME_XP_0004,
							GameInfoTypes.POLICY_EQUUS_TOME_XP_0002,
							GameInfoTypes.POLICY_EQUUS_TOME_XP_0001	}

Gain[GameInfoTypes.EA_ARTIFACT_TOME_OF_EQUUS] = function(iPlayer, mod)
	--give mod/2 xp for horse-mounted
	mod = Floor(mod/2)
	if mod > 0 then
		local player = Players[iPlayer]
		for i = 1, 7 do
			local value = xpValues[i]
			if mod >= value then
				player:SetHasPolicy(equusTomePolicyID[i], true)
				mod = mod - value
			end
		end
	end
end

Lose[GameInfoTypes.EA_ARTIFACT_TOME_OF_EQUUS] = function(iPlayer, mod)
	local player = Players[iPlayer]
	for i = 1, 7 do
		player:SetHasPolicy(equusTomePolicyID[i], false)
	end
end

Gain[GameInfoTypes.EA_ARTIFACT_TOME_OF_THE_LEVIATHAN] = function(iPlayer, mod)
	local player = Players[iPlayer]
	player:SetHasPolicy(GameInfoTypes.POLICY_LEVIATHAN_TOME, true)
end

Lose[GameInfoTypes.EA_ARTIFACT_TOME_OF_THE_LEVIATHAN] = function(iPlayer, mod)
	local player = Players[iPlayer]
	player:SetHasPolicy(GameInfoTypes.POLICY_LEVIATHAN_TOME, false)
end