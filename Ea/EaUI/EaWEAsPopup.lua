-- EaWEAsPopup
-- Author: Pazyryk
-- DateCreated: 9/10/2012 9:18:52 PM
--------------------------------------------------------------
print("Loading EaWEAsPopup.lua")

include( "IconSupport" )
include( "InstanceManager" )
include("EaTextUtils.lua")

MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT

MapModData.realCivs = MapModData.realCivs or {}
MapModData.fullCivs = MapModData.fullCivs or {}


--shared
local realCivs =					MapModData.realCivs
local fullCivs =					MapModData.fullCivs

--cached table
local modNames = {}
for modInfo in GameInfo.EaModifiers() do
	modNames[modInfo.ID] = Locale.Lookup(modInfo.Description)
end
local numMods = #modNames
local g_spellModSort = {{},{},{},{},{},{},{},{}}

g_Tabs = {	Wonders = {		Panel = Controls.WondersPanel,
							SelectHighlight = Controls.WondersSelectHighlight	},
	
			Epics =	{		Panel = Controls.EpicsPanel,
							SelectHighlight = Controls.EpicsSelectHighlight		},
	
			Artifacts = {	Panel = Controls.ArtifactsPanel,
							SelectHighlight = Controls.ArtifactsSelectHighlight	}	}

local g_WondersManager = InstanceManager:new("WonderInstance", "Base", Controls.WondersStack);
local g_EpicsManager = InstanceManager:new( "EpicInstance", "Base", Controls.EpicsStack);
local g_ArtifactsManager = InstanceManager:new( "ArtifactInstance", "Base", Controls.ArtifactsStack);

g_CurrentTab = "Wonders"

function Show()
	ContextPtr:SetHide(false)
	TabSelect(g_CurrentTab)
end

function TabSelect(tab)
	for i,v in pairs(g_Tabs) do
		local bHide = i ~= tab
		v.Panel:SetHide(bHide)
		v.SelectHighlight:SetHide(bHide)
	end
	g_CurrentTab = tab
	g_Tabs[tab].RefreshContent()
end
Controls.TabButtonWonders:RegisterCallback( Mouse.eLClick, function() TabSelect("Wonders") end)
Controls.TabButtonEpics:RegisterCallback( Mouse.eLClick, function() TabSelect("Epics") end )
Controls.TabButtonArtifacts:RegisterCallback( Mouse.eLClick, function() TabSelect("Artifacts") end )

