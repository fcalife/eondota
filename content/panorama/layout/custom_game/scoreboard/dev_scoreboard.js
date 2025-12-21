GameEvents.Subscribe("new_message", NewMessage);
GameEvents.Subscribe("display_custom_error", ShowCustomError);

// Uncomment any of the following lines in order to disable that portion of the default UI
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_COURIER, false);			// Courier controls.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false);			// Glyph.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, false);			// Suggested items shop panel.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PANEL, false);			// Suggested items shop panel.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false);			// Suggested items shop panel.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_ITEMS, false);			// Suggested items shop panel.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_AGHANIMS_STATUS, false);			// Suggested items shop panel.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_KILLCAM, false);			// Suggested items shop panel.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, false);			// Suggested items shop panel.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP, false);			// Suggested items shop panel.

// These lines set up the panorama colors used by each team (for game select/setup, etc)
GameUI.CustomUIConfig().team_colors = {}
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_GOODGUYS] = "#4040D0;";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_BADGUYS ] = "#D04040;";

function NewMessage(data) {
	let container = $("#Message_Container");

	let label = $.CreatePanel("Label", container, "", {
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
HideBaseHud("inventory_neutral_craft_holder");
HideBaseHud("inventory_tpscroll_container");
HideBaseHud("left_flare");
HideBaseHud("xp");
HideBaseHud("StatBranch");
HideBaseHud("StatBranchHotkey");
HideBaseHud("ButtonWell");
HideBaseHud("level_stats_frame");
HideBaseHud("minimap_container");

$.Msg("help")
if (Players.GetTeam(Game.GetLocalPlayerID()) == DOTATeam_t.DOTA_TEAM_GOODGUYS) {
	GameUI.SetCameraYaw(-45);
} else {
	GameUI.SetCameraYaw(135);
}