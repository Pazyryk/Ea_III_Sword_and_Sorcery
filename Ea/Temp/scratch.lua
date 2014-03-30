


function Test()

end

--EA_SPELL_EXPLOSIVE_RUNES
TestTarget[GameInfoTypes.EA_SPELL_EXPLOSIVE_RUNES] = function()
	if g_faith < g_modSpell then
		g_testTargetSwitch = 1
		return false
	end
	g_int1, g_int2, g_int3, g_int4 = g_plot:GetPlotEffectData()	--effectID, effectStength, iEffectPlayer, iCaster
	if g_int1 ~= -1 then
		if g_int3 == g_iPlayer then
			g_testTargetSwitch = 2
			return false			
		end
		--need more logic here for overwriteable effects
		g_testTargetSwitch = 3
		return false
	end
	return true
end

SetUI[GameInfoTypes.EA_SPELL_EXPLOSIVE_RUNES] = function()
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
		if g_bAllTestsPassed then
			MapModData.text = "Place Explosive Runes on this plot"
		elseif g_testTargetSwitch == 1 then
			MapModData.text = "[COLOR_WARNING_TEXT]You do not have sufficent mana (requres " .. g_modSpell .. ")[ENDCOLOR]"
		elseif g_testTargetSwitch == 2 then
			MapModData.text = "[COLOR_WARNING_TEXT]Your civilization has already placed a Glyph, Rune or Ward on this plot[ENDCOLOR]"
		elseif g_testTargetSwitch == 3 then
			MapModData.text = "[COLOR_WARNING_TEXT]Another civilization has placed a Glyph, Rune or Ward on this plot[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_EXPLOSIVE_RUNES] = function()	--already restricted by AI heuristic; just value good defence plot
	gg_aiOptionValues.i = 10		--placeholder
end

Finish[GameInfoTypes.EA_SPELL_EXPLOSIVE_RUNES] = function()
	g_plot:SetPlotEffectData(GameInfoTypes.EA_PLOTEFFECT_EXPLOSIVE_RUNES, g_modSpell, g_iPlayer, g_iPerson)	--effectID, effectStength, iPlayer, iCaster
end