g_Tabs.Wonders.RefreshContent = function()
	g_WondersManager:ResetInstances()
	
	local wonders = {}
	local iActivePlayer = Game.GetActivePlayer()
	local activePlayer = Players[iActivePlayer]

	for id, wonder in pairs(gT.gWonders) do
		local wonderInfo = GameInfo.EaWonders[id]
		if wonder.iPlot then
			local wonderName = Locale.Lookup(wonderInfo.Description)
			LuaEvents.EaActionsSetWEAHelp(GameInfoTypes[wonderInfo.EaAction], wonder.mod)
			local eaActionHelp = MapModData.text	--set in EaActions system
			local wonderDesc = string.gsub(eaActionHelp, "%[NEWLINE%]", "; ")
			local plot = Map.GetPlotByIndex(wonder.iPlot)
			local iOwner = plot:GetOwner()		--will be some special ownership situations later
			local wonderOwner = (iOwner == iActivePlayer) and "You" or Locale.Lookup(PreGame.GetCivilizationShortDescription(iOwner))
			local wonderCity = plot:GetPlotCity()
			local wonderLocation
			if wonderCity then
				wonderLocation = wonderCity:GetName()
			else
				local iCity = plot:GetCityPurchaseID()			--get city that owns this plot
				wonderCity = Players[plot:GetOwner()]:GetCityByID(iCity)
				if wonderCity then
					wonderLocation = "Near " .. wonderCity:GetName()
				else
					wonderLocation = "unknown"
				end
			end
			--local wonderMouseOver = "Wonder modifier from builder: " .. wonder.mod .. "[NEWLINE]" .. eaActionHelp

			table.insert(wonders, {	wonderName = wonderName,
									wonderOwner = wonderOwner,
									wonderLocation = wonderLocation,
									wonderDesc = wonderDesc,
									--wonderMouseOver = wonderMouseOver,
									wonderIconIndex = wonderInfo.IconIndex,
									wonderIconAtlas = wonderInfo.IconAtlas	})

		else	--This is a multiple instance wonder, such as an Arcane Tower
			local wonderType = wonderInfo.Type
			for id2, wonderInstance in pairs(wonder) do
				local plot = Map.GetPlotByIndex(wonderInstance.iPlot)
				local wonderName, wonderOwner, wonderDesc
				if wonderType == "EA_WONDER_ARCANE_TOWER" then
					wonderName = plot:GetScriptData()
					local iOwner = plot:GetOwner()		--will be some special ownership situations later
					wonderOwner = (iOwner == iActivePlayer) and "You" or Locale.Lookup(PreGame.GetCivilizationShortDescription(iOwner))

					local i = 0
					for modID = numMods - 7, numMods do
						i = i + 1
						g_spellModSort[i].mod = wonderInstance[modID]
						g_spellModSort[i].name = modNames[modID]
					end
					table.sort(g_spellModSort, function(a, b) return b.mod < a.mod end)
					wonderDesc = "Modifies spells: "
					for i = 1, 7 do
						wonderDesc = wonderDesc .. g_spellModSort[i].name .. " " .. g_spellModSort[i].mod .. ", "
					end
					wonderDesc = wonderDesc .. g_spellModSort[8].name .. " " .. g_spellModSort[8].mod
				else
					error("Unknown mulitple instance wonder (or perhaps a wonder was missing iPlot for some reason); id = " .. id)
				end
				local wonderCity = plot:GetPlotCity()
				local wonderLocation
				if wonderCity then
					wonderLocation = wonderCity:GetName()
				else
					local iCity = plot:GetCityPurchaseID()					--get city that owns this plot
					wonderCity = Players[plot:GetOwner()]:GetCityByID(iCity)
					if wonderCity then
						wonderLocation = "Near " .. wonderCity:GetName()
					else
						wonderLocation = "unknown"
					end
				end
				--local wonderMouseOver = "Wonder modifier from builder: " .. wonder.mod .. "[NEWLINE]" .. eaActionHelp

				table.insert(wonders, {	wonderName = wonderName,
										wonderOwner = wonderOwner,
										wonderLocation = wonderLocation,
										wonderDesc = wonderDesc,
										--wonderMouseOver = wonderMouseOver,
										wonderIconIndex = wonderInfo.IconIndex,
										wonderIconAtlas = wonderInfo.IconAtlas	})

			end
		end
	end

	if #wonders > 0 then
		Controls.NoWonders:SetHide(true)
		Controls.WondersScrollPanel:SetHide(false)

		table.sort(wonders, WondersSort)

		for i,v in ipairs(wonders) do
			
			--print(v.wonderName,v.wonderIconIndex,v.wonderIconAtlas)

			local wonderEntry = g_WondersManager:GetInstance()
			wonderEntry.WonderName:SetText(v.wonderName)
			wonderEntry.WonderOwner:SetText(v.wonderOwner)
			wonderEntry.WonderLocation:SetText(v.wonderLocation)
			wonderEntry.WonderDescription:SetText(v.wonderDesc)
			IconHookup(v.wonderIconIndex, 45, v.wonderIconAtlas, wonderEntry.WonderIcon)
		end
		
		Controls.WondersStack:CalculateSize()
		Controls.WondersStack:ReprocessAnchoring()
		Controls.WondersScrollPanel:CalculateInternalSize()

	else
		Controls.WondersScrollPanel:SetHide(true)
		Controls.NoWonders:SetHide(false)
	end


