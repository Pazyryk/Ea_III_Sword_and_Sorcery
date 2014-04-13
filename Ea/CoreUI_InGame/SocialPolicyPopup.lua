
-------------------------------------------------
-- SocialPolicy Chooser Popup
-------------------------------------------------

--Paz: modified from 1.0.1.383, 36879 bytes

--New layout --
	-- tradition ->		dominionism
	-- liberty ->		pantheism
	-- honor ->			theism
	-- piety ->			arcana
	-- patronage ->		slavery
	-- order ->			(representation)
	-- autocracy ->		militerism
	-- freedom ->		tradition
	-- rationalism ->	commerce
	-- commerce ->		civ-enabled


include( "IconSupport" );
include( "InstanceManager" );
include( "TutorialPopupScreen" );

--Paz add
include("EaCultureLevelHelper.lua")
MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT
local FALLEN_ID_SHIFT = GameInfoTypes.POLICY_ANTI_THEISM - GameInfoTypes.POLICY_THEISM
local g_civEnabledPolicies = {}		--update at Init(), which also runs after player change
--end Paz add

local m_PopupInfo = nil;

local g_LibertyPipeManager = InstanceManager:new( "ConnectorPipe", "ConnectorImage", Controls.LibertyPanel );
local g_TraditionPipeManager = InstanceManager:new( "ConnectorPipe", "ConnectorImage", Controls.TraditionPanel );
local g_HonorPipeManager = InstanceManager:new( "ConnectorPipe", "ConnectorImage", Controls.HonorPanel );
local g_PietyPipeManager = InstanceManager:new( "ConnectorPipe", "ConnectorImage", Controls.PietyPanel );
local g_PatronagePipeManager = InstanceManager:new( "ConnectorPipe", "ConnectorImage", Controls.PatronagePanel );
local g_CommercePipeManager = InstanceManager:new( "ConnectorPipe", "ConnectorImage", Controls.CommercePanel );
local g_RationalismPipeManager = InstanceManager:new( "ConnectorPipe", "ConnectorImage", Controls.RationalismPanel );
local g_FreedomPipeManager = InstanceManager:new( "ConnectorPipe", "ConnectorImage", Controls.FreedomPanel );
local g_OrderPipeManager = InstanceManager:new( "ConnectorPipe", "ConnectorImage", Controls.OrderPanel );
local g_AutocracyPipeManager = InstanceManager:new( "ConnectorPipe", "ConnectorImage", Controls.AutocracyPanel );

local g_LibertyInstanceManager = InstanceManager:new( "PolicyButton", "PolicyIcon", Controls.LibertyPanel );
local g_TraditionInstanceManager = InstanceManager:new( "PolicyButton", "PolicyIcon", Controls.TraditionPanel );
local g_HonorInstanceManager = InstanceManager:new( "PolicyButton", "PolicyIcon", Controls.HonorPanel );
local g_PietyInstanceManager = InstanceManager:new( "PolicyButton", "PolicyIcon", Controls.PietyPanel );
local g_PatronageInstanceManager = InstanceManager:new( "PolicyButton", "PolicyIcon", Controls.PatronagePanel );
local g_CommerceInstanceManager = InstanceManager:new( "PolicyButton", "PolicyIcon", Controls.CommercePanel );
local g_RationalismInstanceManager = InstanceManager:new( "PolicyButton", "PolicyIcon", Controls.RationalismPanel );
local g_FreedomInstanceManager = InstanceManager:new( "PolicyButton", "PolicyIcon", Controls.FreedomPanel );
local g_OrderInstanceManager = InstanceManager:new( "PolicyButton", "PolicyIcon", Controls.OrderPanel );
local g_AutocracyInstanceManager = InstanceManager:new( "PolicyButton", "PolicyIcon", Controls.AutocracyPanel );

include( "FLuaVector" );

local fullColor = {x = 1, y = 1, z = 1, w = 1};
local fadeColor = {x = 1, y = 1, z = 1, w = 0};
local fadeColorRV = {x = 1, y = 1, z = 1, w = 0.2};
local pinkColor = {x = 2, y = 0, z = 2, w = 1};
local lockTexture = "48Lock.dds";
local checkTexture = "48Checked.dds";

local hTexture = "Connect_H.dds";
local vTexture = "Connect_V.dds";

local topRightTexture =		"Connect_JonCurve_TopRight.dds"
local topLeftTexture =		"Connect_JonCurve_TopLeft.dds"
local bottomRightTexture =	"Connect_JonCurve_BottomRight.dds"
local bottomLeftTexture =	"Connect_JonCurve_BottomLeft.dds"

local policyIcons = {};

local g_PolicyXOffset = 28;
local g_PolicyYOffset = 68;

local g_PolicyPipeXOffset = 28;
local g_PolicyPipeYOffset = 68;

local m_gPolicyID;
local m_gAdoptingPolicy;

--Paz disabled: local numBranchesRequiredForUtopia = GameInfo.Projects["PROJECT_UTOPIA_PROJECT"].CultureBranchesRequired;

-------------------------------------------------
-- On Policy Selected
-------------------------------------------------
function PolicySelected( policyIndex )
    
    print("Clicked on Policy: " .. tostring(policyIndex));
    
	if policyIndex == -1 then
		return;
	end
    local player = Players[Game.GetActivePlayer()];   
    if player == nil then
		return;
    end

 	--Paz add
	local swappedPolicyIndex = policyIndex
	if GameInfo.Policies[policyIndex].PolicyBranchType == "POLICY_BRANCH_THEISM" then
		local eaPlayer = gT.gPlayers[Game.GetActivePlayer()]
		local bIsFallen = eaPlayer.bIsFallen
		if bIsFallen then
			swappedPolicyIndex = policyIndex + FALLEN_ID_SHIFT
		end
	end
	--end Paz add 
	  
    local bHasPolicy = player:HasPolicy(swappedPolicyIndex);	--Paz: changed policyIndex to swappedPolicyIndex
    local bCanAdoptPolicy = player:CanAdoptPolicy(swappedPolicyIndex);	--Paz: changed policyIndex to swappedPolicyIndex
    
    print("bHasPolicy: " .. tostring(bHasPolicy));
    print("bCanAdoptPolicy: " .. tostring(bCanAdoptPolicy));
    print("Policy Blocked: " .. tostring(player:IsPolicyBlocked(swappedPolicyIndex)));	--Paz: changed policyIndex to swappedPolicyIndex
    
    local bPolicyBlocked = false;
    
    -- If we can get this, OR we already have it, see if we can unblock it first
    if (bHasPolicy or bCanAdoptPolicy) then
    
		-- Policy blocked off right now? If so, try to activate
		if (player:IsPolicyBlocked(swappedPolicyIndex)) then	--Paz: changed policyIndex to swappedPolicyIndex
			
			bPolicyBlocked = true;
			
			local strPolicyBranch = GameInfo.Policies[swappedPolicyIndex].PolicyBranchType;	--Paz: changed policyIndex to swappedPolicyIndex
			local iPolicyBranch = GameInfoTypes[strPolicyBranch];
			
			print("Policy Branch: " .. tostring(iPolicyBranch));
			
			local popupInfo = {
				Type = ButtonPopupTypes.BUTTONPOPUP_CONFIRM_POLICY_BRANCH_SWITCH,
				Data1 = iPolicyBranch;
			}
			Events.SerialEventGameMessagePopup(popupInfo);
			
		end
    end
    
    -- Can adopt Policy right now - don't try this if we're going to unblock the Policy instead
    if (bCanAdoptPolicy and not bPolicyBlocked) then
		m_gPolicyID = swappedPolicyIndex;	--Paz: changed policyIndex to swappedPolicyIndex
		m_gAdoptingPolicy = true;
		Controls.PolicyConfirm:SetHide(false);
		Controls.BGBlock:SetHide(true);
		--Network.SendUpdatePolicies(policyIndex, true, true);
		--Events.AudioPlay2DSound("AS2D_INTERFACE_POLICY");		
	end
	
