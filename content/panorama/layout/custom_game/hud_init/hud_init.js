GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_COURIER, false);
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false);
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, false);
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PANEL, false);
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false);
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_ITEMS, false);
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_AGHANIMS_STATUS, false);
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_KILLCAM, false);
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, false);
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP, false);
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_RADIANT_TEAM, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_DIRE_TEAM, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_SCORE, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_QUICK_STATS, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false);
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, false);

// Vanilla UI tweaks
const hud_root = $.GetContextPanel().GetParent().GetParent();

function HideBaseHud(panel_name) {
	hud_root.FindChildTraverse(panel_name).visible = false;
}

function AdjustBaseHud(panel_name, parameter, new_value) {
	const panel = hud_root.FindChildTraverse(panel_name);

	panel.style[parameter] = new_value;
}

HideBaseHud("ToggleScoreboardButton");
HideBaseHud("inventory_neutral_slot_container");
HideBaseHud("inventory_tpscroll_container");
HideBaseHud("xp");
// HideBaseHud("StatBranch");
// HideBaseHud("StatBranchHotkey");
// HideBaseHud("ButtonWell");
// HideBaseHud("level_stats_frame");
// HideBaseHud("left_flare");

// AdjustBaseHud("center_with_stats", "horizontal-align", "left");
// AdjustBaseHud("PortraitGroup", "margin-left", "0px");
// AdjustBaseHud("center_bg", "margin-left", "0px");
// AdjustBaseHud("stats_container", "margin-left", "30px");
// AdjustBaseHud("unitname", "margin-left", "10px");
// AdjustBaseHud("unitname", "width", "300px");
// AdjustBaseHud("UnitNameLabel", "text-align", "left");
// AdjustBaseHud("AbilitiesAndStatBranch", "margin-left", "193px");
// AdjustBaseHud("buffs", "margin-left", "10px");
// AdjustBaseHud("buffs", "margin-bottom", "165px");
// AdjustBaseHud("debuffs", "margin-left", "10px");
// AdjustBaseHud("debuffs", "margin-right", "0px");
// AdjustBaseHud("debuffs", "margin-bottom", "210px");
// AdjustBaseHud("debuffs", "horizontal-align", "left");
// AdjustBaseHud("debuffs", "flow-children", "right");
// AdjustBaseHud("HealthManaContainer", "margin-left", "171px");
// AdjustBaseHud("HealthManaContainer", "margin-right", "220px");

// This one is a bit more involved
// const center_root = hud_root.FindChildTraverse("center_block");

// for (let index = 0; index < center_root.GetChildCount(); index++) {
// 	const child = center_root.GetChild(index)

// 	if (child.BHasClass("AbilityInsetShadowLeft") || child.BHasClass("AbilityInsetShadowRight")) {
// 		child.visible = false;
// 	}
// }

// // These need to happen after we are ingame
// GameEvents.Subscribe("pregame_started", (event) => {
// 	GameUI.SetCameraPitchMin(35);
// 	GameUI.SetCameraPitchMax(85);
// });