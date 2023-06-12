_G.Hazards = Hazards or {}

PORTAL_PAIR_VERTICAL = 1
PORTAL_PAIR_HORIZONTAL = 2

PORTAL_MIN_INTERVAL = 15
PORTAL_RANDOM = 15

PLANT_ROOT = 1
PLANT_DAMAGE = 2

PLANT_MIN_INTERVAL = 5
PLANT_RANDOM = 7

TESLA_MIN_INTERVAL = 3
TESLA_RANDOM = 3

function Hazards:Init()
	self.tesla_coils = {}

	for _, location in pairs(GameManager:GetAllMapLocations("tesla_coil")) do
		table.insert(self.tesla_coils, TeslaCoil(location))
	end

	self.tesla_pairs = {
		{1, 2},
		{1, 3},
		{1, 4},
		{2, 3},
		{2, 4},
		{3, 4},
	}
end

function Hazards:Reset()
	if self.tesla_coil_timer then Timers:RemoveTimer(self.tesla_coil_timer) end
	if self.portal_timer then Timers:RemoveTimer(self.portal_timer) end

	self:DestroyPortal()
	self:StopPlants()
end





function Hazards:StartTeslaCoils()
	self.next_tesla_activation = GameRules:GetGameTime() + TESLA_MIN_INTERVAL + RandomInt(0, TESLA_RANDOM)

	self.tesla_coil_timer = Timers:CreateTimer(1, function()
		return Hazards:TeslaThink()
	end)
end

function Hazards:TeslaThink()
	if (not BossManager:IsBossBusy()) then
		local current_time = GameRules:GetGameTime()

		if current_time >= self.next_tesla_activation then
			local boss_health = BossManager.boss:GetHealth()
			local pair_count = (boss_health < 10000 and 4) or (boss_health < 18000 and 3) or (boss_health < 25000 and 2) or 1

			local random_pairs = table.shuffle(self.tesla_pairs)
			local tesla_pairs = {}

			for i = 1, pair_count do table.insert(tesla_pairs, table.remove(random_pairs)) end

			self:TriggerTesla(tesla_pairs)

			self.next_tesla_activation = current_time + TESLA_MIN_INTERVAL + RandomInt(0, TESLA_RANDOM)
		end
	end

	if GameManager:GetGamePhase() == GAME_STATE_BATTLE then return 1 end
end