end

-------------------------------------------------
-- On Policy Branch Selected
-------------------------------------------------
function PolicyBranchSelected( policyBranchIndex )
    
    --print("Clicked on PolicyBranch: " .. tostring(policyBranchIndex));
    
	if policyBranchIndex == -1 then
		return;
	end
    local player = Players[Game.GetActivePlayer()];   
    if player == nil then
		return;
    end
    
	--Paz add
	local swappedPolicyBranchIndex = policyBranchIndex
	if policyBranchIndex == GameInfoTypes.POLICY_BRANCH_THEISM then
		local eaPlayer = gT.gPlayers[Game.GetActivePlayer()]
		local bIsFallen = eaPlayer.bIsFallen
		if bIsFallen then
			swappedPolicyBranchIndex = GameInfoTypes.POLICY_BRANCH_ANTI_THEISM
		end
	end
	--end Paz add

    local bHasPolicyBranch = player:IsPolicyBranchUnlocked(swappedPolicyBranchIndex);	--Paz: changed policyBranchIndex to swappedPolicyBranchIndex
    local bCanAdoptPolicyBranch = player:CanUnlockPolicyBranch(swappedPolicyBranchIndex);	--Paz: changed policyBranchIndex to swappedPolicyBranchIndex
    
    --print("bHasPolicyBranch: " .. tostring(bHasPolicyBranch));
    --print("bCanAdoptPolicyBranch: " .. tostring(bCanAdoptPolicyBranch));
   -- print("PolicyBranch Blocked: " .. tostring(player:IsPolicyBranchBlocked(policyBranchIndex)));
    
    local bUnblockingPolicyBranch = false;
    
    -- If we can get this, OR we already have it, see if we can unblock it first
    if (bHasPolicyBranch or bCanAdoptPolicyBranch) then
    
		-- Policy Branch blocked off right now? If so, try to activate
		if (player:IsPolicyBranchBlocked(swappedPolicyBranchIndex)) then	--Paz: changed policyBranchIndex to swappedPolicyBranchIndex
			
			bUnblockingPolicyBranch = true;
			
			local popupInfo = {
				Type = ButtonPopupTypes.BUTTONPOPUP_CONFIRM_POLICY_BRANCH_SWITCH,
				Data1 = swappedPolicyBranchIndex;	--Paz: changed policyBranchIndex to swappedPolicyBranchIndex
			}
			Events.SerialEventGameMessagePopup(popupInfo);
		end
    end
    
    -- Can adopt Policy Branch right now - don't try this if we're going to unblock the Policy Branch instead
    if (bCanAdoptPolicyBranch and not bUnblockingPolicyBranch) then
		m_gPolicyID = swappedPolicyBranchIndex;	--Paz: changed policyBranchIndex to swappedPolicyBranchIndex
		m_gAdoptingPolicy = false;
		Controls.PolicyConfirm:SetHide(false);
		Controls.BGBlock:SetHide(true);
	end
	
	---- Are we allowed to unlock this Branch right now?
	--if player:CanUnlockPolicyBranch( policyBranchIndex ) then
		--
		---- Can't adopt the Policy Branch - can we switch active branches though?
		--if (player:IsPolicyBranchBlocked(policyBranchIndex)) then
		--
			--local popupInfo = {
				--Type = ButtonPopupTypes.BUTTONPOPUP_CONFIRM_POLICY_BRANCH_SWITCH,
				--Data1 = policyBranchIndex;
			--}
			--Events.SerialEventGameMessagePopup(popupInfo);
	    --
		---- Can adopt this Policy Branch right now
		--else
			--Network.SendUpdatePolicies(policyBranchIndex, false, true);
		--end
	--end
end

-------------------------------------------------
-------------------------------------------------
function OnPopupMessage(popupInfo)
	
	local popupType = popupInfo.Type;
	if popupType ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSEPOLICY then
		return;
	end
	
	m_PopupInfo = popupInfo;

	UpdateDisplay();
	
	if( m_PopupInfo.Data1 == 1 ) then
    	if( ContextPtr:IsHidden() == false ) then
    	    OnClose();
    	else
        	UIManager:QueuePopup( ContextPtr, PopupPriority.eUtmost );
    	end
	else
    	UIManager:QueuePopup( ContextPtr, PopupPriority.SocialPolicy );
	end
end
Events.SerialEventGameMessagePopup.Add( OnPopupMessage );

