-- EaMiscUtils
-- Author: Pazyryk
-- DateCreated: 5/6/2013 11:28:37 PM
--------------------------------------------------------------

local DOMAIN_SEA = GameInfoTypes.DOMAIN_SEA

local Floor = math.floor

function GetUnitAIPowerEa(unit)		--modified from below (skip morale and don't compound!)	NOT CHANGED YET!
	local power = unit:GetBaseCombatStrength() ^ 1.5
	local rangedStrength = unit:GetBaseRangedCombatStrength() ^ 1.45
	if unit:GetDomainType() == DOMAIN_SEA then
		rangedStrength = rangedStrength / 2
	end
	if rangedStrength > 0 then
		power = rangedStrength
	end
	power = power * (unit:MaxMoves() / 60) ^ 0.3
	local unitInfo = GameInfo.Units[unit:GetUnitType()]
	if unitInfo.Suicide then
		power = power / 2
	end
	if unit:NukeDamageLevel() > 0 then
		power = power + 4000
	end

	for promoInfo in GameInfo.UnitPromotions() do
		if unit:IsHasPromotion(promoInfo.ID) then
			if promoInfo.CityAttack > 0 then
				power = power + (power * promoInfo.CityAttack / 200)
			end
			if promoInfo.AttackMod > 0 then
				power = power + (power * promoInfo.AttackMod / 200)
			end
			if promoInfo.DefenseMod > 0 then
				power = power + (power * promoInfo.DefenseMod / 200)
			end
			if promoInfo.DropRange > 0 then
				power = power + power / 4
			end
			if promoInfo.Blitz then
				power = power + power / 5
			end
			if promoInfo.MustSetUpToRangedAttack then
				power = power - power / 5
			end
			if promoInfo.OnlyDefensive and rangedStrength == 0 then
				power = power - power / 4
			end
			local searchStr = "PromotionType = '" .. promoInfo.Type .. "'"
			for row in GameInfo.UnitPromotions_Terrains(searchStr) do
				power = power + (power * row.Attack / 400)
				power = power + (power * row.Defense / 400)
			end
			for row in GameInfo.UnitPromotions_Features(searchStr) do
				power = power + (power * row.Attack / 400)
				power = power + (power * row.Defense / 400)
			end
			for row in GameInfo.UnitPromotions_UnitCombatMods(searchStr) do
				power = power + (power * row.Modifier / 400)
			end
			for row in GameInfo.UnitPromotions_UnitClasses(searchStr) do
				power = power + (power * row.Modifier / 800)
				power = power + (power * row.Attack / 1000)
				power = power + (power * row.Defense / 1000)
			end
			for row in GameInfo.UnitPromotions_Domains(searchStr) do
				power = power + (power * row.Modifier / 400)
			end
		end
	end
	return power
end
local GetUnitAIPowerEa = GetUnitAIPowerEa


function GetMercenaryCosts(unit, power, discountLevel)		--supply either unit or power; discount 1 or 2 means 10%, 20%
	power = power or GetUnitAIPowerEa(unit)
	local totalCost = 2 * power						--adjust
	if discountLevel == 1 then
		totalCost = totalCost * 0.9
	elseif discountLevel == 2 then
		totalCost = totalCost * 0.8
	end
	local gpt = Floor((totalCost + 30) / 60)
	local upFront = Floor(totalCost - gpt * 30)
	return totalCost, upFront, gpt
end

--[[
function GetUnitAIPower(unit)		--replica of dll logic; this is how AI evaluates unit power
	local power = unit:GetBaseCombatStrength() ^ 1.5
	local rangedStrength = unit:GetBaseRangedCombatStrength() ^ 1.45
	if unit:GetDomainType() == DOMAIN_SEA then
		rangedStrength = rangedStrength / 2
	end
	if rangedStrength > 0 then
		power = rangedStrength
	end
	power = power * (unit:MaxMoves() / 60) ^ 0.3
	local unitInfo = GameInfo.Units[unit:GetUnitType()]
	if unitInfo.Suicide then
		power = power / 2
	end
	if unit:NukeDamageLevel() > 0 then
		power = power + 4000
	end

	for promoInfo in GameInfo.UnitPromotions() do
		if unit:IsHasPromotion(promoInfo.ID) then
			if promoInfo.CityAttack > 0 then
				power = power + (power * promoInfo.CityAttack / 200)
			end
			if promoInfo.AttackMod > 0 then
				power = power + (power * promoInfo.AttackMod / 200)
			end
			if promoInfo.DefenseMod > 0 then
				power = power + (power * promoInfo.DefenseMod / 200)
			end
			if promoInfo.DropRange > 0 then
				power = power + power / 4
			end
			if promoInfo.Blitz then
				power = power + power / 5
			end
			if promoInfo.MustSetUpToRangedAttack then
				power = power - power / 5
			end
			if promoInfo.OnlyDefensive and rangedStrength == 0 then
				power = power - power / 4
			end
			local searchStr = "PromotionType = '" .. promoInfo.Type .. "'"
			for row in GameInfo.UnitPromotions_Terrains(searchStr) do
				power = power + (power * row.Attack / 400)
				power = power + (power * row.Defense / 400)
			end
			for row in GameInfo.UnitPromotions_Features(searchStr) do
				power = power + (power * row.Attack / 400)
				power = power + (power * row.Defense / 400)
			end
			for row in GameInfo.UnitPromotions_UnitCombatMods(searchStr) do
				power = power + (power * row.Modifier / 400)
			end
			for row in GameInfo.UnitPromotions_UnitClasses(searchStr) do
				power = power + (power * row.Modifier / 800)
				power = power + (power * row.Attack / 1000)
				power = power + (power * row.Defense / 1000)
			end
			for row in GameInfo.UnitPromotions_Domains(searchStr) do
				power = power + (power * row.Modifier / 400)
			end
		end
	end
	return power
end
local GetUnitAIPower = GetUnitAIPower
]]