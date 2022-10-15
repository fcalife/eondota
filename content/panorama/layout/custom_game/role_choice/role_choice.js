$.Schedule(5, () => { $("#Container").visible = true });

function SelectRole(role) {
	GameEvents.SendCustomGameEventToServer("player_role_selected", {role: role});

	$("#Container").visible = false;
}