-------------------------------------------------
-------------------------------------------------
function UpdateDisplay()

    --Paz modified below: local player = Players[Game.GetActivePlayer()];
	local iPlayer = Game.GetActivePlayer()
	local player = Players[iPlayer]
	--end Paz modified
    local pTeam = Teams[player:GetTeam()];
    
    if player == nil then
		return;
    end
    
    Controls.AnarchyBlock:SetHide( not player:IsAnarchy() );

    local bShowAll = OptionsManager.GetPolicyInfo();
    
	--[[Paz disable
    local szText = Locale.ConvertTextKey("TXT_KEY_NEXT_POLICY_COST_LABEL", player:GetNextPolicyCost());
    Controls.NextCost:SetText(szText);
    
    szText = Locale.ConvertTextKey("TXT_KEY_CURRENT_CULTURE_LABEL", player:GetJONSCulture());
    Controls.CurrentCultureLabel:SetText(szText);
    
    szText = Locale.ConvertTextKey("TXT_KEY_CULTURE_PER_TURN_LABEL", player:GetTotalJONSCulturePerTurn());
    Controls.CulturePerTurnLabel:SetText(szText);
    
    local iTurns;
    local iCultureNeeded = player:GetNextPolicyCost() - player:GetJONSCulture();
    if (iCultureNeeded <= 0) then
		iTurns = 0;
    else
		if (player:GetTotalJONSCulturePerTurn() == 0) then
			iTurns = "?";
		else
			iTurns = iCultureNeeded / player:GetTotalJONSCulturePerTurn();
			iTurns = iTurns + 1;
			iTurns = math.floor(iTurns);
		end
    end
    szText = Locale.ConvertTextKey("TXT_KEY_NEXT_POLICY_TURN_LABEL", iTurns);
    Controls.NextPolicyTurnLabel:SetText(szText);
	]]
	--Paz add (note: this is all confusing because the Control names haven't been changed)
	UpdateCultureLevelInfoForUI(iPlayer)
	Controls.NextCost:SetText(Locale.ConvertTextKey("TXT_KEY_EA_CULTURE_LEVEL") .. "[COLOR_POSITIVE_TEXT]" .. string.format(" %.2f", MapModData.cultureLevel) .. "[ENDCOLOR]")
	Controls.CurrentCultureLabel:SetText(Locale.ConvertTextKey("TXT_KEY_EA_CULTURE_LEVEL_APPROACHING") .. "[COLOR_POSITIVE_TEXT]" .. string.format(" %.2f", MapModData.approachingCulturalLevel) .. "[ENDCOLOR]")
	local txtColor = MapModData.estCultureLevelChange < 0 and "[COLOR_NEGATIVE_TEXT]" or "[COLOR_POSITIVE_TEXT]"
	Controls.CulturePerTurnLabel:SetText(Locale.ConvertTextKey("TXT_KEY_EA_CULTURE_LEVEL_CHANGE") .. txtColor .. string.format(" %+.2f", MapModData.estCultureLevelChange) .. "[ENDCOLOR]")
	Controls.NextPolicyTurnLabel:SetText(Locale.ConvertTextKey("TXT_KEY_EA_NEXT_CULTURE_LEVEL") .. " [COLOR_POSITIVE_TEXT]" .. MapModData.nextCultureLevel .. "[ENDCOLOR]")

	--[[old
	Controls.NextCost:SetText(string.format("Cultural Level: %.2f", eaPlayer.culturalLevel))
	--local cultPerPop = player:GetTotalJONSCulturePerTurn() / player:GetTotalPopulation()
	--szText = "Culture per Pop. (x".. MapModData.POLICY_MULTIPLIER .."): "..(math.floor(cultPerPop * MapModData.POLICY_MULTIPLIER * 100 + 0.5)/100)
	local approachingCL = MapModData.POLICY_MULTIPLIER * ((player:GetTotalJONSCulturePerTurn() / player:GetTotalPopulation()) ^ MapModData.POLICY_CULTURE_EXPONENT)
	Controls.CurrentCultureLabel:SetText(string.format("Approaching C.L.: %.2f", approachingCL))
	local estimatedCultLevelNextTurn = MapModData.POLICY_MULTIPLIER * (((player:GetJONSCulture() + player:GetTotalJONSCulturePerTurn()) / (eaPlayer.cumPopTurns + MapModData.POLICY_DENOMINATOR_ADD + player:GetTotalPopulation())) ^ MapModData.POLICY_CULTURE_EXPONENT)
	if gT.gEpics[EA_EPIC_VOLUSPA] and gT.gEpics[EA_EPIC_VOLUSPA].iPlayer == iPlayer then
		estimatedCultLevelNextTurn = estimatedCultLevelNextTurn + gT.gEpics[EA_EPIC_VOLUSPA].mod / 10
	end
	local estChange = estimatedCultLevelNextTurn - eaPlayer.culturalLevel
	Controls.CulturePerTurnLabel:SetText(string.format("Estimated change next turn: %+.2f", estChange))
	local nextPolicyAtLevel = eaPlayer.policyCount + 1 - player:GetNumFreePolicies()
	Controls.NextPolicyTurnLabel:SetText(string.format("Next Policy at Level: %.0f", nextPolicyAtLevel))
	]]
	
	local eaPlayer = gT.gPlayers[iPlayer]
	if not eaPlayer then return end
	local bIsFallen = eaPlayer.bIsFallen	--used below for Theism branch swap
	--end Paz add
    
    -- Player Title
	--[[Paz modified below
    local iDominantBranch = player:GetDominantPolicyBranchForTitle();
    if (iDominantBranch ~= -1) then
		
		local strTextKey = GameInfo.PolicyBranchTypes[iDominantBranch].Title;
		
		local strText = Locale.ConvertTextKey(strTextKey, player:GetNameKey(), player:GetCivilizationShortDescriptionKey());
		
	    Controls.PlayerTitleLabel:SetHide(false);
	    Controls.PlayerTitleLabel:SetText(strText);
	else
	    Controls.PlayerTitleLabel:SetHide(true);
    end
	]]
	Controls.PlayerTitleLabel:SetHide(true)
	--end Paz modified
    
    -- Free Policies
    local iNumFreePolicies = player:GetNumFreePolicies();
    if (iNumFreePolicies > 0) then
	    szText = Locale.ConvertTextKey("TXT_KEY_FREE_POLICIES_LABEL", iNumFreePolicies);
	    Controls.FreePoliciesLabel:SetText( szText );
	    Controls.FreePoliciesLabel:SetHide( false );
	else
	    Controls.FreePoliciesLabel:SetHide( true );
    end
    
	Controls.InfoStack:ReprocessAnchoring();
    
	--szText = Locale.ConvertTextKey( "TXT_KEY_SOCIAL_POLICY_DIRECTIONS" );
    --Controls.ReminderText:SetText( szText );

	local justLooking = true;
	if player:GetJONSCulture() >= player:GetNextPolicyCost() then
		justLooking = false;
	end
	
	-- Adjust Policy Branches
	local i = 0;
	local numUnlockedBranches = player:GetNumPolicyBranchesUnlocked();
--	if numUnlockedBranches > 0 then
	local policyBranchInfo = GameInfo.PolicyBranchTypes[i];

	--Paz add
	local swapped_i = 0
	--end Paz add

		while policyBranchInfo ~= nil do
			local numString = tostring( i );
			
			local buttonName = "BranchButton"..numString;
			local backName = "BranchBack"..numString;
			local DisabledBoxName = "DisabledBox"..numString;
			local LockedBoxName = "LockedBox"..numString;
			local ImageMaskName = "ImageMask"..numString;
			local DisabledMaskName = "DisabledMask"..numString;
			--local EraLabelName = "EraLabel"..numString;
			
			
			local thisButton = Controls[buttonName];
			local thisBack = Controls[backName];
			local thisDisabledBox = Controls[DisabledBoxName];
			local thisLockedBox = Controls[LockedBoxName];
			
			local thisImageMask = Controls[ImageMaskName];
			local thisDisabledMask = Controls[DisabledMaskName];
			
			
			if(thisImageMask == nil) then
				print(ImageMaskName);
			end
			--local thisEraLabel = Controls[EraLabelName];
			
			--Paz add: Theism swap
			if bIsFallen and policyBranchInfo.Type == "POLICY_BRANCH_THEISM" then
				policyBranchInfo = GameInfo.Policies[GameInfoTypes.POLICY_BRANCH_ANTI_THEISM]
				swapped_i = policyBranchInfo.ID
			else
				swapped_i = i
			end
			--end Paz add


			local strToolTip = Locale.ConvertTextKey(policyBranchInfo.Help);
			
			-- Era Prereq
			--Paz disabled: local iEraPrereq = GameInfoTypes[policyBranchInfo.EraPrereq]
			local bEraLock = false;
			--[[Paz disable
			if (iEraPrereq ~= nil and pTeam:GetCurrentEra() < iEraPrereq) then
				bEraLock = true;
			else
				--thisEraLabel:SetHide(true);
			end
			]]
			
			local lockName = "Lock"..numString;
			local thisLock = Controls[lockName];
			
			-- Branch is not yet unlocked
			
			if not player:IsPolicyBranchUnlocked( swapped_i ) then	--Paz: changed i to swapped_i
				
				-- Cannot adopt this branch right now
				if (not player:CanUnlockPolicyBranch(swapped_i)) then	--Paz: changed i to swapped_i

					--[[Paz modified below				
					strToolTip = strToolTip .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_POLICY_BRANCH_CANNOT_UNLOCK");
					
					-- Not in prereq Era
					if (bEraLock) then

						local strEra = GameInfo.Eras[iEraPrereq].Description;
						strToolTip = strToolTip .. " " .. Locale.ConvertTextKey("TXT_KEY_POLICY_BRANCH_CANNOT_UNLOCK_ERA", strEra);
						
						-- Era Label
						--local strEraTitle = "[COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey(strEra) .. "[ENDCOLOR]";
						local strEraTitle = Locale.ConvertTextKey(strEra);
						thisButton:SetText( strEraTitle );
						--thisEraLabel:SetText(strEraTitle);
						--thisEraLabel:SetHide( true );
					
						thisButton:SetHide( true );

						
					-- Don't have enough Culture Yet
					else
						strToolTip = strToolTip .. " " .. Locale.ConvertTextKey("TXT_KEY_POLICY_BRANCH_CANNOT_UNLOCK_CULTURE", player:GetNextPolicyCost());
						thisButton:SetHide( false );
						thisButton:SetText( Locale.ConvertTextKey( "TXT_KEY_POP_ADOPT_BUTTON" ) );
						--thisEraLabel:SetHide( true );
					end
					]]	

					thisButton:SetHide( false );
					thisButton:SetText( Locale.ConvertTextKey( "TXT_KEY_POP_ADOPT_BUTTON" ) );
					--end Paz modified

					thisLock:SetHide( false );
					thisButton:SetDisabled( true );
				-- Can adopt this branch right now
				else
					strToolTip = strToolTip .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_POLICY_BRANCH_UNLOCK_SPEND", player:GetNextPolicyCost());
					thisLock:SetHide( true );
					--thisEraLabel:SetHide( true );
					thisButton:SetDisabled( false );
					thisButton:SetHide( false );
					thisButton:SetText( Locale.ConvertTextKey( "TXT_KEY_POP_ADOPT_BUTTON" ) );
				end

				--Paz add
				if policyBranchInfo.Type == "POLICY_BRANCH_8" or policyBranchInfo.Type == "POLICY_BRANCH_CIV_ENABLED" then
					thisButton:SetHide( true )
				end
				--end Paz add

				
				thisBack:SetColor( fadeColor );
				thisLockedBox:SetHide(false);
				
				thisImageMask:SetHide(true);
				thisDisabledMask:SetHide(false);
			
			-- Branch is unlocked, but blocked by another branch
			elseif (player:IsPolicyBranchBlocked(swapped_i)) then	--Paz: changed i to swapped_i
				thisButton:SetHide( false );
				thisBack:SetColor( fadeColor );
				thisLock:SetHide( false );
				thisLockedBox:SetHide(true);
				
				strToolTip = strToolTip .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_POLICY_BRANCH_BLOCKED");
				
			-- Branch is unlocked already
			else
				thisButton:SetHide( true );
				thisBack:SetColor( fullColor );
				thisLockedBox:SetHide(true);
				
				thisImageMask:SetHide(false);
				thisDisabledMask:SetHide(true);
			end
			
			--Paz add
			if policyBranchInfo.Type == "POLICY_BRANCH_THEISM" then
				if eaPlayer.race ~= GameInfoTypes.EARACE_MAN then
					strToolTip = strToolTip .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_POLICY_BRANCH_RACE_BLOCKED")
				end
			end
			--end Paz add


			-- Update tooltips
			thisButton:SetToolTipString(strToolTip);
			
			-- If the player doesn't have the era prereq, then dim out the branch
			if (bEraLock) then
				thisDisabledBox:SetHide(false);
				thisLockedBox:SetHide(true);
			else
				thisDisabledBox:SetHide(true);
			end
			
			if (bShowAll) then
				thisDisabledBox:SetHide(true);
				thisLockedBox:SetHide(true);
			end
			
			i = i + 1;
			policyBranchInfo = GameInfo.PolicyBranchTypes[i];

			--Paz add: skip Anti-Theism
			if policyBranchInfo.Type == "POLICY_BRANCH_ANTI_THEISM" then 
				i = i + 1
				policyBranchInfo = GameInfo.PolicyBranchTypes[i]
			end
			--end Paz add

		end
	--else
		--local policyBranchInfo = GameInfo.PolicyBranchTypes[i];
		--while policyBranchInfo ~= nil do
			--local numString = tostring(i);
			--local buttonName = "BranchButton"..numString;
			--local backName = "BranchBack"..numString;
			--local thisButton = Controls[buttonName];
			--local thisBack = Controls[backName];
			--thisBack:SetColor( fullColor );
			--thisButton:SetHide( true );
			--i = i + 1;
			--policyBranchInfo = GameInfo.PolicyBranchTypes[i];
		--end
	--end
	
	-- Adjust Policy buttons
	i = 0;
	local policyInfo = GameInfo.Policies[i];

	while policyInfo ~= nil do		
		local iBranch = policyInfo.PolicyBranchType;

		--Paz add: Theism, anti-Theism policy swap (use graphic layout for Theism, but helpinfo for anti-Theism) and civ enabled
		swapped_i = i
		if iBranch == "POLICY_BRANCH_ANTI_THEISM" or (iBranch == "POLICY_BRANCH_CIV_ENABLED" and not g_civEnabledPolicies[policyInfo.ID]) then
			iBranch = nil	--skip
		elseif bIsFallen and iBranch == "POLICY_BRANCH_THEISM" then
			swapped_i = i + FALLEN_ID_SHIFT
			policyInfo = GameInfo.Policies[swapped_i]
		end
		--end Paz add
			

		-- If this is nil it means the Policy is a freebie handed out with the Branch, so don't display it
		if (iBranch ~= nil) then
			
			local thisPolicyIcon = policyIcons[i];
			
			-- Tooltip
			local strTooltip = Locale.ConvertTextKey( policyInfo.Help );
			
			-- Player already has Policy
			if player:HasPolicy( swapped_i ) then	--Paz: changed i to swapped_i
				--thisPolicyIcon.Lock:SetTexture( checkTexture ); 
				--thisPolicyIcon.Lock:SetHide( true ); 
				thisPolicyIcon.MouseOverContainer:SetHide( true );
				thisPolicyIcon.PolicyIcon:SetDisabled( true );
				--thisPolicyIcon.PolicyIcon:SetVoid1( -1 );
				thisPolicyIcon.PolicyImage:SetColor( fullColor );
				IconHookup( policyInfo.PortraitIndex, 64, policyInfo.IconAtlasAchieved, thisPolicyIcon.PolicyImage );
				
			-- Can adopt the Policy right now
			elseif player:CanAdoptPolicy( swapped_i ) then	--Paz: changed i to swapped_i
				--thisPolicyIcon.Lock:SetHide( true ); 
				thisPolicyIcon.MouseOverContainer:SetHide( false );
				thisPolicyIcon.PolicyIcon:SetDisabled( false );
				if justLooking then
					--thisPolicyIcon.PolicyIcon:SetVoid1( -1 );
					thisPolicyIcon.PolicyImage:SetColor( fullColor );
				else
					thisPolicyIcon.PolicyIcon:SetVoid1( swapped_i ); -- indicates policy to be chosen		--Paz: changed i to swapped_i
					thisPolicyIcon.PolicyImage:SetColor( fullColor );
				end
				IconHookup( policyInfo.PortraitIndex, 64, policyInfo.IconAtlas, thisPolicyIcon.PolicyImage );
				
			-- Policy is locked
			else
				--thisPolicyIcon.Lock:SetTexture( lockTexture ); 
				thisPolicyIcon.MouseOverContainer:SetHide( true );
				--thisPolicyIcon.Lock:SetHide( true ); 
				thisPolicyIcon.PolicyIcon:SetDisabled( true );
				--thisPolicyIcon.Lock:SetHide( false ); 
				--thisPolicyIcon.PolicyIcon:SetVoid1( -1 );
				thisPolicyIcon.PolicyImage:SetColor( fadeColorRV );
				IconHookup( policyInfo.PortraitIndex, 64, policyInfo.IconAtlas, thisPolicyIcon.PolicyImage );
				-- Tooltip
				strTooltip = strTooltip .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_POLICY_CANNOT_UNLOCK");
			end
			
			-- Policy is Blocked
			if player:IsPolicyBlocked(swapped_i) then	--Paz: changed i to swapped_i
				thisPolicyIcon.PolicyImage:SetColor( fadeColorRV );
				IconHookup( policyInfo.PortraitIndex, 64, policyInfo.IconAtlas, thisPolicyIcon.PolicyImage );
				
				-- Update tooltip if we have this Policy
				if player:HasPolicy( swapped_i ) then	--Paz: changed i to swapped_i
					strTooltip = strTooltip .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_POLICY_BRANCH_BLOCKED");
				end
			end
				
			thisPolicyIcon.PolicyIcon:SetToolTipString( strTooltip );
		end
		
		i = i + 1;
		policyInfo = GameInfo.Policies[i];
	end
	
	-- update the Utopia bar
	--[[Paz disabled
	local numDone = player:GetNumPolicyBranchesFinished();
	local percentDone = numDone / numBranchesRequiredForUtopia;
	if percentDone > 1 then
		percentDone = 1;
	end
	Controls.UtopiaBar:SetPercent( percentDone );
	]]
end
Events.EventPoliciesDirty.Add( UpdateDisplay );

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnClose()
    UIManager:DequeuePopup( ContextPtr );
	--Paz add
	LuaEvents.EaCivNamingTestAllCivNamingConditions(Game.GetActivePlayer())
	LuaEvents.EaPoliciesOnPlayerAdoptPolicyDelayedEffect()
	--end Paz add
end
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnClose );

