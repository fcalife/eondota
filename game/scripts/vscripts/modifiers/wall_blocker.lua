modifier_wall_blocker = class({})

function modifier_wall_blocker:IsHidden() return true end
function modifier_wall_blocker:IsDebuff() return false end
function modifier_wall_blocker:IsPurgable() return false end



modifier_ignore_wall = class({})

function modifier_ignore_wall:IsHidden() return true end
function modifier_ignore_wall:IsDebuff() return false end
function modifier_ignore_wall:IsPurgable() return false end

function modifier_ignore_wall:CheckState()
	return {
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_ALLOW_PATHING_THROUGH_FISSURE] = true,
	}
end