end

function WondersSort(a, b)		--by owner, city, then wonder
	if a.wonderOwner == b.wonderOwner then
		if a.wonderLocation == b.wonderLocation then
			return Locale.Compare(a.wonderName, b.wonderName) == -1
		else
			return Locale.Compare(a.wonderLocation, b.wonderLocation) == -1
		end
	elseif a.wonderOwner == "You" then
		return true
	elseif b.wonderOwner == "You" then
		return false
	else
		return Locale.Compare(a.wonderOwner, b.wonderOwner) == -1
	end
end


g_Tabs.Epics.RefreshContent = function()
	g_EpicsManager:ResetInstances()
	
	local epics = {}
	local iActivePlayer = Game.GetActivePlayer()
	local activePlayer = Players[iActivePlayer]

	for id, epic in pairs(gT.gEpics) do
		local epicInfo = GameInfo.EaEpics[id]
		LuaEvents.EaActionsSetWEAHelp(GameInfoTypes[epicInfo.EaAction], epic.mod)
		local iOwner = epic.iPlayer
		local epicOwner = (iOwner == iActivePlayer) and "You" or Locale.Lookup(PreGame.GetCivilizationShortDescription(iOwner))

		local eaActionHelp = MapModData.text	--set in EaActions system
		--local wonderMouseOver = "Wonder modifier from builder: " .. wonder.mod .. "[NEWLINE]" .. eaActionHelp
		local epicDesc = string.gsub(eaActionHelp, "%[NEWLINE%]", "; ")

		table.insert(epics, {	epicName = Locale.Lookup(epicInfo.Description),
								epicOwner = epicOwner,
								epicDesc = epicDesc,
								epicIconIndex = epicInfo.IconIndex,
								epicIconAtlas = epicInfo.IconAtlas	})
	end

	if #epics > 0 then
		Controls.NoEpics:SetHide(true)
		Controls.EpicsScrollPanel:SetHide(false)

		table.sort(epics, EpicsSort)

		for i,v in ipairs(epics) do
			local epicEntry = g_EpicsManager:GetInstance()
			epicEntry.EpicName:SetText(v.epicName)
			epicEntry.EpicOwner:SetText(v.epicOwner)
			epicEntry.EpicDescription:SetText(v.epicDesc)
			IconHookup(v.epicIconIndex, 45, v.epicIconAtlas, epicEntry.EpicIcon)
		end
		
		Controls.EpicsStack:CalculateSize()
		Controls.EpicsStack:ReprocessAnchoring()
		Controls.EpicsScrollPanel:CalculateInternalSize()

	else
		Controls.EpicsScrollPanel:SetHide(true)
		Controls.NoEpics:SetHide(false)
	end


end

function EpicsSort(a, b)		--by owner, city, then epic
	if a.epicOwner == b.epicOwner then
		return Locale.Compare(a.epicName, b.epicName) == -1
	elseif a.epicOwner == "You" then
		return true
	elseif b.epicOwner == "You" then
		return false
	else
		return Locale.Compare(a.epicOwner, b.epicOwner) == -1
	end
end


