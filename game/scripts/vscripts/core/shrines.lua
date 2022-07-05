_G.Shrines = Shrines or {}

SHRINE_UPDATE_RATE = 0.03

SHRINE_STATE_INACTIVE = 0
SHRINE_STATE_CHARGED = 1
SHRINE_STATE_ACTIVE = 2

SHRINE_PROGRESS_TICK = 100 / (SHRINE_CAPTURE_TIME / SHRINE_UPDATE_RATE)

SHRINE_TYPES = {
	SHRINE_ARCANE = {
		tower_particle = "particles/generic_gameplay/rune_arcane_owner.vpcf",
		tower_color = Vector(220, 100, 220),
		active_effect = "",
		active_buff = "modifier_shrine_buff_arcane"
	},
	SHRINE_FRENZY = {
		tower_particle = "particles/dev/rune_test_owner.vpcf",
		tower_color = Vector(220, 220, 100),
		active_effect = "",
		active_buff = "modifier_shrine_buff_frenzy"
	},
	SHRINE_CATASTROPHE = {
		tower_particle = "particles/generic_gameplay/rune_doubledamage_owner.vpcf",
		tower_color = Vector(100, 100, 220),
		active_effect = "",
		active_buff = "modifier_shrine_buff_catastrophe"
	},
	SHRINE_ULTIMATE = {
		tower_particle = "particles/generic_gameplay/rune_regen_owner.vpcf",
		tower_color = Vector(100, 220, 100),
		active_effect = "",
		active_buff = "modifier_shrine_buff_ultimate"
	},
}

SHRINE_BASE_COLOR = Vector(220, 220, 220)
SHRINE_TEAM_COLOR = {
	[DOTA_TEAM_GOODGUYS] = Vector(120, 90, 220),
	[DOTA_TEAM_BADGUYS]  = Vector(220, 90, 120)
}

function Shrines:Init()
	for _, spawn_point in pairs(Entities:FindAllByName("shrine_spawn") do
		Shrine(spawn_point:GetAbsOrigin(), table.remove(SHRINE_TYPES))
	end
end



if Shrine == nil then Shrine = class({
	state = SHRINE_STATE_INACTIVE,
	progress = 0,
}) end

function Shrine:constructor(location, type)
	self.tower = CreateUnitByName("npc_control_shrine", location, false, nil, nil, DOTA_TEAM_NEUTRALS)
	self.tower:AddNewModifier(self.tower, nil, "modifier_shrine_base_state", {})
	self.tower:SetRenderColor(type.tower_color.x, type.tower_color.y, type.tower_color.z)

	self.trigger = MapTrigger(location, TRIGGER_TYPE_CIRCLE, {
		radius = SHRINE_CAPTURE_ZONE_RADIUS
	}, {
		trigger_team = DOTA_TEAM_NEUTRALS,
		team_filter = DOTA_UNIT_TARGET_TEAM_BOTH,
		unit_filter = DOTA_UNIT_TARGET_HERO,
		flag_filter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	}, function(units)
		Timers:CreateTimer(0, function()
			return self:Think(units)
		end)
	end)

	self.capture_pfx = ParticleManager:CreateParticle("capture_point_ring.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.capture_pfx, 0, location)
	ParticleManager:SetParticleControl(self.capture_pfx, 3, SHRINE_BASE_COLOR)
	ParticleManager:SetParticleControl(self.capture_pfx, 9, Vector(SHRINE_CAPTURE_ZONE_RADIUS, 0, 0))

	self.tower_pfx = ParticleManager:CreateParticle(type.tower_particle, PATTACH_ABSORIGIN_FOLLOW, self.tower)

	Timers:CreateTimer(0, function())
end

function Shrine:Think()
	local enemies = FindUnitsInRadius(
		self.golem:GetTeam(),
		self.golem:GetAbsOrigin(),
		nil,
		PATROL_GOLEM_AGGRO_RANGE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_CLOSEST,
		false
	)

	if #enemies > 0 then

		ExecuteOrderFromTable({
			unitIndex = self.golem:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = enemies[1]:entindex()
		})

		return 0.5
	end
end
