--<<Necrophos V1.0C ✰ - by ☢bruninjaman☢>>--
--[[
☑ Script requested by rivaillle.
☛ This script do?
☑ Use Dagon, Death Pulse if enemy is in range and ult.
☑ Show If enemy is kilable by combo.
********************************************************************************
♜ Change Log ♜
➩ V1.0C - Monday, March 9, 2015 - Added Health bar and ultimate icon.
➩ V1.0B - Wednesday, March 5, 2015 - Fixed Damage Calculation.
➩ V1.0A - Wednesday, March 4, 2015 - Script Released.
]]

-- ✖ Libraries ✖ --
require("libs.Utils")
require("libs.ScriptConfig")
require("libs.TargetFind")

-- ✖ config ✖ --
config = ScriptConfig.new()
config:SetParameter("ComboKey", "D", config.TYPE_HOTKEY)
config:Load()

local ultcombo = config.ComboKey

-- Global Variables --
local me = nil
local Combodmg = 0
local healthtokill = 0
local percenthp = 0
local registered = false
local target = nil
local keyactive = false
local F11 = drawMgr:CreateFont("F11","Verdana",24,600)
local Killtext = drawMgr:CreateText(-20,-60,0xE61D1DFF,"Health to Kill: ".. (healthtokill) .." <--",F11) Killtext.visible = false
local damagebg2 = drawMgr:CreateRect(-53, -35, 110, 2, 0xA4A4A4FF) damagebg2.visible = false
local damagebg3 = drawMgr:CreateRect(-53, -35, 110, 2, 0xB40404FF) damagebg3.visible = false
local damagebg = drawMgr:CreateRect(-53, -35, 110, 2, 0x00FF00FF) damagebg.visible = false
local deadimg2 = drawMgr:CreateRect(-18,-62,34,33,0x1C1C1Cff) deadimg2.visible = false
local deadimg = drawMgr:CreateRect(-16,-60,30,30,0x000000ff) deadimg.visible  = false

-- ✖ When you start the game (check hero) ✖ --
function onLoad()
	if PlayingGame() then
		me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Necrolyte then 
			script:Disable()
			registered = false
		else
			registered = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(onLoad)
		end
	end 
end

-- ✖ pressing 'D' ✖ --
function Key(msg,code)
	me = entityList:GetMyHero()
	if not me then return end
	if client.chat or client.console or client.loading then return end
	if code == ultcombo then
		keyactive = (msg == KEY_DOWN)
	end
end

-- ✖ Starting Combo ✖ --
function Main(tick)
	me = entityList:GetMyHero()
	if not me then return end
	if not SleepCheck() then return end
	target = targetFind:GetClosestToMouse(100)
	if me:GetAbility(4).level > 0  and target and target.alive and target.visible then
		ScytheCombo()
		healthtokill = ScytheCombo()
	end
	if me:GetAbility(4).level > 0 then
		showdamage()
	end
end

-- ✖ END OF GAME  ✖ --
function onClose()
	collectgarbage("collect")
	if registered then
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		registered = false
	end
end

-- functions  \/      \/     \/       \/      \/      \/      \/ --
function showdamage()
	if target and target.alive and target.visible and GetDistance2D(me,target) < 2000 then
		Killtext.entity = target
		Killtext.entityPosition = Vector(0,0,target.healthbarOffset)
		damagebg.entity = target
		damagebg.entityPosition = Vector(0,0,target.healthbarOffset)
		damagebg2.entity = target
		damagebg2.entityPosition = Vector(0,0,target.healthbarOffset)
		damagebg3.entity = target
		damagebg3.entityPosition = Vector(0,0,target.healthbarOffset)
		deadimg2.entity = target
		deadimg2.entityPosition = Vector(0,0,target.healthbarOffset)
		deadimg.entity = target 
		deadimg.entityPosition = Vector(0,0,target.healthbarOffset)
		deadimg.textureId  = drawMgr:GetTextureId("NyanUI/spellicons/necrolyte_reapers_scythe")
		if healthtokill > 0 then
			Killtext.visible = true
			damagebg.visible = true
			damagebg2.visible = true
			damagebg3.visible = true
			deadimg2.visible = false
			deadimg.visible = false
			damagebg.w = percenthp
			if SleepCheck("delay") and damagebg.visible then
		        damagebg3.w = percenthp
				Sleep(1000,"delay")
			end
			Killtext.color = 0xE61D1DFF
			Killtext.text = "".. (healthtokill) ..""
		else
			Killtext.visible = false
			damagebg.visible = false
			deadimg.visible = true
			deadimg2.visible = true
			damagebg2.visible = false
			damagebg3.visible = false
		end
	else
		Killtext.visible = false
		damagebg.visible = false
		deadimg.visible = false
		deadimg2.visible = false
		damagebg2.visible = false
		damagebg3.visible = false
	end
