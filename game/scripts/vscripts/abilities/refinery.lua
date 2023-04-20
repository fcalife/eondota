refinery_spawn_harvester = class({})

LinkLuaModifier("modifier_refinery_spawn_harvester", "abilities/refinery", LUA_MODIFIER_MOTION_NONE)

function refinery_spawn_harvester:GetIntrinsicModifierName()
	return "modifier_refinery_spawn_harvester"
end

function refinery_spawn_harvester:OnChannelFinish(interrupted)
	if interrupted then return end

	local caster = self:GetCaster()

	if caster.refinery then caster.refinery:SpawnHarvester() end
end



modifier_refinery_spawn_harvester = class({})

function modifier_refinery_spawn_harvester:IsHidden() return true end
function modifier_refinery_spawn_harvester:IsDebuff() return false end
function modifier_refinery_spawn_harvester:IsPurgable() return false end

function modifier_refinery_spawn_harvester:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}
end

function modifier_refinery_spawn_harvester:OnCreated(keys)
	if IsClient() then return end

	self:StartIntervalThink(0.03)
end

function modifier_refinery_spawn_harvester:OnIntervalThink()
	local parent = self:GetParent()
	
	if parent.refinery then
		if parent.refinery:ShouldBeSpawningHarvesters() then
			if GameManager:GetGamePhase() == GAME_STATE_BATTLE then
				if (not parent:IsChanneling()) then
					ExecuteOrderFromTable({
						unitIndex = parent:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = self:GetAbility():entindex(),
						Queue = false
					})
				end
			end
		else
			if parent:IsChanneling() then parent:Stop() end
		end
	end
end



harvester_harvest = class({})

LinkLuaModifier("modifier_harvester_harvest", "abilities/refinery", LUA_MODIFIER_MOTION_NONE)

function harvester_harvest:GetIntrinsicModifierName()
	return "modifier_harvester_harvest"
end



modifier_harvester_harvest = class({})

function modifier_harvester_harvest:IsHidden() return true end
function modifier_harvester_harvest:IsDebuff() return false end
function modifier_harvester_harvest:IsPurgable() return false end

function modifier_harvester_harvest:OnCreated(keys)
	if IsClient() then return end

	self:StartIntervalThink(0.2)
end

function modifier_harvester_harvest:OnIntervalThink()
	local parent = self:GetParent()

	local unit_id = parent:entindex()
	local target_id = Minerals:GetMineralPatch(parent:GetTeam()).unit:entindex()

	ExecuteOrderFromTable({
		unitIndex = unit_id,
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target_id,
		Queue = false
	})
end

function modifier_harvester_harvest:DeclareFunctions()
	if IsServer() then return { MODIFIER_PROPERTY_PROCATTACK_FEEDBACK } end
end

function modifier_harvester_harvest:GetModifierProcAttack_Feedback(keys)
	if keys.target and keys.target.is_minerals then
		keys.target:EmitSound("Harvester.Hit")

		local hit_pfx = ParticleManager:CreateParticle("particles/rts/mineral_attack_impact.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(hit_pfx, 0, keys.target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(hit_pfx)

		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, keys.attacker, 1, nil)

		EonSpheres:GiveTeamSpheres(keys.attacker:GetTeam(), EON_SPHERES_PER_HIT)
	end
end