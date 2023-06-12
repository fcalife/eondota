_G.StoneManager = StoneManager or {}

STONE_SPEED = 0
STONE_SHIELD = 1
STONE_REGEN = 2
STONE_NUKE = 3
STONE_ULTIMATE = 4

STONE_SYMBOL = {}
STONE_SYMBOL[STONE_SPEED] = 3
STONE_SYMBOL[STONE_SHIELD] = 0
STONE_SYMBOL[STONE_REGEN] = 4
STONE_SYMBOL[STONE_NUKE] = 1
STONE_SYMBOL[STONE_ULTIMATE] = 2

STONE_MESSAGE = {}
STONE_MESSAGE[STONE_SPEED] = "Delivered Wind Stone! Movement speed increased."
STONE_MESSAGE[STONE_SHIELD] = "Delivered Earth Stone! Damage shield unlocked."
STONE_MESSAGE[STONE_REGEN] = "Delivered Nature Stone! Health regeneration increased."
STONE_MESSAGE[STONE_NUKE] = "Delivered Fire Stone! Fire Breath unlocked."
STONE_MESSAGE[STONE_ULTIMATE] = "Last stone obtained! ULTIMATE POWER ACHIEVED!"

STONE_MODIFIER = {}
STONE_MODIFIER[STONE_SPEED] = "modifier_powerup_bossfight_movespeed"
STONE_MODIFIER[STONE_SHIELD] = "modifier_powerup_bossfight_shield"
STONE_MODIFIER[STONE_REGEN] = "modifier_powerup_bossfight_regen"
STONE_MODIFIER[STONE_NUKE] = "modifier_powerup_bossfight_nuke_damage"
STONE_MODIFIER[STONE_ULTIMATE] = "modifier_powerup_bossfight_ultimate_power"



function StoneManager:Reset()
	self.eon_drops = 0
	self.eon_activations = 0

	if self.final_stone then
		self.final_stone:RemoveModifierByName("modifier_final_stone")
		self.final_stone:Destroy()
	end

	CustomGameEventManager:Send_ServerToAllClients("reset_eon", {})

	if self.current_delivery_points then
		for _, delivery_point in pairs(self.current_delivery_points) do
			if delivery_point then delivery_point:Clear() end
		end
	end

	local stone_locations = table.shuffle(GameManager:GetAllMapLocations("delivery_point"))
	self.ultimate_stone_location = GameManager:GetMapLocation("last_stone_spawn")

	self.current_delivery_points = {}

	for stone = STONE_SPEED, STONE_NUKE do
		table.insert(self.current_delivery_points, StoneDeliveryPoint(stone, Vector(-8192, 0, 0) + table.remove(stone_locations)))
	end
end

