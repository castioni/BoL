--[[
	AutoCarry Plugin - Hecarim The Shadow Of War 1.0 by Jaikor & Skeem
	With Code from Kain
	Auto Level from Dekaron
	AoE Skillshot by monogato
	All credit goes Basicly to Skeem & to them.
	I'm Still learning so don't be hard.
	Copyright 2013
	Changelog :
   1.0 - Initial Release
   To DO ?: 
   Let me know what else U would like to see in it.
   Knows Bugs:
   Need To Fix the Auto HP POTS and MANA, will update this ASAP ! meanwhile U can disable it in the menu so I won't spam pots.
 ]] --

if myHero.charName ~= "Hecarim" then return end

--[Function When Plugin Loads]--
function PluginOnLoad()
	mainLoad() -- Loads our Variable Function
	mainMenu() -- Loads our Menu function
end

--[OnTick]--
function PluginOnTick()
	if Recall then return end
	if IsSACReborn then
		AutoCarry.Crosshair:SetSkillCrosshairRange(1000)
	else
		AutoCarry.SkillsCrosshair.range = 1000
	end
	Checks()
	
	if Carry.AutoCarry then FullCombo() end
	if Carry.MixedMode and Target then 
		if Menu.qHarass and not IsMyManaLow() and GetDistance(Target) <= qRange then CastSpell(_Q) end
	end
	if Carry.LaneClear then JungleClear() end
	
	if Extras.ZWItems and IsMyHealthLow() and Target and (ZNAREADY or WGTREADY) then CastSpell((wgtSlot or znaSlot)) end
	if Extras.aHP and NeedHP() and not (UsingHPot or UsingFlask) and (HPREADY or FSKREADY) then CastSpell((hpSlot or fskSlot)) end
	if Extras.aMP and IsMyManaLow() and not (UsingMPot or UsingFlask) and(MPREADY or FSKREADY) then CastSpell((mpSlot or fskSlot)) end
	if Extras.AutoLevelSkills then autoLevelSetSequence(levelSequence) end
	
end

--[Drawing our Range/Killable Enemies]--
function PluginOnDraw()
	if not myHero.dead then
		if WREADY and Menu.wDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0x191970)
		end
	end
end

--[Object Detection]--
function PluginOnCreateObj(obj)
	if obj.name:find("TeleportHome.troy") then
		if GetDistance(obj, myHero) <= 70 then
			Recall = true
		end
	end
	if obj.name:find("Regenerationpotion_itm.troy") then
		if GetDistance(obj, myHero) <= 70 then
			UsingHPot = true
		end
	end
	if obj.name:find("ManaPotion_itm.troy") then
		if GetDistance(obj, myHero) <= 70 then
			UsingMPot = true
		end
	end
	if obj.name:find("potion_manaheal") then
		if GetDistance(obj, myHero) <= 70 then
			UsingFlask = true
		end
	end
end

function PluginOnDeleteObj(obj)
	if obj.name:find("TeleportHome.troy") then
		Recall = false
	end
	if obj.name:find("Regenerationpotion_itm.troy") then
		UsingHPot = false
	end
	if obj.name:find("ManaPotion_itm.troy") then
		UsingMPot = false
	end
	if obj.name:find("potion_manaheal") then
		UsingFlask = false
	end
end

--[Low Mana Function by Kain]--
function IsMyManaLow()
    if myHero.mana < (myHero.maxMana * ( Extras.MinMana / 100)) then
        return true
    else
        return false
    end
end

--[/Low Mana Function by Kain]--

--[Low Health Function Trololz]--
function IsMyHealthLow()
	if myHero.health < (myHero.maxHealth * ( Extras.ZWHealth / 100)) then
		return true
	else
		return false
	end
end
--[/Low Health Function Trololz]--

--[Health Pots Function]--
function NeedHP()
	if myHero.health < (myHero.maxHealth * ( Extras.HPHealth / 100)) then
		return true
	else
		return false
	end
end

function CountEnemies(point, range)
        local ChampCount = 0
        for j = 1, heroManager.iCount, 1 do
                local enemyhero = heroManager:getHero(j)
                if myHero.team ~= enemyhero.team and ValidTarget(enemyhero, QRange) then
                        if GetDistance(enemyhero, point) <= range then
                                ChampCount = ChampCount + 1
                        end
                end
        end            
        return ChampCount
end

function CastR(Target)
    if RREADY then
		local ultPos = GetAoESpellPosition(300, Target)
		if ultPos and GetDistance(ultPos) <= rRange then
			if CountEnemies(ultPos, 300) > 1 then
				CastSpell(_R, ultPos.x, ultPos.z)
			end
		end
		if IsSACReborn then
			SkillR:Cast(Target)
		else
			AutoCarry.CastSkillshot(SkillR, Target)
		end
	end
 end

