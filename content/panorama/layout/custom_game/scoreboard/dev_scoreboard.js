GameEvents.Subscribe("new_message", NewMessage);
GameEvents.Subscribe("display_custom_error", ShowCustomError);

function NewMessage(data) {
	let container = $("#Message_Container");

	let label = $.CreatePanelWithProperties("Label", container, "", {
		class: "GlobalMessage",
		text: data.text
	});

	if (data.animate) label.AddClass("AnimatedMessage");

	$.Schedule(4.5, () => {
		label.DeleteAsync(0.0);
	})
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

if (Players.GetTeam(Game.GetLocalPlayerID()) == DOTATeam_t.DOTA_TEAM_GOODGUYS) {
	GameUI.SetCameraYaw(-40);
} else {
	GameUI.SetCameraYaw(140);
}