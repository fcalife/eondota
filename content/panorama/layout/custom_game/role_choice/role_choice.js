// $.Schedule(5, () => { $("#Container").visible = true });

// if(Players.GetTeam(Players.GetLocalPlayer()) == DOTATeam_t.DOTA_TEAM_GOODGUYS) {
// 	GameUI.SetCameraYaw(-90);
// } else {
// 	GameUI.SetCameraYaw(-270);
// }

GameEvents.Subscribe("open_building_menu", OpenBuildingMenu);

function OpenBuildingMenu() {
	$("#Container").visible = true;
}

function CloseBuildingMenu() {
	$("#Container").visible = false;
}

function SelectBuilding(building) {
	GameEvents.SendCustomGameEventToServer("building_selected", {building: building});

	CloseBuildingMenu();
}