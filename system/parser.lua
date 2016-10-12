local _, NeP = ...

NeP.Parser = {}

local function IsMountedCheck()
	for i = 1, 40 do
		local mountID = select(11, UnitBuff('player', i))
		if mountID and NeP.ByPassMounts(mountID) then
			return true
		end
	end
	return not IsMounted()
end

local function castingTime()
	local time = GetTime()
	local name, _,_,_,_, endTime = UnitCastingInfo("player")
	if endTime then
		return (endTime/1000)-time, name
	end
	local name, _,_,_,_, endTime = UnitChannelInfo("player")
	if endTime then
		return (endTime/1000)-time, name
	end
	return 0
end

function NeP.Parser.Target(eval)
	if eval.func then
		eval.target = eval.func()
	end
	if UnitExists(eval.target) and UnitIsVisible(eval.target) then
		return true
	end
end

function NeP.Parser.Spell(eval)
	if eval[1].token then
		return NeP.Actions[eval[1].token](eval)
	end
	local skillType = GetSpellBookItemInfo(eval[1].spell)
	local isUsable, notEnoughMana = IsUsableSpell(eval[1].spell)
	if skillType ~= 'FUTURESPELL' and isUsable and not notEnoughMana then
		local GCD = NeP.DSL:Get('gcd')()
		if GetSpellCooldown(eval[1].spell) <= GCD then
			eval.func = eval[3].ground and NeP.Protected.CastGround or NeP.Protected.Cast
			return true
		end
	end
end

function NeP.Parser.Table(spell, cond)
	if NeP.DSL.Parse(cond) then
		for i=1, #spell do
			local r = NeP.Parser.Parse(spell[i])
			if r then return true end
		end
	end
end

function NeP.Parser.Parse(eval)
	local spell, cond, target = eval[1], eval[2], eval[3]
	local endtime, cname = castingTime()
	if not spell.spell then
		NeP.Parser.Table(spell, cond)
	elseif spell.bypass or endtime == 0 then
		--print('start', spell.spell)
		if NeP.Parser.Target(target) then
			if spell.token == 'func' or NeP.Parser.Spell(eval) then
				if NeP.DSL.Parse(cond, spell.spell) then
					--print('final', spell.spell)
					if eval.breaks then
						return true
					end
					if spell.interrupts then
						if cname == spell.spell and (endtime > 0 and endtime < 1) then
							return true
						end
						print(cname, spell.spell)
						SpellStopCasting()
					end
					eval.func(spell.spell, target.target)
					NeP.ActionLog:Add('Parser', spell.spell, spell.icon, target.target)
					NeP.Interface:UpdateIcon('mastertoggle', spell.icon)
					return true
				end
			end
		end
	end
end

C_Timer.NewTicker(0.1, (function()
	NeP.Faceroll:Hide()
	if NeP.DSL:Get('toggle')(nil, 'mastertoggle') then
		if not UnitIsDeadOrGhost('player') and IsMountedCheck() then
			local table = NeP.CR.CR[InCombatLockdown()]
			for i=1, #table do
				--print('--------------------- ', i)
				if NeP.Parser.Parse(table[i]) then break end
			end
		end
	end
end), nil)