----------------------------------------------------------------
----------------------------------------------------------------
function OnPolicyInfo( bIsChecked )
	local bUpdateScreen = false;
	
	if (bIsChecked ~= OptionsManager.GetPolicyInfo()) then
		bUpdateScreen = true;
	end
	
    OptionsManager.SetPolicyInfo_Cached( bIsChecked );
    OptionsManager.CommitGameOptions();
    
    if (bUpdateScreen) then
		Events.EventPoliciesDirty();
	end
end
Controls.PolicyInfo:RegisterCheckHandler( OnPolicyInfo );

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function InputHandler( uiMsg, wParam, lParam )
    ----------------------------------------------------------------        
    -- Key Down Processing
    ----------------------------------------------------------------        
    if uiMsg == KeyEvents.KeyDown then
        if (wParam == Keys.VK_RETURN or wParam == Keys.VK_ESCAPE) then
			if(Controls.PolicyConfirm:IsHidden())then
	            OnClose();
	        else
				Controls.PolicyConfirm:SetHide(true);
            	Controls.BGBlock:SetHide(false);
			end
			return true;
        end
    end
end
ContextPtr:SetInputHandler( InputHandler );

--Paz: swapped policy branches as indidicated in header
function GetPipe(branchType)
	local controlTable = nil;
	-- decide which panel it goes on
	if branchType == "POLICY_BRANCH_PANTHEISM" then
		controlTable = g_LibertyPipeManager:GetInstance();
	elseif branchType == "POLICY_BRANCH_DOMINIONISM" then
		controlTable = g_TraditionPipeManager:GetInstance();
	elseif branchType == "POLICY_BRANCH_THEISM" then
		controlTable = g_HonorPipeManager:GetInstance();
	elseif branchType == "POLICY_BRANCH_ARCANA" then
		controlTable = g_PietyPipeManager:GetInstance();
	elseif branchType == "POLICY_BRANCH_SLAVERY" then
		controlTable = g_PatronagePipeManager:GetInstance();
	elseif branchType == "POLICY_BRANCH_CIV_ENABLED" then
		controlTable = g_CommercePipeManager:GetInstance();
	elseif branchType == "POLICY_BRANCH_COMMERCE" then
		controlTable = g_RationalismPipeManager:GetInstance();
	elseif branchType == "POLICY_BRANCH_TRADITION" then
		controlTable = g_FreedomPipeManager:GetInstance();
	--elseif branchType == "POLICY_BRANCH_ORDER" then
	--	controlTable = g_OrderPipeManager:GetInstance();
	elseif branchType == "POLICY_BRANCH_MILITARISM" then
		controlTable = g_AutocracyPipeManager:GetInstance();
	end
	return controlTable;
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function Init()
	--Paz note: this runs at game start AND after player change. So we can have civ- (or race-)specific differences
	--Paz note: should have coded Theism as I did civ-enabled (by running Init again)
	
	--Paz add: update civ enabled policies (this runs at game init and after player change)
	local iPlayer = Game.GetActivePlayer()
	local player = Players[iPlayer]
	local civID = player:GetCivilizationType()
	local civInfo = GameInfo.Civilizations[civID]
	local eaCivType = civInfo.EaCivName
	print("Initing SocialPolicyPopup with civType/eaCivType = ", civInfo.Type, eaCivType)
	for key in pairs(g_civEnabledPolicies) do
		g_civEnabledPolicies[key] = nil				--in case we do more complex player changes later
	end
	if eaCivType and not MapModData.bDisableEnabledPolicies then
		for row in GameInfo.EaCiv_EnabledPolicies() do
			if eaCivType == row.EaCivType then
				g_civEnabledPolicies[GameInfoTypes[row.PolicyType] ] = {x = row.GridX, y = row.GridY}
			end
		end
		Controls.CivEnabledTitle:SetText(Locale.ToUpper(Locale.ConvertTextKey(civInfo.Description)))
	else
		Controls.CivEnabledTitle:SetText(Locale.ConvertTextKey("TXT_KEY_EA_POLICY_BRANCH_CIV_ENABLED_CAP"))
	end
	--end Paz add

	local bDisablePolicies = Game.IsOption(GameOptionTypes.GAMEOPTION_NO_POLICIES);
	
	Controls.LabelPoliciesDisabled:SetHide(not bDisablePolicies);
	Controls.InfoStack:SetHide(bDisablePolicies);
	Controls.InfoStack2:SetHide(bDisablePolicies);
	
	-- Activate the Branch buttons
	local i = 0;
	local policyBranchInfo = GameInfo.PolicyBranchTypes[i];

	while policyBranchInfo ~= nil do
		local buttonName = "BranchButton"..tostring( i );
		local thisButton = Controls[buttonName];
		thisButton:SetVoid1( i ); -- indicates type
		thisButton:RegisterCallback( Mouse.eLClick, PolicyBranchSelected );
		i = i + 1;
		policyBranchInfo = GameInfo.PolicyBranchTypes[i];
		--Paz add
		if i > 9 then	--we're done (yes, this is a sucky way to do it but it's not my fault)
			policyBranchInfo = nil
		end
		--end Paz add
	end

	--Paz add


	--end Paz add

	-- add the pipes
	local policyPipes = {};
	for row in GameInfo.Policies() do
		--Paz add
		local bDisplay = false
		if row.PolicyBranchType and row.PolicyBranchType ~= "POLICY_BRANCH_ANTI_THEISM" then
			if row.PolicyBranchType == "POLICY_BRANCH_CIV_ENABLED" then
				bDisplay = g_civEnabledPolicies[row.ID]
			else
				bDisplay = true
			end
		end
		--Paz: enclosed policyPipes assignment in if block
		if bDisplay then
			policyPipes[row.Type] = 
			{
				upConnectionLeft = false;
				upConnectionRight = false;
				upConnectionCenter = false;
				upConnectionType = 0;
				downConnectionLeft = false;
				downConnectionRight = false;
				downConnectionCenter = false;
				downConnectionType = 0;
				yOffset = 0;
				policyType = row.Type;
			};
		end
		--end Paz modified
	end
	
	local cnxCenter = 1
	local cnxLeft = 2
	local cnxRight = 4

	-- Figure out which top and bottom adapters we need
	for row in GameInfo.Policy_PrereqPolicies() do
		local prereq = GameInfo.Policies[row.PrereqPolicy];
		local policy = GameInfo.Policies[row.PolicyType];
		--Paz add: skip for anti-Theism or non civ-enabled, and adjust position for civ enabled
		if policy.PolicyBranchType == "POLICY_BRANCH_ANTI_THEISM" or (policy.PolicyBranchType == "POLICY_BRANCH_CIV_ENABLED" and not g_civEnabledPolicies[policy.ID]) then
			policy = nil
		elseif policy.PolicyBranchType == "POLICY_BRANCH_CIV_ENABLED" then
			if g_civEnabledPolicies[policy.ID] then
				policy.GridX = g_civEnabledPolicies[policy.ID].x	--positions are civ-specific
				policy.GridY = g_civEnabledPolicies[policy.ID].y
				prereq.GridX = g_civEnabledPolicies[prereq.ID].x	--This WILL cause an error when you make a civ-enabled policy prereq that is not also civ-enabled (I warned you!)
				prereq.GridY = g_civEnabledPolicies[prereq.ID].y
			else
				policy = nil
			end		
		end
		--end Paz add
		if policy and prereq then
			if policy.GridX < prereq.GridX then
				policyPipes[policy.Type].upConnectionRight = true;
				policyPipes[prereq.Type].downConnectionLeft = true;
			elseif policy.GridX > prereq.GridX then
				policyPipes[policy.Type].upConnectionLeft = true;
				policyPipes[prereq.Type].downConnectionRight = true;
			else -- policy.GridX == prereq.GridX
				policyPipes[policy.Type].upConnectionCenter = true;
				policyPipes[prereq.Type].downConnectionCenter = true;
			end
			local yOffset = (policy.GridY - prereq.GridY) - 1;
			if yOffset > policyPipes[prereq.Type].yOffset then
				policyPipes[prereq.Type].yOffset = yOffset;
			end
		end
	end

	for pipeIndex, thisPipe in pairs(policyPipes) do
		if thisPipe.upConnectionLeft then
			thisPipe.upConnectionType = thisPipe.upConnectionType + cnxLeft;
		end 
		if thisPipe.upConnectionRight then
			thisPipe.upConnectionType = thisPipe.upConnectionType + cnxRight;
		end 
		if thisPipe.upConnectionCenter then
			thisPipe.upConnectionType = thisPipe.upConnectionType + cnxCenter;
		end 
		if thisPipe.downConnectionLeft then
			thisPipe.downConnectionType = thisPipe.downConnectionType + cnxLeft;
		end 
		if thisPipe.downConnectionRight then
			thisPipe.downConnectionType = thisPipe.downConnectionType + cnxRight;
		end 
		if thisPipe.downConnectionCenter then
			thisPipe.downConnectionType = thisPipe.downConnectionType + cnxCenter;
		end 
	end

	-- three passes down, up, connection
	-- connection
	for row in GameInfo.Policy_PrereqPolicies() do
		local prereq = GameInfo.Policies[row.PrereqPolicy];
		local policy = GameInfo.Policies[row.PolicyType];
		--Paz add: skip for anti-Theism or non civ-enabled, and adjust position for civ enabled
		if policy.PolicyBranchType == "POLICY_BRANCH_ANTI_THEISM" or (policy.PolicyBranchType == "POLICY_BRANCH_CIV_ENABLED" and not g_civEnabledPolicies[policy.ID]) then
			policy = nil
		elseif policy.PolicyBranchType == "POLICY_BRANCH_CIV_ENABLED" then
			if g_civEnabledPolicies[policy.ID] then
				policy.GridX = g_civEnabledPolicies[policy.ID].x	--positions are civ-specific
				policy.GridY = g_civEnabledPolicies[policy.ID].y
				prereq.GridX = g_civEnabledPolicies[prereq.ID].x	--This WILL cause an error when you make a civ-enabled policy prereq that is not also civ-enabled (I warned you!)
				prereq.GridY = g_civEnabledPolicies[prereq.ID].y
			else
				policy = nil
			end		
		end
		--end Paz add
		if policy and prereq then
		
			local thisPipe = policyPipes[row.PrereqPolicy];
		
			if policy.GridY - prereq.GridY > 1 or policy.GridY - prereq.GridY < -1 then
				local xOffset = (prereq.GridX-1)*g_PolicyPipeXOffset + 30;
				local pipe = GetPipe(policy.PolicyBranchType);
				pipe.ConnectorImage:SetOffsetVal( xOffset, (prereq.GridY-1)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(vTexture);
				local size = { x = 19; y = g_PolicyPipeYOffset*(policy.GridY - prereq.GridY - 1); };
				pipe.ConnectorImage:SetSize(size);
			end
			
			if policy.GridX - prereq.GridX == 1 then
				local xOffset = (prereq.GridX-1)*g_PolicyPipeXOffset + 30;
				local pipe = GetPipe(policy.PolicyBranchType);
				pipe.ConnectorImage:SetOffsetVal( xOffset + 16, (prereq.GridY-1 + thisPipe.yOffset)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(hTexture);
				local size = { x = 19; y = 19; };
				pipe.ConnectorImage:SetSize(size);
			end
			if policy.GridX - prereq.GridX == 2 then
				local xOffset = (prereq.GridX-1)*g_PolicyPipeXOffset + 30;
				local pipe = GetPipe(policy.PolicyBranchType);
				pipe.ConnectorImage:SetOffsetVal( xOffset + 16, (prereq.GridY-1 + thisPipe.yOffset)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(hTexture);
				local size = { x = 40; y = 19; };
				pipe.ConnectorImage:SetSize(size);
			end
			if policy.GridX - prereq.GridX == -2 then
				local xOffset = (policy.GridX-1)*g_PolicyPipeXOffset + 30;
				local pipe = GetPipe(policy.PolicyBranchType);
				pipe.ConnectorImage:SetOffsetVal( xOffset + 16, (prereq.GridY-1 + thisPipe.yOffset)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(hTexture);
				local size = { x = 40; y = 19; };
				pipe.ConnectorImage:SetSize(size);
			end
			if policy.GridX - prereq.GridX == -1 then
				local xOffset = (policy.GridX-1)*g_PolicyPipeXOffset + 30;
				local pipe = GetPipe(policy.PolicyBranchType);
				pipe.ConnectorImage:SetOffsetVal( xOffset + 16, (prereq.GridY-1 + thisPipe.yOffset)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(hTexture);
				local size = { x = 20; y = 19; };
				pipe.ConnectorImage:SetSize(size);
			end
			
		end
	end
	
	-- Down	
	for pipeIndex, thisPipe in pairs(policyPipes) do
		local policy = GameInfo.Policies[thisPipe.policyType];
		--Paz add
		if g_civEnabledPolicies[policy.ID] then
			policy.GridX = g_civEnabledPolicies[policy.ID].x	--positions are civ-specific
			policy.GridY = g_civEnabledPolicies[policy.ID].y
		end
		--end Paz add
		local xOffset = (policy.GridX-1)*g_PolicyPipeXOffset + 30;
		if thisPipe.downConnectionType >= 1 then
			
			local startPipe = GetPipe(policy.PolicyBranchType);
			startPipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset + 48 );
			startPipe.ConnectorImage:SetTexture(vTexture);
			
			local pipe = GetPipe(policy.PolicyBranchType);			
			if thisPipe.downConnectionType == 1 then
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(vTexture);
			elseif thisPipe.downConnectionType == 2 then
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1 + thisPipe.yOffset)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(bottomRightTexture);
			elseif thisPipe.downConnectionType == 3 then
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(vTexture);
				pipe = GetPipe(policy.PolicyBranchType);			
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1 + thisPipe.yOffset)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(bottomRightTexture);
			elseif thisPipe.downConnectionType == 4 then
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(bottomLeftTexture);
			elseif thisPipe.downConnectionType == 5 then
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(vTexture);
				pipe = GetPipe(policy.PolicyBranchType);			
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1 + thisPipe.yOffset)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(bottomLeftTexture);
			elseif thisPipe.downConnectionType == 6 then
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1 + thisPipe.yOffset)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(bottomRightTexture);
				pipe = GetPipe(policy.PolicyBranchType);		
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1 + thisPipe.yOffset)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(bottomLeftTexture);
			else
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(vTexture);
				pipe = GetPipe(policy.PolicyBranchType);		
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1 + thisPipe.yOffset)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(bottomRightTexture);
				pipe = GetPipe(policy.PolicyBranchType);
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1 + thisPipe.yOffset)*g_PolicyPipeYOffset + 58 );
				pipe.ConnectorImage:SetTexture(bottomLeftTexture);
			end
		end
	end

	-- Up
	for pipeIndex, thisPipe in pairs(policyPipes) do
		local policy = GameInfo.Policies[thisPipe.policyType];
		--Paz add
		if g_civEnabledPolicies[policy.ID] then
			policy.GridX = g_civEnabledPolicies[policy.ID].x	--positions are civ-specific
			policy.GridY = g_civEnabledPolicies[policy.ID].y
		end
		--end Paz add
		local xOffset = (policy.GridX-1)*g_PolicyPipeXOffset + 30;
		
		if thisPipe.upConnectionType >= 1 then
			
			local startPipe = GetPipe(policy.PolicyBranchType);
			startPipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset + 0 );
			startPipe.ConnectorImage:SetTexture(vTexture);
			
			local pipe = GetPipe(policy.PolicyBranchType);			
			if thisPipe.upConnectionType == 1 then
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset - 10 );
				pipe.ConnectorImage:SetTexture(vTexture);
			elseif thisPipe.upConnectionType == 2 then
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset - 10 );
				pipe.ConnectorImage:SetTexture(topRightTexture);
			elseif thisPipe.upConnectionType == 3 then
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset - 10 );
				pipe.ConnectorImage:SetTexture(vTexture);
				pipe = GetPipe(policy.PolicyBranchType);			
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset - 10 );
				pipe.ConnectorImage:SetTexture(topRightTexture);
			elseif thisPipe.upConnectionType == 4 then
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset - 10 );
				pipe.ConnectorImage:SetTexture(topLeftTexture);
			elseif thisPipe.upConnectionType == 5 then
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset - 10 );
				pipe.ConnectorImage:SetTexture(vTexture);
				pipe = GetPipe(policy.PolicyBranchType);			
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset - 10 );
				pipe.ConnectorImage:SetTexture(topLeftTexture);
			elseif thisPipe.upConnectionType == 6 then
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset - 10 );
				pipe.ConnectorImage:SetTexture(topRightTexture);
				pipe = GetPipe(policy.PolicyBranchType);		
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset - 10 );
				pipe.ConnectorImage:SetTexture(topLeftTexture);
			else
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset - 10 );
				pipe.ConnectorImage:SetTexture(vTexture);
				pipe = GetPipe(policy.PolicyBranchType);		
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset - 10 );
				pipe.ConnectorImage:SetTexture(topRightTexture);
				pipe = GetPipe(policy.PolicyBranchType);
				pipe.ConnectorImage:SetOffsetVal( xOffset, (policy.GridY-1)*g_PolicyPipeYOffset - 10 );
				pipe.ConnectorImage:SetTexture(topLeftTexture);
			end
		end
	end

	-- Add Policy buttons
	i = 0;
	policyInfo = GameInfo.Policies[i];
	while policyInfo ~= nil do
		
		local iBranch = policyInfo.PolicyBranchType;

		--Paz add: skip for anti-Theism or non civ-enabled
		if iBranch == "POLICY_BRANCH_ANTI_THEISM" then
			iBranch = nil
		elseif iBranch == "POLICY_BRANCH_CIV_ENABLED" then
			if g_civEnabledPolicies[policyInfo.ID] then
				policyInfo.GridX = g_civEnabledPolicies[policyInfo.ID].x	--positions are civ-specific
				policyInfo.GridY = g_civEnabledPolicies[policyInfo.ID].y
			else
				iBranch = nil
			end
		end
		--end Paz add

		-- If this is nil it means the Policy is a freebie handed out with the Branch, so don't display it
		if (iBranch ~= nil) then
			
			local controlTable = nil;
			
			-- decide which panel it goes on
			--Paz: swapped policy branches as indidicated in header
			if iBranch == "POLICY_BRANCH_PANTHEISM" then
				controlTable = g_LibertyInstanceManager:GetInstance();
			elseif iBranch == "POLICY_BRANCH_DOMINIONISM" then
				controlTable = g_TraditionInstanceManager:GetInstance();
			elseif iBranch == "POLICY_BRANCH_THEISM" then
				controlTable = g_HonorInstanceManager:GetInstance();
			elseif iBranch == "POLICY_BRANCH_ARCANA" then
				controlTable = g_PietyInstanceManager:GetInstance();
			elseif iBranch == "POLICY_BRANCH_SLAVERY" then
				controlTable = g_PatronageInstanceManager:GetInstance();
			elseif iBranch == "POLICY_BRANCH_CIV_ENABLED" then
				controlTable = g_CommerceInstanceManager:GetInstance();
			elseif iBranch == "POLICY_BRANCH_COMMERCE" then
				controlTable = g_RationalismInstanceManager:GetInstance();
			elseif iBranch == "POLICY_BRANCH_TRADITION" then
				controlTable = g_FreedomInstanceManager:GetInstance();
			--elseif iBranch == "POLICY_BRANCH_ORDER" then
			--	controlTable = g_OrderInstanceManager:GetInstance();
			elseif iBranch == "POLICY_BRANCH_MILITARISM" then
				controlTable = g_AutocracyInstanceManager:GetInstance();
			end
			
			IconHookup( policyInfo.PortraitIndex, 64, policyInfo.IconAtlas, controlTable.PolicyImage );

			-- this math should match Russ's mocked up layout
			controlTable.PolicyIcon:SetOffsetVal((policyInfo.GridX-1)*g_PolicyXOffset+16,(policyInfo.GridY-1)*g_PolicyYOffset+12);
			controlTable.PolicyIcon:SetVoid1( i ); -- indicates which policy
			controlTable.PolicyIcon:RegisterCallback( Mouse.eLClick, PolicySelected );
			
			-- store this away for later
			policyIcons[i] = controlTable;
		end
		
		i = i + 1;
		policyInfo = GameInfo.Policies[i];
	end
	
