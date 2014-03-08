-- EaAIPeople
-- Author: Pazyryk
-- DateCreated: 1/17/2013 6:27:36 PM
--------------------------------------------------------------
print("Loading EaAIPeople.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

--------------------------------------------------------------
-- Local Defines
--------------------------------------------------------------

local Rand = Map.Rand



function AIPickGPPromotion(iPlayer, iPerson, unit)		--must have unit if on map; otherwise assume disappeared
	print("Running AIPickGPPromotion ", iPlayer, iPerson, unit)
	--need logic; for now, just pick any random valid
	local eaPerson = gPeople[iPerson]
	local aiSpecialization = eaPerson.aiSpecialization or PickPersonAISpecialization(iPlayer, iPerson)	--must be something, even if "None"

	if eaPerson.spells then
		if Rand(2, "hello") < 1 then		--50/50 try to learn a spell rather than take promotion (spell casters should naturally learn all within specialization)
			local spellClass
			if eaPerson.class1 == "Devout" or eaPerson.class2 == "Devout" then
				if eaPerson.class1 ~= "Thaumaturge" and eaPerson.class2 ~= "Thaumaturge" then
					spellClass = "Divine"
				end
			elseif eaPerson.class1 == "Thaumaturge" or eaPerson.class2 == "Thaumaturge" then
				if eaPerson.class1 ~= "Devout" and eaPerson.class2 ~= "Devout" then
					spellClass = "Arcane"
				end
			end		--spellClass=nil for dual-class will give both
			local spellList = GenerateLearnableSpellList(iPlayer, iPerson, spellClass, aiSpecialization)
			local numSpells = #spellList
			if numSpells > 0 then
				local spellID = spellList[Rand(numSpells, "hello") + 1]
				eaPerson.spells[spellID] = true
				ApplyGPLevelGain(iPlayer, unit, iPerson)
				print("Learned Spell: ", GameInfo.EaActions[spellID].Type)
				return
			end
		end
	end

	local promotionTable = GetAvailableGreatPersonPromotions(iPlayer, iPerson, aiSpecialization)	--aiSpecialization doesn't work yet except to exclude PROMOTION_LEARN_SPELL

	local numPromos = #promotionTable
	if numPromos > 0 then

		local promoID = promotionTable[Rand(numPromos, "AI promo pick") + 1]
		ApplyGPPromotion(iPlayer, unit, iPerson, promoID, true)
		print("Picked promotion: ", GameInfo.UnitPromotions[promoID].Type)
	else
		print("!!!! WARNING: AI had no promotions to select")
	end
end


function PickPersonAISpecialization(iPlayer, iPerson)
	--Keep it simple for now; will complexify when we have a good spell selection
	local eaPerson = gPeople[iPerson]
	local aiSpecialization = "None"
	if eaPerson.subclass == "Druid" then
		aiSpecialization = "Terraform"
	elseif eaPerson.subclass == "Priest" or eaPerson.subclass == "FallenPriest" or eaPerson.subclass == "Paladin" or eaPerson.subclass == "Eidolon" then
		aiSpecialization = "Combat"
	end
	eaPerson.aiSpecialization = aiSpecialization
	return aiSpecialization
end