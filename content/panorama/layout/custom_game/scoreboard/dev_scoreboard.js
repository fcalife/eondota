GameEvents.Subscribe("new_message", NewMessage);
GameEvents.Subscribe("display_custom_error", ShowCustomError);

CustomNetTables.SubscribeNetTableListener("score", UpdateScoreboard);

let team_names = {}

team_names[2] = "BLUE";
team_names[3] = "RED";
team_names[6] = "GREEN";
team_names[7] = "PINK";
team_names[8] = "YELLOW";
team_names[9] = "CYAN";
team_names[10] = "LIGHT GRAY";
team_names[11] = "DARK GRAY";
team_names[12] = "MAUVE";
team_names[13] = "PLAID";

function NewMessage(data) {
	let container = $("#Message_Container");

	let label = $.CreatePanelWithProperties("Label", container, "", {
		class: "GlobalMessage",
		text: data.text
	});

	if (data.animate) label.AddClass("AnimatedMessage");
	if (data.team) label.text = team_names[data.team] + data.text;

	$.Schedule(4.5, () => {
		label.DeleteAsync(0.0);
	})
}

function UpdateScoreboard(table_name, key, data) {
	if (key == "scoreboard") {
		$("#Blue_Score").text = parseInt(data[DOTATeam_t.DOTA_TEAM_GOODGUYS]);
		$("#Red_Score").text = parseInt(data[DOTATeam_t.DOTA_TEAM_BADGUYS]);
		$("#Green_Score").text = parseInt(data[DOTATeam_t.DOTA_TEAM_CUSTOM_1]);
		$("#Pink_Score").text = parseInt(data[DOTATeam_t.DOTA_TEAM_CUSTOM_2]);
		// $("#Yellow_Score").text = parseInt(data[DOTATeam_t.DOTA_TEAM_CUSTOM_3]);
		// $("#Cyan_Score").text = parseInt(data[DOTATeam_t.DOTA_TEAM_CUSTOM_4]);
		// $("#Light_Gray_Score").text = parseInt(data[DOTATeam_t.DOTA_TEAM_CUSTOM_5]);
		// $("#Dark_Gray_Score").text = parseInt(data[DOTATeam_t.DOTA_TEAM_CUSTOM_6]);
		// $("#Mauve_Score").text = parseInt(data[DOTATeam_t.DOTA_TEAM_CUSTOM_7]);
		// $("#Plaid_Score").text = parseInt(data[DOTATeam_t.DOTA_TEAM_CUSTOM_8]);
	}
}

function ShowCustomError(data) {
	GameEvents.SendEventClientSide("dota_hud_error_message", {
		splitscreenplayer: 0,
		reason: 80,
		message: data.message,
	});
}

// Vanilla UI tweaks
let hud_root = $.GetContextPanel()

while (hud_root.GetParent() != null) {
	hud_root = hud_root.GetParent();
}

function HideBaseHud(panel_name) {
	const panel = hud_root.FindChildTraverse(panel_name);

	if (panel != null) {
		panel.visible = false;
	}
}

HideBaseHud("inventory_neutral_slot_container");
HideBaseHud("inventory_tpscroll_container");
HideBaseHud("left_flare");
HideBaseHud("xp");
HideBaseHud("StatBranch");
HideBaseHud("StatBranchHotkey");
HideBaseHud("ButtonWell");
HideBaseHud("level_stats_frame");

// if (Players.GetTeam(Game.GetLocalPlayerID()) == DOTATeam_t.DOTA_TEAM_GOODGUYS) {
// 	GameUI.SetCameraYaw(-45);
// } else {
// 	GameUI.SetCameraYaw(135);
// }