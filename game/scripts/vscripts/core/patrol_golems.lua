_G.PatrolGolems = PatrolGolems or {}

PATROL_GOLEMS = {}
PATROL_GOLEMS[DOTA_TEAM_GOODGUYS] = {}
PATROL_GOLEMS[DOTA_TEAM_BADGUYS] = {}

local golem_paths = {}

golem_paths["radiant_golem_a_"] = { team = DOTA_TEAM_GOODGUYS, color = Vector(80, 110, 240) }
golem_paths["radiant_golem_b_"] = { team = DOTA_TEAM_GOODGUYS, color = Vector(80, 110, 240) }
golem_paths["dire_golem_a_"] = { team = DOTA_TEAM_BADGUYS, color = Vector(240, 80, 110) }
golem_paths["dire_golem_b_"] = { team = DOTA_TEAM_BADGUYS, color = Vector(240, 80, 110) }

function PatrolGolems:Init()
	table.insert(PATROL_GOLEMS[DOTA_TEAM_GOODGUYS], PatrolGolem("radiant_golem_a_"))
	table.insert(PATROL_GOLEMS[DOTA_TEAM_GOODGUYS], PatrolGolem("radiant_golem_b_"))
	table.insert(PATROL_GOLEMS[DOTA_TEAM_BADGUYS], PatrolGolem("dire_golem_a_"))
	table.insert(PATROL_GOLEMS[DOTA_TEAM_BADGUYS], PatrolGolem("dire_golem_b_"))
end

function PatrolGolems:GetTeamGolems(team)
	return PATROL_GOLEMS[team] or nil
end



if PatrolGolem == nil then PatrolGolem = class({
	path = {},
	next_position = 1
}) end

function PatrolGolem:constructor(path_name)
	local path_counter = 1
	local path_entity = Entities:FindByName(nil, path_name..path_counter)

	self.path = {}

	while path_entity do
		table.insert(self.path, path_entity:GetAbsOrigin())

		path_counter = path_counter + 1
		path_entity = Entities:FindByName(nil, path_name..path_counter)
	end

	local golem_name = (golem_paths[path_name].team == DOTA_TEAM_GOODGUYS and "npc_patrol_golem_good") or "npc_patrol_golem_bad"

	if self.path[1] then
		self.golem = CreateUnitByName(golem_name, self.path[1], false, nil, nil, golem_paths[path_name].team)
		self.golem:AddNewModifier(self.golem, nil, "modifier_golem_base_state", {})
		self.golem:AddNewModifier(self.golem, nil, "modifier_tower_truesight_aura", {})
		self.golem:SetRenderColor(golem_paths[path_name].color.x, golem_paths[path_name].color.y, golem_paths[path_name].color.z)

		Timers:CreateTimer(1, function()
			return self:Think()
		end)
	end
end

function PatrolGolem:Think()
	local heroes = FindUnitsInRadius(
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

	if #heroes > 0 then

		ExecuteOrderFromTable({
			unitIndex = self.golem:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = heroes[1]:entindex()
		})

		return 0.5
	else
		local current_destination = self.path[self.next_position]

		if (self.golem:GetAbsOrigin() - current_destination):Length2D() < 100 then
			self.next_position = self.next_position + 1

			if (not self.path[self.next_position]) then self.next_position = 1 end

			current_destination = self.path[self.next_position]
		end

		self.golem:MoveToPosition(self.path[self.next_position])

		return 0.5
	end
end
