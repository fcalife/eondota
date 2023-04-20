// $.Schedule(5, () => { $("#Container").visible = true });

// if(Players.GetTeam(Players.GetLocalPlayer()) == DOTATeam_t.DOTA_TEAM_GOODGUYS) {
// 	GameUI.SetCameraYaw(-90);
// } else {
// 	GameUI.SetCameraYaw(-270);
// }

function SelectRole(role) {
	GameEvents.SendCustomGameEventToServer("player_role_selected", {role: role});

	$("#Container").visible = false;
}