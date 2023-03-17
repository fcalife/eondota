basic_ink = class({})

LinkLuaModifier("modifier_basic_ink", "abilities/paint", LUA_MODIFIER_MOTION_NONE)

function basic_ink:GetIntrinsicModifierName()
	return "modifier_basic_ink"
end



modifier_basic_ink = class({})

function modifier_basic_ink:IsHidden() return true end
function modifier_basic_ink:IsDebuff() return false end
function modifier_basic_ink:IsPurgable() return false end

function modifier_basic_ink:OnCreated()
	if IsClient() then return end

	self:StartIntervalThink(0.03)
end

function modifier_basic_ink:OnIntervalThink()
	local caster = self:GetParent()
	local position = caster:GetAbsOrigin()
	local team = caster:GetTeam()

	local square = PaintableGrids:GetSquareClosestTo(position)

	if square then square:SetCurrentTeam(team, 0.05) end
end



ballistic_ink = class({})

function ballistic_ink:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local team = caster:GetTeam()

	local distance = (target - caster:GetAbsOrigin()):Length2D()
	local delay = distance / 1500

	local target_grid = PaintableGrids:GetGridPositionClosestTo(target)
	local target_squares = PaintableGrids:GetSquaresAround(target_grid.x, target_grid.y, NEIGHBOR_SHAPE_CROSS)

	caster:EmitSound("Ink.Launch")

	local ink_blob_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_snapfire/snapfire_lizard_blobs_arced.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(ink_blob_pfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(ink_blob_pfx, 1, target)
	ParticleManager:SetParticleControl(ink_blob_pfx, 2, Vector(1500, 0, 0))

	Timers:CreateTimer(delay, function()
		ParticleManager:DestroyParticle(ink_blob_pfx, false)
		ParticleManager:ReleaseParticleIndex(ink_blob_pfx)

		EmitSoundOnLocationWithCaster(target, "Ink.Splotch", caster)

		local ink_splash_pfx = ParticleManager:CreateParticle("particles/tag/ink_splotch.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(ink_splash_pfx, 0, target)
		ParticleManager:SetParticleControl(ink_splash_pfx, 1, TEAM_COLORS[team])
		ParticleManager:SetParticleControl(ink_splash_pfx, 2, Vector(1.25 * GRID_RADIUS, self:GetSpecialValueFor("stickyness"), 0))
		ParticleManager:ReleaseParticleIndex(ink_splash_pfx)

		for _, square in pairs(target_squares) do
			square:SetCurrentTeam(team, self:GetSpecialValueFor("stickyness"))
		end
	end)
end



splatter_ink = class({})

function splatter_ink:OnSpellStart()
	local caster = self:GetCaster()
	local team = caster:GetTeam()
	local target = caster:GetAbsOrigin()

	local target_grid = PaintableGrids:GetGridPositionClosestTo(target)
	local target_squares = PaintableGrids:GetSquaresAround(target_grid.x, target_grid.y, NEIGHBOR_SHAPE_SQUARE)

	for _, square in pairs(target_squares) do
		square:SetCurrentTeam(team, self:GetSpecialValueFor("stickyness"))
	end

	caster:EmitSound("Ink.Smash")
	caster:EmitSound("Ink.Splotch")

	local smash_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(smash_pfx, 0, target)
	ParticleManager:SetParticleControl(smash_pfx, 1, Vector(2.5 * GRID_RADIUS, 0, 0))
	ParticleManager:ReleaseParticleIndex(smash_pfx)

	local ink_splash_pfx = ParticleManager:CreateParticle("particles/tag/ink_splotch.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(ink_splash_pfx, 0, target)
	ParticleManager:SetParticleControl(ink_splash_pfx, 1, TEAM_COLORS[team])
	ParticleManager:SetParticleControl(ink_splash_pfx, 2, Vector(2.5 * GRID_RADIUS, self:GetSpecialValueFor("stickyness"), 0))
	ParticleManager:ReleaseParticleIndex(ink_splash_pfx)
end