end

-- Scythecombo variables
local dagon = nil
local ultimate = nil
local ethereal = nil
local DeathPulse = nil
local dmgD = 0
local dmgDP = 0
local dmgult = 0
local dmgethereal = 0
local DeathPulseSkill = { 75,125,200,275 }
local manapoint = 0
local aghanim = nil
local ultlvl = { 0.4,0.6,0.9 }
local Aultlvl = { 0.6,0.9,1.2 }
local etherealready = false
local predictedhp = 0
local percent = 0
local hptokill = 0

function ScytheCombo()
	dagon = me:FindDagon()
	ethereal = me:FindItem("item_ethereal_blade")
	ultimate = me:GetAbility(4)
	DeathPulse = me:GetAbility(1)
	manapoint = 0
	aghanim = me:FindItem("item_ultimate_scepter")
	if ethereal and ethereal:CanBeCasted() then
		dmgethereal = target:DamageTaken((2 * me.intellectTotal + 75),DAMAGE_MAGC,me)
		manapoint = manapoint + DeathPulse.manacost
		etherealready = true
	else
		dmgethereal = 0
		etherealready = false
	end 
	if DeathPulse.level > 0 and DeathPulse:CanBeCasted() and GetDistance2D(me,target) < 475 then
		dmgDP = target:DamageTaken((DeathPulseSkill[DeathPulse.level]),DAMAGE_MAGC,me) 
		manapoint = manapoint + DeathPulse.manacost
		if etherealready then
			dmgDP = dmgDP + (dmgDP * 0.4)
		end
	else
		dmgDP = 0
	end
	if dagon and dagon:CanBeCasted() then
		dmgD = target:DamageTaken((dagon:GetSpecialData("damage")),DAMAGE_MAGC,me)
		manapoint = manapoint + dagon.manacost
		if etherealready then
			dmgD = dmgD + (dmgD * 0.4)
		end
	else
		dmgD = 0
	end
	if ultimate.level > 0 and ultimate:CanBeCasted() and not aghanim then
		dmgult = ((target.maxHealth - target.health) * ultlvl[ultimate.level])
		percent = ultlvl[ultimate.level]
		if etherealready then
			dmgult = dmgult + (dmgult * 0.4)
		end
	elseif ultimate.level > 0 and ultimate:CanBeCasted() and aghanim then
		dmgult = ((target.maxHealth - target.health) * Aultlvl[ultimate.level])
		percent = Aultlvl[ultimate.level]
		if etherealready then
			dmgult = dmgult + (dmgult * 0.4)
		end
	else
		dmgult = 0
	end
	predictedhp = (target.health - (dmgethereal + dmgD + dmgDP))
	combodmg = ((target.health - predictedhp) + ((target.maxHealth - predictedhp) * percent))
	if ultimate.level > 0 and keyactive and target and target.alive and target.visible and target.health < combodmg and me.mana > manapoint and GetDistance2D(me,target) < 600 and not target:IsMagicDmgImmune() and target:CanDie() then
		if not me:IsChanneling() and me:CanCast() then
			if ethereal and ethereal:CanBeCasted() and ethereal.state == LuaEntityItem.STATE_READY then 
				me:CastItem("item_ethereal_blade",target)
				Sleep(100+me:GetTurnTime(target)*500)
			end
			if ultimate and ultimate:CanBeCasted() and not target:IsLinkensProtected() then
				me:CastAbility(ultimate,target)
				Sleep(ultimate:FindCastPoint()*800)
			end
			if DeathPulse.level > 0 and DeathPulse:CanBeCasted() and GetDistance2D(me,target) < 475 then
				me:SafeCastAbility(DeathPulse)
				Sleep(DeathPulse:FindCastPoint()*800)
			end
			if dagon and dagon:CanBeCasted() and dagon.state == LuaEntityItem.STATE_READY then 
				me:CastAbility(dagon,target)
				Sleep(100+me:GetTurnTime(target)*500)
			end
		end
	end
	hptokill = (( percent / (1 + percent )) * target.maxHealth ) -- THANKS NOVA
	hptokill = target:DamageTaken(hptokill,DAMAGE_MAGC,me)
	healthtokill = math.floor((target.health - (dmgethereal + dmgD + dmgDP) - hptokill))
	percenthp = math.floor(160*(healthtokill/target.maxHealth ))
	return healthtokill
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)