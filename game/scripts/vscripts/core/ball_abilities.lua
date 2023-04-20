_G.BallAbilities = BallAbilities or {}

CustomGameEventManager:RegisterListener("player_role_selected", function(_, event)
	BallAbilities:OnPlayerSelectedRole(event)
end)



function BallAbilities:OnPlayerSelectedRole(event)
	if event.role then self:SetRole(event.PlayerID, event.role) end
end

function BallAbilities:SetRole(player_id, role)
	local hero = PlayerResource:GetSelectedHeroEntity(player_id)

	if hero then
		local added_ball_ability = false
		local i = 0

		while (not added_ball_ability) do
			local ability = hero:GetAbilityByIndex(i)

			if ability and ability:GetAbilityName() == "generic_hidden" then
				hero:RemoveAbilityByHandle(ability)
				added_ball_ability = true

				local ball_ability = hero:AddAbility("ability_ball_"..role)
				ball_ability:SetLevel(1)

				if ball_ability:GetAbilityName() ~= "ability_ball_forcer" then ball_ability:SetActivated(false) end
			elseif i >= DOTA_MAX_ABILITIES then
				added_ball_ability = true

				local ball_ability = hero:AddAbility("ability_ball_"..role)
				ball_ability:SetLevel(1)

				if ball_ability:GetAbilityName() ~= "ability_ball_forcer" then ball_ability:SetActivated(false) end
			end

			i = i + 1
		end
	end
end