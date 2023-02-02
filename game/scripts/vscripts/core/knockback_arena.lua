_G.KnockbackArena = KnockbackArena or {}

function KnockbackArena:OnExitRing(unit)
	unit:AddNewModifier(unit, nil, "modifier_thrown_out", {duration = 2.0})

	unit:StartGesture(ACT_DOTA_FLAIL)
end

function KnockbackArena:OnThrowOutStatusEnd(unit)
	unit:FadeGesture(ACT_DOTA_FLAIL)

	if (not unit:HasModifier("modifier_reeling_in")) then
		ApplyDamage({attacker = unit, victim = unit, damage = 1000, damage_type = DAMAGE_TYPE_PURE})
	end
end