--[Full Combo with Items]--
function FullCombo()
	if Target then
		if AutoCarry.MainMenu.AutoCarry then
			 if GetDistance(Target) <= eRange then CastSpell(_E) end
			 if GetDistance(Target) <= wRange then CastSpell(_W) end
			 if GetDistance(Target) <= qRange then CastSpell(_Q) end
			 if Menu.useR and GetDistance(Target) <= rRange then CastR(Target) end
		end
	end
end

function JungleClear()
	if IsSACReborn then
		JungleMob = AutoCarry.Jungle:GetAttackableMonster()
	else
		JungleMob = AutoCarry.GetMinionTarget()
	end
	if JungleMob ~= nil and not IsMyManaLow() then
		if Extras.JungleQ and GetDistance(JungleMob) <= qRange then CastQ(JungleMob) end
		if Extras.JungleW and GetDistance(JungleMob) <= wRange then CastW(JungleMob) end
	end
end

--[Variables Load]--
function mainLoad()
	if AutoCarry.Skills then IsSACReborn = true else IsSACReborn = false end
	if IsSACReborn then AutoCarry.Skills:DisableAll() end
	Carry = AutoCarry.MainMenu
	qRange,wRange,eRange,rRange = 350, 525, 800, 1000
	QREADY, WREADY, EREADY, RREADY = false, false, false, false
	qName, wName, eName, rName = "Rampage", "Spirit of Dread", "Devastating Charge", "Onslaught of Shadows"
	HK1, HK2, HK3 = string.byte("Z"), string.byte("K"), string.byte("G")
	Menu = AutoCarry.PluginMenu
	UsingHPot, UsingMPot, UsingFlask = false, false, false
	Recall = false, false, false
	TextList = {"Harass him!!", "FULL COMBO KILL!"}
	KillText = {}
	waittxt = {} -- prevents UI lags, all credits to Dekaron
	for i=1, heroManager.iCount do waittxt[i] = i*3 end -- All credits to Dekaron
	levelSequence = { 1, 2, 3, 1, 2, 4, 1, 1, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
	if IsSACReborn then
		SkillR = AutoCarry.Skills:NewSkill(false, _R, rRange, rName, AutoCarry.SPELL_CIRCLE, 0, false, false, 1.2, 250, 300, false)
	else
		SkillR = {spellKey = _R, range = rRange, speed = 1.2, delay = 250, width = 300, configName = rName, displayName = "R "..rName.."", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = false }
	end	
end

--[Main Menu & Extras Menu]--
function mainMenu()
	Menu:addParam("sep1", "-- Full Combo Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("useQ", "Use "..qName.." (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useW", "Use "..wName.." (W)", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useE", "Use "..eName.." (E)", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useR", "Use "..rName.." (R)", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep2", "-- Mixed Mode Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("qHarass", "Use "..qName.." (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep5", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("wDraw", "Draw "..wName.." (W)", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("cDraw", "Draw Enemy Text", SCRIPT_PARAM_ONOFF, true)
	Extras = scriptConfig("Sida's Auto Carry Plugin: "..myHero.charName..": Extras", myHero.charName)
	Extras:addParam("sep6", "-- Misc --", SCRIPT_PARAM_INFO, "")
	Extras:addParam("JungleQ", "Jungle with "..qName.." (Q)", SCRIPT_PARAM_ONOFF, true)
	Extras:addParam("JungleW", "Jungle with "..eName.." (W)", SCRIPT_PARAM_ONOFF, true)
	Extras:addParam("MinMana", "Minimum Mana for Jungle/Harass %", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
	Extras:addParam("ZWItems", "Auto Zhonyas/Wooglets", SCRIPT_PARAM_ONOFF, true)
	Extras:addParam("ZWHealth", "Min Health % for Zhonyas/Wooglets", SCRIPT_PARAM_SLICE, 15, 0, 100, -1)
	Extras:addParam("aHP", "Auto Health Pots", SCRIPT_PARAM_ONOFF, true)
	Extras:addParam("aMP", "Auto Auto Mana Pots", SCRIPT_PARAM_ONOFF, true)
	Extras:addParam("HPHealth", "Min % for Health Pots", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
	Extras:addParam("AutoLevelSkills", "Auto Level Skills (Requires Reload)", SCRIPT_PARAM_ONOFF, true)
end

--[Certain Checks]--
function Checks()
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
	if IsSACReborn then Target = AutoCarry.Crosshair:GetTarget() else Target = AutoCarry.GetAttackTarget() end
	dfgSlot, hxgSlot, bwcSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144)
	brkSlot = GetInventorySlotItem(3092),GetInventorySlotItem(3143),GetInventorySlotItem(3153)
	znaSlot, wgtSlot = GetInventorySlotItem(3157),GetInventorySlotItem(3090)
	hpSlot, mpSlot, fskSlot = GetInventorySlotItem(2003),GetInventorySlotItem(2004),GetInventorySlotItem(2041)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	DFGREADY = (dfgSlot ~= nil and myHero:CanUseSpell(dfgSlot) == READY)
	HXGREADY = (hxgSlot ~= nil and myHero:CanUseSpell(hxgSlot) == READY)
	BWCREADY = (bwcSlot ~= nil and myHero:CanUseSpell(bwcSlot) == READY)
	BRKREADY = (brkSlot ~= nil and myHero:CanUseSpell(brkSlot) == READY)
	ZNAREADY = (znaSlot ~= nil and myHero:CanUseSpell(znaSlot) == READY)
	WGTREADY = (wgtSlot ~= nil and myHero:CanUseSpell(wgtSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	HPREADY = (hpSlot ~= nil and myHero:CanUseSpell(hpSlot) == READY)
	MPREADY =(mpSlot ~= nil and myHero:CanUseSpell(mpSlot) == READY)
	FSKREADY = (fskSlot ~= nil and myHero:CanUseSpell(fskSlot) == READY)
end

--------------------------------------- END OF HECARIM SCRIPT ----------------------------------------------------------

--[[ 
        AoE_Skillshot_Position 2.0 by monogato
        
        GetAoESpellPosition(radius, main_target, [delay]) returns best position in order to catch as many enemies as possible with your AoE skillshot, making sure you get the main target.
        Note: You can optionally add delay in ms for prediction (VIP if avaliable, normal else).
]]

function GetCenter(points)
        local sum_x = 0
        local sum_z = 0
        
        for i = 1, #points do
                sum_x = sum_x + points[i].x
                sum_z = sum_z + points[i].z
        end
        
        local center = {x = sum_x / #points, y = 0, z = sum_z / #points}
        
        return center
end

function ContainsThemAll(circle, points)
        local radius_sqr = circle.radius*circle.radius
        local contains_them_all = true
        local i = 1
        
        while contains_them_all and i <= #points do
                contains_them_all = GetDistanceSqr(points[i], circle.center) <= radius_sqr
                i = i + 1
        end
        
        return contains_them_all
end

-- The first element (which is gonna be main_target) is untouchable.
function FarthestFromPositionIndex(points, position)
        local index = 2
        local actual_dist_sqr
        local max_dist_sqr = GetDistanceSqr(points[index], position)
        
        for i = 3, #points do
                actual_dist_sqr = GetDistanceSqr(points[i], position)
                if actual_dist_sqr > max_dist_sqr then
                        index = i
                        max_dist_sqr = actual_dist_sqr
                end
        end
        
        return index
end

function RemoveWorst(targets, position)
        local worst_target = FarthestFromPositionIndex(targets, position)
        
        table.remove(targets, worst_target)
        
        return targets
end

function GetInitialTargets(radius, main_target)
        local targets = {main_target}
        local diameter_sqr = 4 * radius * radius
        
        for i=1, heroManager.iCount do
                target = heroManager:GetHero(i)
                if target.networkID ~= main_target.networkID and ValidTarget(target) and GetDistanceSqr(main_target, target) < diameter_sqr then table.insert(targets, target) end
        end
        
        return targets
end

function GetPredictedInitialTargets(radius, main_target, delay)
        if VIP_USER and not vip_target_predictor then vip_target_predictor = TargetPredictionVIP(nil, nil, delay/1000) end
        local predicted_main_target = VIP_USER and vip_target_predictor:GetPrediction(main_target) or GetPredictionPos(main_target, delay)
        local predicted_targets = {predicted_main_target}
        local diameter_sqr = 4 * radius * radius
        
        for i=1, heroManager.iCount do
                target = heroManager:GetHero(i)
                if ValidTarget(target) then
                        predicted_target = VIP_USER and vip_target_predictor:GetPrediction(target) or GetPredictionPos(target, delay)
                        if target.networkID ~= main_target.networkID and GetDistanceSqr(predicted_main_target, predicted_target) < diameter_sqr then table.insert(predicted_targets, predicted_target) end
                end
        end
        
        return predicted_targets
end

-- I don't need range since main_target is gonna be close enough. You can add it if you do.
function GetAoESpellPosition(radius, main_target, delay)
        local targets = delay and GetPredictedInitialTargets(radius, main_target, delay) or GetInitialTargets(radius, main_target)
        local position = GetCenter(targets)
        local best_pos_found = true
        local circle = Circle(position, radius)
        circle.center = position
        
        if #targets > 2 then best_pos_found = ContainsThemAll(circle, targets) end
        
        while not best_pos_found do
                targets = RemoveWorst(targets, position)
                position = GetCenter(targets)
                circle.center = position
                best_pos_found = ContainsThemAll(circle, targets)
        end
        
        return position, #targets
end