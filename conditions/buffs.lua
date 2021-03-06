local _, NeP       = ...
local UnitBuff     = UnitBuff
local UnitDebuff   = UnitDebuff
local GetTime      = GetTime

local function UnitBuffL(target, spell, own)
  local name,_,_,count,_,_,expires,caster = UnitBuff(target, spell, nil, own)
  return name, count, expires, caster
end

local function UnitDebuffL(target, spell, own)
  local name, _,_, count, _,_, expires, caster = UnitDebuff(target, spell, nil, own)
  return name, count, expires, caster
end

local heroismBuffs = { 32182, 90355, 80353, 2825, 146555 }
NeP.DSL:Register("hashero", function()
  for i = 1, #heroismBuffs do
    local SpellName = NeP.Core:GetSpellName(heroismBuffs[i])
    if UnitBuffL('player', SpellName) then return true end
  end
end)

------------------------------------------ BUFFS -----------------------------------------
------------------------------------------------------------------------------------------
NeP.DSL:Register("buff", function(target, spell)
  return UnitBuffL(target, spell, 'PLAYER')
end)

NeP.DSL:Register("buff.any", function(target, spell)
  return UnitBuffL(target, spell)
end)

NeP.DSL:Register("buff.count", function(target, spell)
  local buff, count = UnitBuffL(target, spell, 'PLAYER')
  return buff and count or 0
end)

NeP.DSL:Register("buff.duration", function(target, spell)
  local buff,_,expires = UnitBuffL(target, spell, 'PLAYER')
  return buff and (expires - GetTime()) or 0
end)

------------------------------------------ DEBUFFS ---------------------------------------
------------------------------------------------------------------------------------------

NeP.DSL:Register("debuff", function(target, spell)
  return  UnitDebuffL(target, spell, 'PLAYER')
end)

NeP.DSL:Register("debuff.any", function(target, spell)
  return UnitDebuffL(target, spell)
end)

NeP.DSL:Register("debuff.count", function(target, spell)
  local debuff,count = UnitDebuffL(target, spell, 'PLAYER')
  return debuff and count or 0
end)

NeP.DSL:Register("debuff.duration", function(target, spell)
  local debuff,_,expires = UnitDebuffL(target, spell)
  return debuff and (expires - GetTime()) or 0
end)
