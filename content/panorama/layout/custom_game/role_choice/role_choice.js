function ResetFight() {
	GameEvents.SendCustomGameEventToServer("debug_command_fight_reset", {});
}

function AdvancePhase() {
	GameEvents.SendCustomGameEventToServer("debug_command_advance_phase", {});
}

function HealAll() {
	GameEvents.SendCustomGameEventToServer("debug_command_heal_all", {});
}

function GodMode() {
	GameEvents.SendCustomGameEventToServer("debug_command_god_mode", {});
}

function SetSphereSourceHealth() {
	GameEvents.SendCustomGameEventToServer(
		"debug_command_set_sphere_trigger_health",
		{}
	);
}

function SetSphereSourceWeakPoint() {
	GameEvents.SendCustomGameEventToServer(
		"debug_command_set_sphere_trigger_weak_point",
		{}
	);
}

function SetSphereSourceMap() {
	GameEvents.SendCustomGameEventToServer(
		"debug_command_set_sphere_trigger_map",
		{}
	);
}

function SetFirstSphereMoveSpeed() {
	GameEvents.SendCustomGameEventToServer("debug_command_sphere_ms", {
		value: $("#FirstSphereInput").text,
	});
}

function SetSecondSphereRegen() {
	GameEvents.SendCustomGameEventToServer("debug_command_sphere_regen", {
		value: $("#SecondSphereInput").text,
	});
}

function SetThirdSphereShieldAmount() {
	GameEvents.SendCustomGameEventToServer("debug_command_sphere_shield", {
		value: $("#ThirdSphereInput").text,
	});
}

function SetThirdSphereShieldCooldown() {
	GameEvents.SendCustomGameEventToServer("debug_command_sphere_shield_cd", {
		value: $("#ThirdSphereCooldownInput").text,
	});
}

function SetFourthSphereDamage() {
	GameEvents.SendCustomGameEventToServer("debug_command_sphere_nuke_damage", {
		value: $("#FourthSphereInput").text,
	});
}

function SetFifthSphereFactor() {
	GameEvents.SendCustomGameEventToServer(
		"debug_command_sphere_power_factor",
		{
			value: $("#FifthSphereInput").text,
		}
	);
}

function SetPlayerHealth() {
	GameEvents.SendCustomGameEventToServer("debug_command_set_player_health", {
		value: $("#PlayerHealthInput").text,
	});
}

function ToggleMenu() {
	$("#MenuContainer").visible = !$("#MenuContainer").visible;
}