end

function OnYes( )
	Controls.PolicyConfirm:SetHide(true);
	Controls.BGBlock:SetHide(false);
	
	Network.SendUpdatePolicies(m_gPolicyID, m_gAdoptingPolicy, true);
	Events.AudioPlay2DSound("AS2D_INTERFACE_POLICY");		
	--Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_DECLARES_WAR, g_iAIPlayer, 0, 0 );
end
Controls.Yes:RegisterCallback( Mouse.eLClick, OnYes );

function OnNo( )
	Controls.PolicyConfirm:SetHide(true);
	Controls.BGBlock:SetHide(false);
end
Controls.No:RegisterCallback( Mouse.eLClick, OnNo );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ShowHideHandler( bIsHide, bInitState )
    if( not bInitState ) then
        Controls.PolicyInfo:SetCheck( OptionsManager.GetPolicyInfo() );
        if( not bIsHide ) then
        	UI.incTurnTimerSemaphore();
        	--OpenAdvisorPopup(ButtonPopupTypes.BUTTONPOPUP_CHOOSEPOLICY);
        	Events.SerialEventGameMessagePopupShown(m_PopupInfo);
        else
            UI.decTurnTimerSemaphore();
            --CloseAdvisorPopup(ButtonPopupTypes.BUTTONPOPUP_CHOOSEPOLICY);
            Events.SerialEventGameMessagePopupProcessed.CallImmediate(ButtonPopupTypes.BUTTONPOPUP_CHOOSEPOLICY, 0);
        end
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

----------------------------------------------------------------
-- 'Active' (local human) player has changed
----------------------------------------------------------------
function OnActivePlayerChanged()
	if (not Controls.PolicyConfirm:IsHidden()) then
		Controls.PolicyConfirm:SetHide(true);
    	Controls.BGBlock:SetHide(false);
	end
	--[[Paz modified below
	OnClose();
	]]
	UIManager:DequeuePopup( ContextPtr )
	Init()
	--end Paz modified
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged);

Init();