function Hazards:TriggerTesla(tesla_pairs)
	local boss = BossManager.boss

	local sound_locations = {}

	for _, tesla_pair in pairs(tesla_pairs) do
		if (not sound_locations[tesla_pair[1]]) then sound_locations[tesla_pair[1]] = true end
		if (not sound_locations[tesla_pair[2]]) then sound_locations[tesla_pair[2]] = true end
	end

	for coil_index, coil in pairs(self.tesla_coils) do
		if sound_locations[coil_index] then coil.unit:EmitSound("Tesla.Warn") end
	end

	for _, tesla_pair in pairs(tesla_pairs) do
		local tell_pfx = ParticleManager:CreateParticle("particles/boss/tesla_tell.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(tell_pfx, 0, self.tesla_coils[tesla_pair[1]].coil_loc)
		ParticleManager:SetParticleControl(tell_pfx, 1, self.tesla_coils[tesla_pair[2]].coil_loc)
		ParticleManager:ReleaseParticleIndex(tell_pfx)
	end

	Timers:CreateTimer(0.1 * RandomInt(3, 8), function()
		for coil_index, coil in pairs(self.tesla_coils) do
			if sound_locations[coil_index] then coil.unit:EmitSound("Tesla.Warn") end
		end

		for _, tesla_pair in pairs(tesla_pairs) do
			local tell_pfx = ParticleManager:CreateParticle("particles/boss/tesla_tell.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(tell_pfx, 0, self.tesla_coils[tesla_pair[1]].coil_loc)
			ParticleManager:SetParticleControl(tell_pfx, 1, self.tesla_coils[tesla_pair[2]].coil_loc)
			ParticleManager:ReleaseParticleIndex(tell_pfx)
		end
	end)

	Timers:CreateTimer(1.7, function()
		local targets = {}

		for coil_index, coil in pairs(self.tesla_coils) do
			if sound_locations[coil_index] then coil.unit:EmitSound("Tesla.Hit") end
		end

		for _, tesla_pair in pairs(tesla_pairs) do
			local cast_pfx = ParticleManager:CreateParticle("particles/boss/tesla_cast_01.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(cast_pfx, 0, self.tesla_coils[tesla_pair[1]].coil_loc)
			ParticleManager:SetParticleControl(cast_pfx, 1, self.tesla_coils[tesla_pair[2]].coil_loc)
			ParticleManager:ReleaseParticleIndex(cast_pfx)

			local cast_pfx_b = ParticleManager:CreateParticle("particles/boss/tesla_cast_02.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(cast_pfx_b, 0, self.tesla_coils[tesla_pair[1]].coil_loc)
			ParticleManager:SetParticleControl(cast_pfx_b, 1, self.tesla_coils[tesla_pair[2]].coil_loc)
			ParticleManager:ReleaseParticleIndex(cast_pfx_b)

			local enemies = FindUnitsInLine(
				DOTA_TEAM_BADGUYS,
				self.tesla_coils[tesla_pair[1]].coil_loc,
				self.tesla_coils[tesla_pair[2]].coil_loc,
				nil,
				280,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_NONE
			)

			for _, enemy in pairs(enemies) do
				if (not enemy:HasModifier("modifier_tesla_coil_hit")) and (not enemy:HasModifier("modifier_final_stone")) then

					ApplyDamage({attacker = boss, victim = enemy, damage = 150, damage_type = DAMAGE_TYPE_MAGICAL})

					enemy:AddNewModifier(boss, nil, "modifier_stunned", {duration = 0.35})
					enemy:AddNewModifier(boss, nil, "modifier_tesla_coil_hit", {duration = 0.01})

					local enemy_loc = enemy:GetAbsOrigin()

					local hit_pfx = ParticleManager:CreateParticle("particles/boss/tesla_hit.vpcf", PATTACH_CUSTOMORIGIN, nil)
					ParticleManager:SetParticleControl(hit_pfx, 0, enemy_loc + Vector(0, 0, 700))
					ParticleManager:SetParticleControl(hit_pfx, 2, enemy_loc)
					ParticleManager:SetParticleControl(hit_pfx, 7, Vector(275, 0, 0))
					ParticleManager:ReleaseParticleIndex(hit_pfx)
				end
			end
		end
	end)
end



if TeslaCoil == nil then TeslaCoil = class({}) end

function TeslaCoil:constructor(position)
	self.position = position
	self.coil_loc = self.position + Vector(0, 0, 260)

	self.unit = CreateUnitByName("npc_tesla_coil", self.position, false, nil, nil, DOTA_TEAM_NEUTRALS)
	self.unit:AddNewModifier(self.unit, nil, "modifier_tesla_coil", {})
end



LinkLuaModifier("modifier_tesla_coil", "core/hazards", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tesla_coil_hit", "core/hazards", LUA_MODIFIER_MOTION_NONE)

modifier_tesla_coil_hit = class({})

function modifier_tesla_coil_hit:IsHidden() return true end
function modifier_tesla_coil_hit:IsDebuff() return false end
function modifier_tesla_coil_hit:IsPurgable() return false end

modifier_tesla_coil = class({})

function modifier_tesla_coil:IsHidden() return true end
function modifier_tesla_coil:IsDebuff() return false end
function modifier_tesla_coil:IsPurgable() return false end

function modifier_tesla_coil:GetEffectName()
	return "particles/boss/boss_tesla_ambient_effect.vpcf"
end

function modifier_tesla_coil:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_tesla_coil:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
	}
end

function modifier_tesla_coil:DeclareFunctions()
	return { MODIFIER_PROPERTY_OVERRIDE_ANIMATION }
end

function modifier_tesla_coil:GetOverrideAnimation() return ACT_DOTA_IDLE end





function Hazards:StartPortals()
	self:RollNextPortalSpawn()

	self.portal_timer = Timers:CreateTimer(1, function()
		return Hazards:PortalThink()
	end)
end

function Hazards:PortalThink()
	if (not BossManager:IsBossBusy()) then
		local current_time = GameRules:GetGameTime()

		if current_time >= self.next_portal_spawn then
			self:SpawnPortalPair()
			self.next_portal_spawn = current_time + 9999
		end
	end

	if GameManager:GetGamePhase() == GAME_STATE_BATTLE then return 1 end
end

function Hazards:SpawnPortalPair()
	local orientation = (RollPercentage(50) and PORTAL_PAIR_VERTICAL) or PORTAL_PAIR_HORIZONTAL

	local location_a = BossManager:GetCurrentMapCenter()
	local location_b = BossManager:GetCurrentMapCenter()

	if orientation == PORTAL_PAIR_VERTICAL then
		local x_offset = ((RollPercentage(50) and -1) or 1) * RandomInt(0, 850)

		location_a = location_a + Vector(x_offset, 1080, 256)
		location_b = location_b + Vector((-1) * x_offset, -1536, 256)
	elseif orientation == PORTAL_PAIR_HORIZONTAL then
		local y_offset = ((RollPercentage(50) and -1) or 1) * RandomInt(0, 672) - 224

		location_a = location_a + Vector(1600, y_offset, 128)
		location_b = location_b + Vector(-1600, (-1) * y_offset, 128)
	end

	self.current_portal = PortalPair(location_a, location_b)
end

function Hazards:DestroyPortal()
	if self.current_portal then self.current_portal:Destroy() end
end

function Hazards:RollNextPortalSpawn()
	self.next_portal_spawn = GameRules:GetGameTime() + PORTAL_MIN_INTERVAL + RandomInt(0, PORTAL_RANDOM)
end





function Hazards:StartPlants()
	self.next_plant_spawn = GameRules:GetGameTime() + PLANT_MIN_INTERVAL + RandomInt(0, PLANT_RANDOM)

	self.plant_timer = Timers:CreateTimer(1, function()
		return Hazards:PlantThink()
	end)
end

function Hazards:PlantThink()
	if (not BossManager:IsBossBusy()) then
		local current_time = GameRules:GetGameTime()

		if current_time >= self.next_plant_spawn then
			self:SpawnPlant()

			self.next_plant_spawn = current_time + PLANT_MIN_INTERVAL + RandomInt(0, PLANT_RANDOM)
		end
	end

	if GameManager:GetGamePhase() == GAME_STATE_BATTLE then return 1 end
end

function Hazards:SpawnPlant()
	local plant_name = (RollPercentage(50) and "npc_plant_rooter") or "npc_plant_lasher"

	local all_heroes = HeroList:GetAllHeroes()

	if #all_heroes < 1 then return end

	local target = all_heroes[RandomInt(1, #all_heroes)]:GetAbsOrigin()

	local position = target + RandomVector(RandomInt(300, 900))

	while (not GridNav:IsTraversable(position)) do
		position = target + RandomVector(RandomInt(300, 900))
	end

	local plant = CreateUnitByName(plant_name, position, false, nil, nil, DOTA_TEAM_BADGUYS)

	FindClearSpaceForUnit(plant, position, true)

	plant:EmitSound("Plant.Spawn")
end

function Hazards:StopPlants()
	if self.plant_timer then Timers:RemoveTimer(self.plant_timer) end

	self:DestroyPlants()
end

function Hazards:DestroyPlants()
	local rooters = Entities:FindAllByModel("models/items/furion/treant/primeval_treant/primeval_treant.vmdl")
	local lashers = Entities:FindAllByModel("models/items/furion/treant/supreme_gardener_treants/supreme_gardener_treants.vmdl")

	for _, plant in pairs(rooters) do plant:Destroy() end
	for _, plant in pairs(lashers) do plant:Destroy() end
end



LinkLuaModifier("modifier_root_trap_plant", "core/hazards", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_root_trap_plant_grow_up", "core/hazards", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_root_trap_debuff", "core/hazards", LUA_MODIFIER_MOTION_NONE)

plant_root_trap = class({})

function plant_root_trap:GetIntrinsicModifierName()
	return "modifier_root_trap_plant"
end



modifier_root_trap_plant = class({})

function modifier_root_trap_plant:IsHidden() return true end
function modifier_root_trap_plant:IsDebuff() return false end
function modifier_root_trap_plant:IsPurgable() return false end

function modifier_root_trap_plant:OnCreated(keys)
	if IsClient() then return end

	local ability = self:GetAbility()

	self.radius = ability:GetSpecialValueFor("radius")
	self.duration = ability:GetSpecialValueFor("root_duration")
	self.health = ability:GetSpecialValueFor("health")

	self:StartIntervalThink(0.03)
end

function modifier_root_trap_plant:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true
	}
end

function modifier_root_trap_plant:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
			MODIFIER_PROPERTY_HEALTHBAR_PIPS,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			MODIFIER_EVENT_ON_TAKEDAMAGE
		}
	else
		return {
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
			MODIFIER_PROPERTY_HEALTHBAR_PIPS,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION
		}
	end
end

function modifier_root_trap_plant:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_root_trap_plant:GetAbsoluteNoDamageMagical() return 1 end
function modifier_root_trap_plant:GetAbsoluteNoDamagePure() return 1 end
function modifier_root_trap_plant:GetModifierHealthBarPips() return self:GetAbility():GetSpecialValueFor("health") end
function modifier_root_trap_plant:GetOverrideAnimation() return ACT_DOTA_IDLE end

function modifier_root_trap_plant:OnTakeDamage(keys)
	if keys.unit == self:GetParent() then
		if keys.unit:GetHealth() > 1 then
			keys.unit:SetHealth(keys.unit:GetHealth() - 1)
		else
			keys.unit:Destroy()
		end
	end
end

function modifier_root_trap_plant:OnIntervalThink()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if parent:HasModifier("modifier_root_trap_plant_grow_up") then
		if ability:IsCooldownReady() then
			local enemies = FindUnitsInRadius(
				parent:GetTeam(),
				parent:GetAbsOrigin(),
				nil,
				self.radius,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_NONE,
				FIND_ANY_ORDER,
				false
			)

			if #enemies > 0 then
				parent:EmitSound("Plant.Root")

				for _, enemy in pairs(enemies) do
					enemy:AddNewModifier(parent, ability, "modifier_root_trap_debuff", {duration = self.duration})
				end

				ability:UseResources(true, true, true, true)
			end
		end
	else
		local allies = FindUnitsInRadius(
			parent:GetTeam(),
			parent:GetAbsOrigin(),
			nil,
			self.radius,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false
		)

		for _, ally in pairs(allies) do
			if ally:IsChronophage() then
				parent:AddNewModifier(parent, ability, "modifier_root_trap_plant_grow_up", {})
				parent:EmitSound("Plant.Grow")
			end
		end
	end
end



modifier_root_trap_debuff = class({})

function modifier_root_trap_debuff:IsHidden() return false end
function modifier_root_trap_debuff:IsDebuff() return true end
function modifier_root_trap_debuff:IsPurgable() return true end

function modifier_root_trap_debuff:OnCreated(keys)
	if IsClient() then return end

	self.root_pfx = ParticleManager:CreateParticle("particles/boss/boss_plant_root.vpcf", PATTACH_ABSORIGIN, self:GetParent())
end

function modifier_root_trap_debuff:OnDestroy()
	if IsClient() then return end

	if self.root_pfx then
		ParticleManager:DestroyParticle(self.root_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.root_pfx)
	end
end

function modifier_root_trap_debuff:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true
	}
end



modifier_root_trap_plant_grow_up = class({})

function modifier_root_trap_plant_grow_up:IsHidden() return true end
function modifier_root_trap_plant_grow_up:IsDebuff() return true end
function modifier_root_trap_plant_grow_up:IsPurgable() return true end

function modifier_root_trap_plant_grow_up:OnCreated(keys)
	if IsClient() then return end

	self.ring_pfx = ParticleManager:CreateParticle("particles/boss/boss_plant_grown_up.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.ring_pfx, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.ring_pfx, 1, Vector(450, 0, 0))
end

function modifier_root_trap_plant_grow_up:OnDestroy()
	if IsClient() then return end

	if self.ring_pfx then
		ParticleManager:DestroyParticle(self.ring_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.ring_pfx)
	end
end

function modifier_root_trap_plant_grow_up:DeclareFunctions()
	return { MODIFIER_PROPERTY_MODEL_SCALE }
end

function modifier_root_trap_plant_grow_up:GetModifierModelScale()
	return 90
end



LinkLuaModifier("modifier_lashing_trap_plant", "core/hazards", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lashing_trap_plant_grow_up", "core/hazards", LUA_MODIFIER_MOTION_NONE)

plant_lashing_trap = class({})

function plant_lashing_trap:GetIntrinsicModifierName()
	return "modifier_lashing_trap_plant"
end



modifier_lashing_trap_plant = class({})

function modifier_lashing_trap_plant:IsHidden() return true end
function modifier_lashing_trap_plant:IsDebuff() return false end
function modifier_lashing_trap_plant:IsPurgable() return false end

function modifier_lashing_trap_plant:OnCreated(keys)
	if IsClient() then return end

	local ability = self:GetAbility()

	self.radius = ability:GetSpecialValueFor("radius")
	self.damage = ability:GetSpecialValueFor("damage")
	self.health = ability:GetSpecialValueFor("health")

	self:StartIntervalThink(0.03)
end

function modifier_lashing_trap_plant:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true
	}
end

function modifier_lashing_trap_plant:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
			MODIFIER_PROPERTY_HEALTHBAR_PIPS,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			MODIFIER_EVENT_ON_TAKEDAMAGE
		}
	else
		return {
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
			MODIFIER_PROPERTY_HEALTHBAR_PIPS,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION
		}
	end
end

function modifier_lashing_trap_plant:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_lashing_trap_plant:GetAbsoluteNoDamageMagical() return 1 end
function modifier_lashing_trap_plant:GetAbsoluteNoDamagePure() return 1 end
function modifier_lashing_trap_plant:GetModifierHealthBarPips() return self:GetAbility():GetSpecialValueFor("health") end
function modifier_lashing_trap_plant:GetOverrideAnimation() return ACT_DOTA_IDLE end

function modifier_lashing_trap_plant:OnTakeDamage(keys)
	if keys.unit == self:GetParent() then
		if keys.unit:GetHealth() > 1 then
			keys.unit:SetHealth(keys.unit:GetHealth() - 1)
		else
			keys.unit:Destroy()
		end
	end
end

function modifier_lashing_trap_plant:OnIntervalThink()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if parent:HasModifier("modifier_lashing_trap_plant_grow_up") then
		if ability:IsCooldownReady() then
			local enemies = FindUnitsInRadius(
				parent:GetTeam(),
				parent:GetAbsOrigin(),
				nil,
				self.radius,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_NONE,
				FIND_ANY_ORDER,
				false
			)

			if enemies[1] then
				local lash_pfx = ParticleManager:CreateParticle("particles/boss/boss_plant_lash.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(lash_pfx, 0, parent:GetAbsOrigin())
				ParticleManager:SetParticleControl(lash_pfx, 1, enemies[1]:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(lash_pfx)

				ability:UseResources(true, true, true, true)

				Timers:CreateTimer(0.3, function()
					ApplyDamage({attacker = parent, victim = enemies[1], damage = self.damage, damage_type = DAMAGE_TYPE_PHYSICAL})

					enemies[1]:EmitSound("Lash.Hit")

					if enemies[1]:TriggerCounter(parent) then ApplyDamage({attacker = parent, victim = parent, damage = self.damage, damage_type = DAMAGE_TYPE_PHYSICAL}) end
				end)
			end
		end
	else
		local allies = FindUnitsInRadius(
			parent:GetTeam(),
			parent:GetAbsOrigin(),
			nil,
			self.radius,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false
		)

		for _, ally in pairs(allies) do
			if ally:IsChronophage() then
				parent:AddNewModifier(parent, ability, "modifier_lashing_trap_plant_grow_up", {})
				parent:EmitSound("Plant.Grow")
			end
		end
	end
end



modifier_lashing_trap_plant_grow_up = class({})

function modifier_lashing_trap_plant_grow_up:IsHidden() return true end
function modifier_lashing_trap_plant_grow_up:IsDebuff() return true end
function modifier_lashing_trap_plant_grow_up:IsPurgable() return true end

function modifier_lashing_trap_plant_grow_up:OnCreated(keys)
	if IsClient() then return end

	self.ring_pfx = ParticleManager:CreateParticle("particles/boss/boss_plant_grown_up.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.ring_pfx, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.ring_pfx, 1, Vector(450, 0, 0))
end

function modifier_lashing_trap_plant_grow_up:OnDestroy()
	if IsClient() then return end

	if self.ring_pfx then
		ParticleManager:DestroyParticle(self.ring_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.ring_pfx)
	end
end

function modifier_lashing_trap_plant_grow_up:DeclareFunctions()
	return { MODIFIER_PROPERTY_MODEL_SCALE }
end

function modifier_lashing_trap_plant_grow_up:GetModifierModelScale()
	return 90
end