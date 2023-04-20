_G.PushCarts = PushCarts or {}

CART_TIME_FROM_CENTER = 20
CART_CAPTURE_RADIUS = 400

function PushCarts:StartCountdown()
	GlobalMessages:Send("The push carts will arrive in "..CART_COUNTDOWN_TIME.." seconds!")

	EmitGlobalSound("cart.warning")

	Timers:CreateTimer(CART_COUNTDOWN_TIME, function()
		GlobalMessages:Send("The push carts have arrived!")

		EmitGlobalSound("cart.spawn")

		self:Spawn()
	end)
end

function PushCarts:Spawn()
	PushCart(
		Entities:FindByName(nil, "radiant_cart_point_a"):GetAbsOrigin(),
		Entities:FindByName(nil, "dire_cart_point_a"):GetAbsOrigin()
	)

	PushCart(
		Entities:FindByName(nil, "radiant_cart_point_b"):GetAbsOrigin(),
		Entities:FindByName(nil, "dire_cart_point_b"):GetAbsOrigin()
	)
end



if PushCart == nil then PushCart = class({}) end

function PushCart:constructor(radiant_end, dire_end)
	self.progress = 0
	self.radiant_end = radiant_end
	self.dire_end = dire_end

	self.center = 0.5 * (radiant_end + dire_end)
	self.direction = (dire_end - radiant_end):Normalized()
	self.length = (dire_end - radiant_end):Length2D()
	self.progress_tick = 0.03 / CART_TIME_FROM_CENTER

	self.cart_unit = CreateUnitByName("npc_eon_cart", self.center, false, nil, nil, DOTA_TEAM_NEUTRALS)
	local cart_modifier = self.cart_unit:AddNewModifier(self.cart_unit, nil, "modifier_cart_state", {})
	cart_modifier:SetStackCount(100 * 0.5 * self.length / CART_TIME_FROM_CENTER)

	self.radiant_altar = CreateUnitByName("npc_cart_objective_radiant", self.radiant_end, true, nil, nil, DOTA_TEAM_GOODGUYS)
	self.dire_altar = CreateUnitByName("npc_cart_objective_dire", self.dire_end, true, nil, nil, DOTA_TEAM_BADGUYS)
	self.radiant_altar:AddNewModifier(self.radiant_altar, nil, "modifier_cart_objective_state", {})
	self.dire_altar:AddNewModifier(self.dire_altar, nil, "modifier_cart_objective_state", {})

	AddFOWViewer(DOTA_TEAM_GOODGUYS, self.center, CART_CAPTURE_RADIUS + 200, 1, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, self.center, CART_CAPTURE_RADIUS + 200, 1, false)

	self.radiant_tether_pfx = ParticleManager:CreateParticle("particles/carts/cart_tether.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.cart_unit)
	ParticleManager:SetParticleControl(self.radiant_tether_pfx, 1, self.radiant_end + Vector(0, 0, 0))

	self.dire_tether_pfx = ParticleManager:CreateParticle("particles/carts/cart_tether.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.cart_unit)
	ParticleManager:SetParticleControl(self.dire_tether_pfx, 1, self.dire_end + Vector(0, 0, 0))

	self.capture_ring_pfx = ParticleManager:CreateParticle("particles/carts/cart_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.cart_unit)
	ParticleManager:SetParticleControl(self.capture_ring_pfx, 1, Vector(CART_CAPTURE_RADIUS, 0, 0))

	self.trigger = MapTrigger(self.center, TRIGGER_TYPE_CIRCLE, {
		radius = CART_CAPTURE_RADIUS
	}, {
		trigger_team = DOTA_TEAM_NEUTRALS,
		team_filter = DOTA_UNIT_TARGET_TEAM_BOTH,
		unit_filter = DOTA_UNIT_TARGET_HERO,
		flag_filter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
	}, function(units)
		self:OnUnitsInRange(units)
	end, {
		tick_when_empty = true,
	})
end

function PushCart:UpdatePositionFromProgress()
	local new_position = self.center + 0.5 * self.progress * self.direction * self.length

	self.cart_unit:MoveToPosition(new_position)

	if self.trigger then self.trigger.center = new_position end

	AddFOWViewer(DOTA_TEAM_GOODGUYS, new_position, CART_CAPTURE_RADIUS + 200, 1, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, new_position, CART_CAPTURE_RADIUS + 200, 1, false)
end

function PushCart:OnUnitsInRange(units)
	local radiant_present = false
	local dire_present = false

	for _, unit in pairs(units) do
		if unit:GetTeam() == DOTA_TEAM_GOODGUYS then radiant_present = true end
		if unit:GetTeam() == DOTA_TEAM_BADGUYS then dire_present = true end
	end

	if radiant_present and (not dire_present) then self.progress = math.min(1, self.progress + self.progress_tick) end
	if dire_present and (not radiant_present) then self.progress = math.max(-1, self.progress - self.progress_tick) end

	self:UpdatePositionFromProgress()

	if self.progress >= 1 then self:OnTeamWinCart(DOTA_TEAM_GOODGUYS) end
	if self.progress <= -1 then self:OnTeamWinCart(DOTA_TEAM_BADGUYS) end
end

function PushCart:OnTeamWinCart(team)
	local current_position = self.center + 0.5 * self.progress * self.direction * self.length

	local shockwave_pfx = ParticleManager:CreateParticle("particles/control_zone/capture_point_shockwave.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(shockwave_pfx, 0, current_position)
	ParticleManager:SetParticleControl(shockwave_pfx, 1, SHRINE_TEAM_COLOR[team])
	ParticleManager:ReleaseParticleIndex(shockwave_pfx)

	if self.cart_unit then self.cart_unit:Destroy() end

	if self.radiant_tether_pfx then
		ParticleManager:DestroyParticle(self.radiant_tether_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.radiant_tether_pfx)
	end

	if self.dire_tether_pfx then
		ParticleManager:DestroyParticle(self.dire_tether_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.dire_tether_pfx)
	end

	if self.capture_ring_pfx then
		ParticleManager:DestroyParticle(self.capture_ring_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.capture_ring_pfx)
	end

	if team == DOTA_TEAM_GOODGUYS then
		CartObjective(self.radiant_end, team)
		self.dire_altar:Destroy()
	elseif team == DOTA_TEAM_BADGUYS then
		CartObjective(self.dire_end, team)
		self.radiant_altar:Destroy()
	end

	GlobalMessages:NotifyTeamReachedCartGoal(team)

	self.trigger:Stop()
end