function StoneManager:SpawnMapEonStone()
	local powerup_loc = Vector(1536, 896, 128)

	if RollPercentage(50) then powerup_loc = Vector(-powerup_loc.x, powerup_loc.y, powerup_loc.z) end
	if RollPercentage(50) then powerup_loc = Vector(powerup_loc.x, -powerup_loc.y, powerup_loc.z) end

	local arena_center = BossManager:GetCurrentMapCenter()

	powerup_loc = powerup_loc + arena_center

	self:IncrementEonDropCount()

	PowerupManager:SpawnPowerUp(powerup_loc, powerup_loc, "item_mario_star")

	EmitGlobalSound("ui.npe_objective_complete")

	local indicator_pfx = ParticleManager:CreateParticle("particles/boss/powerup_ping.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(indicator_pfx, 0, powerup_loc - Vector(0, 0, 96))

	Timers:CreateTimer(5.0, function()
		ParticleManager:DestroyParticle(indicator_pfx, false)
		ParticleManager:ReleaseParticleIndex(indicator_pfx)
	end)
end

function StoneManager:MoveAllToNextPhase()
	if self.current_delivery_points then
		for _, delivery_point in pairs(self.current_delivery_points) do
			if delivery_point and delivery_point.active then delivery_point:MoveToNextPhase() end
		end
	end
end

function StoneManager:SpawnFinalStone()
	local target_location = self.ultimate_stone_location + BossManager:GetCurrentMapCenter()

	Timers:CreateTimer(8, function()
		GlobalMessages:Send("The final Eon Stone is about to arrive...")

		Timers:CreateTimer(4, function()
			GlobalMessages:Send("Destroy it to achieve ultimate power!")

			local current_height = 1500

			self.final_stone = CreateUnitByName("npc_last_stone", target_location + Vector(0, 0, current_height), false, nil, nil, DOTA_TEAM_NEUTRALS)
			self.final_stone:AddNewModifier(self.final_stone, nil, "modifier_final_stone", {})
			self.final_stone:AddNoDraw()

			local pre_pfx = ParticleManager:CreateParticle("particles/boss/last_stone_aoe.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(pre_pfx, 0, target_location + Vector(0, 0, 10))
			ParticleManager:SetParticleControl(pre_pfx, 1, target_location + Vector(0, 0, 10))
			ParticleManager:SetParticleControl(pre_pfx, 2, Vector(500, 0, 0))

			EmitSoundOnLocationWithCaster(target_location, "Hero_Dawnbreaker.Solar_Guardian.Channel", self.final_stone)

			Timers:CreateTimer(3.0, function()
				EmitSoundOnLocationWithCaster(target_location, "Hero_Dawnbreaker.Solar_Guardian.BlastOff", self.final_stone)
			end)

			Timers:CreateTimer(3.0, function()
				self.final_stone:RemoveNoDraw()
				current_height = current_height - 150
				self.final_stone:SetAbsOrigin(target_location + Vector(0, 0, current_height))

				if current_height > 0 then
					return 0.03
				else
					FindClearSpaceForUnit(self.final_stone, target_location, true)

					ParticleManager:DestroyParticle(pre_pfx, true)
					ParticleManager:ReleaseParticleIndex(pre_pfx)

					local impact_pfx = ParticleManager:CreateParticle("particles/boss/last_stone_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
					ParticleManager:SetParticleControl(impact_pfx, 0, target_location + Vector(0, 0, 10))
					ParticleManager:SetParticleControl(impact_pfx, 1, target_location + Vector(0, 0, 10))
					ParticleManager:SetParticleControl(impact_pfx, 2, Vector(500, 0, 0))

					self.final_stone:EmitSound("Hero_Dawnbreaker.Solar_Guardian.Impact")
				end
			end)
		end)
	end)
end

function StoneManager:IncrementEonDropCount()
	self.eon_drops = (self.eon_drops or 0) + 1
end

function StoneManager:GetEonDropCount()
	return (self.eon_drops or 0)
end

function StoneManager:ResetEonDropCount()
	self.eon_drops = 0
end

function StoneManager:IncrementActivations()
	self.eon_activations = (self.eon_activations or 0) + 1
end

function StoneManager:GetActivationCount()
	return (self.eon_activations or 0)
end

function StoneManager:ResetActivationCount()
	self.eon_activations = 0
end



if StoneDeliveryPoint == nil then StoneDeliveryPoint = class({}) end

function StoneDeliveryPoint:constructor(stone, position)
	self.stone = stone
	self.position = position
	self.active = true

	self.delivery_pfx = ParticleManager:CreateParticle("particles/boss/stone_delivery_sign.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.delivery_pfx, 0, self.position)
	ParticleManager:SetParticleControl(self.delivery_pfx, 3, Vector(STONE_SYMBOL[self.stone], 0, 0))

	self.trigger = MapTrigger(self.position, TRIGGER_TYPE_CIRCLE, {
		radius = 190
	}, {
		trigger_team = DOTA_TEAM_BADGUYS,
		team_filter = DOTA_UNIT_TARGET_TEAM_ENEMY,
		unit_filter = DOTA_UNIT_TARGET_HERO,
		flag_filter = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		find_order = FIND_CLOSEST,
	}, function(units)
		self:Tick(units)
	end, {
		tick_when_empty = true,
	})

end

function StoneDeliveryPoint:MoveToNextPhase()
	self.position = self.position + Vector(8192, 0, 0)

	ParticleManager:DestroyParticle(self.delivery_pfx, true)
	ParticleManager:ReleaseParticleIndex(self.delivery_pfx)

	self.delivery_pfx = ParticleManager:CreateParticle("particles/boss/stone_delivery_sign.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.delivery_pfx, 0, self.position)
	ParticleManager:SetParticleControl(self.delivery_pfx, 3, Vector(STONE_SYMBOL[self.stone], 0, 0))

	self.trigger:MoveTo(self.position)
end

function StoneDeliveryPoint:Tick(units)
	if units and #units > 0 then
		for _, unit in pairs(units) do
			if unit:HasModifier("modifier_eon_stone_carrier") then
				unit:RemoveModifierByName("modifier_eon_stone_carrier")

				self:Activate()
				break
			end
		end
	end
end

function StoneDeliveryPoint:Activate()
	CustomGameEventManager:Send_ServerToAllClients("got_eon", {})

	GlobalMessages:Send(STONE_MESSAGE[self.stone])

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		hero:AddNewModifier(hero, nil, STONE_MODIFIER[self.stone], {})
		hero:EmitSound("KnockbackArena.Powerup.Star")
	end

	self:Clear()

	StoneManager:IncrementActivations()

	if StoneManager:GetActivationCount() >= 4 then
		StoneManager:SpawnFinalStone()
	end
end

function StoneDeliveryPoint:Clear()
	if self.delivery_pfx then
		ParticleManager:DestroyParticle(self.delivery_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.delivery_pfx)
	end

	if self.trigger then self.trigger:Stop() end

	self.active = false
end





LinkLuaModifier("modifier_eon_stone_carrier", "core/stone_manager", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_final_stone", "core/stone_manager", LUA_MODIFIER_MOTION_NONE)

modifier_eon_stone_carrier = class({})

function modifier_eon_stone_carrier:IsHidden() return true end
function modifier_eon_stone_carrier:IsDebuff() return false end
function modifier_eon_stone_carrier:IsPurgable() return false end
function modifier_eon_stone_carrier:RemoveOnDeath() return false end
function modifier_eon_stone_carrier:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end
function modifier_eon_stone_carrier:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_eon_stone_carrier:GetEffectName()
	return "particles/eon_carrier.vpcf"
end

function modifier_eon_stone_carrier:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end



modifier_final_stone = class({})

function modifier_final_stone:IsHidden() return true end
function modifier_final_stone:IsDebuff() return false end
function modifier_final_stone:IsPurgable() return false end

function modifier_final_stone:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	}
end

function modifier_final_stone:DeclareFunctions()
	if IsServer() then return { MODIFIER_EVENT_ON_DEATH } end
end

function modifier_final_stone:OnDeath(keys)
	if keys.unit == self:GetParent() then
		CustomGameEventManager:Send_ServerToAllClients("got_eon", {})

		GlobalMessages:Send(STONE_MESSAGE[STONE_ULTIMATE])

		for _, hero in pairs(HeroList:GetAllHeroes()) do
			hero:AddNewModifier(hero, nil, STONE_MODIFIER[STONE_ULTIMATE], {})
			hero:EmitSound("KnockbackArena.Powerup.Star")
		end

		local explosion_pfx = ParticleManager:CreateParticle("particles/boss/last_stone_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(explosion_pfx, 0, keys.unit:GetAbsOrigin())
		ParticleManager:SetParticleControl(explosion_pfx, 1, keys.unit:GetAbsOrigin())
		ParticleManager:SetParticleControl(explosion_pfx, 2, Vector(500, 0, 0))
		ParticleManager:ReleaseParticleIndex(explosion_pfx)

		keys.unit:EmitSound("EonStone.Explode")

		StoneManager:IncrementActivations()

		keys.unit:AddNoDraw()
	end
end