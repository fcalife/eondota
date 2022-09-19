item_knight_book = class({})

function item_knight_book:OnSpellStart(keys)
	if IsClient() then return end

	local caster = self:GetCaster()
	local team = caster:GetTeam()
	local player_id = caster:GetPlayerID() or nil
	local origin = caster:GetAbsOrigin()

	caster:EmitSound("DOTA_Item.Necronomicon.Activate")
	
	local blue_knight = CreateUnitByName("npc_eon_knight_ally", origin + RandomVector(250), true, caster, caster, team)
	blue_knight:SetControllableByPlayer(player_id, false)
	blue_knight:AddAbility("knight_sacrifice"):SetLevel(1)
	blue_knight:AddNewModifier(caster, nil, "modifier_knight_state_blue", {})
	blue_knight:AddNewModifier(caster, nil, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})

	local red_knight = CreateUnitByName("npc_eon_knight_ally", origin + RandomVector(250), true, caster, caster, team)
	red_knight:SetControllableByPlayer(player_id, false)
	red_knight:AddAbility("knight_storm_bolt"):SetLevel(1)
	red_knight:AddNewModifier(caster, nil, "modifier_knight_state_red", {})
	red_knight:AddNewModifier(caster, nil, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})

	local green_knight = CreateUnitByName("npc_eon_knight_ally", origin + RandomVector(250), true, caster, caster, team)
	green_knight:SetControllableByPlayer(player_id, false)
	green_knight:AddAbility("knight_spear"):SetLevel(1)
	green_knight:AddNewModifier(caster, nil, "modifier_knight_state_green", {})
	green_knight:AddNewModifier(caster, nil, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})

	ResolveNPCPositions(origin, 350)

	GlobalMessages:NotifyKnights(team)

	self:SpendCharge()
end