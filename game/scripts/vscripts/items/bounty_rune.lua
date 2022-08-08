item_bounty_rune = class({})

function item_bounty_rune:OnSpellStart(keys)
	if IsClient() then return end

	local game_time = GameClock:GetActualGameTime()

	local gold = BOUNTY_RUNE_BASE_GOLD + game_time * BOUNTY_RUNE_GOLD_PER_SECOND
	local exp = BOUNTY_RUNE_BASE_EXP + game_time * BOUNTY_RUNE_EXP_PER_SECOND

	local caster = self:GetCaster()
	local team = caster:GetTeam()

	PassiveGold:GiveGoldToPlayersInTeam(team, gold, exp)

	EmitAnnouncerSoundForTeam("bounty_rune.picked_up", team)

	local location = self:GetContainer():GetAbsOrigin()
	Timers:CreateTimer(BOUNTY_RUNE_SPAWN_INTERVAL, function()
		RuneSpawner:SpawnBountyRune(location)
	end)

	self:Destroy()
end