g_Tabs.Artifacts.RefreshContent = function()
	g_ArtifactsManager:ResetInstances()
	
	local artifacts = {}
	local iActivePlayer = Game.GetActivePlayer()
	local activePlayer = Players[iActivePlayer]

	local wonders = {}
	local iActivePlayer = Game.GetActivePlayer()
	local activePlayer = Players[iActivePlayer]

	for id, artifact in pairs(gT.gArtifacts) do
		local artifactInfo = GameInfo.EaArtifacts[id]
		LuaEvents.EaArtifactsUpdateArtifact(id)

		local artifactLocation = "Unknown"
		--update ownership here

		if artifact.locationType == "iPerson" then
			local eaPerson = gPeople[artifact.locationIndex]
			local iPlayer = eaPerson.iPlayer
			if fullCivs[iPlayer] then		--could be barb
				if eaPerson.name then
					artifactLocation = "With " .. GetEaPersonFullTitle(eaPerson)
				end
			end

		elseif artifact.locationType == "iPlot" then
			local plot = Map.GetPlotByIndex(artifact.locationIndex)
			local city = plot:GetPlotCity()
			if city then
				artifactLocation = "In " .. city:GetName()
			end
		end

		local iOwner = artifact.iPlayer
		local artifactOwner = (iOwner == -1) and "No one" or ((iOwner == iActivePlayer) and "You" or Locale.Lookup(PreGame.GetCivilizationShortDescription(iOwner)))

		LuaEvents.EaActionsSetWEAHelp(GameInfoTypes[artifactInfo.EaAction], artifact.mod)
		local eaActionHelp = MapModData.text	--set in EaActions system
		local artifactDesc = string.gsub(eaActionHelp, "%[NEWLINE%]", "; ")
		table.insert(artifacts, {	artifactName = Locale.Lookup(artifactInfo.Description),
									artifactOwner = artifactOwner,
									artifactLocation = artifactLocation,
									artifactDesc = artifactDesc,
									artifactIconIndex = artifactInfo.IconIndex,
									artifactIconAtlas = artifactInfo.IconAtlas	})
	end
	
	if #artifacts > 0 then
		Controls.NoArtifacts:SetHide(true)
		Controls.ArtifactsScrollPanel:SetHide(false)

		table.sort(artifacts, ArtifactsSort)

		for i,v in ipairs(artifacts) do

			print(v.artifactName,v.artifactLocation, v.artifactIconIndex,v.artifactIconAtlas)

			local artifactEntry = g_ArtifactsManager:GetInstance()
			artifactEntry.ArtifactName:SetText(v.artifactName)
			artifactEntry.ArtifactOwner:SetText(v.artifactOwner)
			artifactEntry.ArtifactLocation:SetText(v.artifactLocation)
			artifactEntry.ArtifactDescription:SetText(v.artifactDesc)
			IconHookup(v.artifactIconIndex, 45, v.artifactIconAtlas, artifactEntry.ArtifactIcon)
		end
		
		Controls.ArtifactsStack:CalculateSize()
		Controls.ArtifactsStack:ReprocessAnchoring()
		Controls.ArtifactsScrollPanel:CalculateInternalSize()

	else
		Controls.ArtifactsScrollPanel:SetHide(true)
		Controls.NoArtifacts:SetHide(false)
	end


end

function ArtifactsSort(a, b)		--by owner, city, then artifact
	if a.artifactOwner == b.artifactOwner then
		if a.artifactLocation == b.artifactLocation then
			return Locale.Compare(a.artifactName, b.artifactName) == -1
		else
			return Locale.Compare(a.artifactLocation, b.artifactLocation) == -1
		end
	elseif a.artifactOwner == "You" then
		return true
	elseif b.artifactOwner == "You" then
		return false
	else
		return Locale.Compare(a.artifactOwner, b.artifactOwner) == -1
	end
end


function Hide()
    ContextPtr:SetHide(true)
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, Hide)

function InputHandler( uiMsg, wParam, lParam )
    if uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
            Hide()
            return true
        end
    end
end
ContextPtr:SetInputHandler(InputHandler)

--This adds popup to the Diplo Corner
function OnAdditionalInformationDropdownGatherEntries(additionalEntries)
	table.insert(additionalEntries, {	text = Locale.ConvertTextKey("TXT_KEY_EA_WONDERS_EPICS_ARTIFACTS_POPUP"), 
										call = Show		})
end
LuaEvents.AdditionalInformationDropdownGatherEntries.Add(OnAdditionalInformationDropdownGatherEntries)
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries()

ContextPtr:SetHide(true)
