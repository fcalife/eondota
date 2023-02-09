_G.KnockbackArena = KnockbackArena or {}

ARENA_RADIUS = 1400

KNOCKBACK_LENGTH = {}

KNOCKBACK_LENGTH[1] = {}
KNOCKBACK_LENGTH[1][10] = 0
KNOCKBACK_LENGTH[1][9] = 125
KNOCKBACK_LENGTH[1][8] = 225
KNOCKBACK_LENGTH[1][7] = 325
KNOCKBACK_LENGTH[1][6] = 500
KNOCKBACK_LENGTH[1][5] = 700
KNOCKBACK_LENGTH[1][4] = 800
KNOCKBACK_LENGTH[1][3] = 900
KNOCKBACK_LENGTH[1][2] = 1000
KNOCKBACK_LENGTH[1][1] = 1300

KNOCKBACK_LENGTH[2] = {}
KNOCKBACK_LENGTH[2][10] = 0
KNOCKBACK_LENGTH[2][9] = 200 
KNOCKBACK_LENGTH[2][8] = 350
KNOCKBACK_LENGTH[2][7] = 475
KNOCKBACK_LENGTH[2][6] = 650
KNOCKBACK_LENGTH[2][5] = 875
KNOCKBACK_LENGTH[2][4] = 975
KNOCKBACK_LENGTH[2][3] = 1100
KNOCKBACK_LENGTH[2][2] = 1300
KNOCKBACK_LENGTH[2][1] = 1600

function KnockbackArena:OnExitRing(unit)
	unit:AddNewModifier(unit, nil, "modifier_thrown_out", {duration = 1.0})

	unit:StartGesture(ACT_DOTA_FLAIL)
end

function KnockbackArena:OnThrowOutStatusEnd(unit)
	unit:FadeGesture(ACT_DOTA_FLAIL)

	if (not unit:HasModifier("modifier_reeling_in")) then
		ApplyDamage({attacker = unit, victim = unit, damage = 1000, damage_type = DAMAGE_TYPE_PURE})
	end
end

function KnockbackArena:Knockback(attacker, target, x, y, damage)
	if target:HasModifier("modifier_powerup_shield") then
		target:RemoveModifierByName("modifier_powerup_shield")

		target:EmitSound("KnockbackArena.Powerup.Shield.Pop")

		return
	end

	local knockback_direction = Vector(x, y, 0):Normalized()
	local knockback_origin = target:GetAbsOrigin() - 100 * knockback_direction

	ApplyDamage({attacker = attacker, victim = target, damage = damage, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL})

	local target_health = target:GetHealth()

	local distance = KNOCKBACK_LENGTH[damage][target_health]

	if target:HasModifier("modifier_powerup_metal") then
		distance = 0.5 * distance

		target:EmitSound("KnockbackArena.Powerup.Metal.Clang")
	end

	local duration = 0.2 + 0.0002 * distance
	local height = 30 + 0.04 * distance

	local knockback = {
		center_x = knockback_origin.x,
		center_y = knockback_origin.y,
		center_z = knockback_origin.z,
		knockback_duration = duration,
		knockback_distance = distance,
		knockback_height = height,
		should_stun = 1,
		duration = duration
	}

	target:RemoveModifierByName("modifier_knockback")
	target:AddNewModifier(attacker, nil, "modifier_knockback", knockback)
end