const FindDotaHudElement = (id) => dotaHud.FindChildTraverse(id);
const dotaHud = (() => {
	let panel = $.GetContextPanel();
	while (panel) {
		if (panel.id === "DotaHud") return panel;
		panel = panel.GetParent();
	}
})();

const DOTA_SHOP = FindDotaHudElement("shop");

GameEvents.Subscribe("new_message", NewMessage);
GameEvents.Subscribe("display_custom_error", ShowCustomError);

CustomNetTables.SubscribeNetTableListener("charge", UpdateScore);
CustomNetTables.SubscribeNetTableListener("bosses", UpdateBossMap);

$.RegisterEventHandler("PanelStyleChanged", DOTA_SHOP, HideBossmapBehindShop);

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

function UpdateScore(table_name, key, data) {
	if (key == "BLUE") {
		$("#Blue_Score").text = parseInt(data.score);
	} else if (key == "RED") {
		$("#Red_Score").text = parseInt(data.score);
	} else if (key == "GREEN") {
		$("#Green_Score").text = parseInt(data.score);
	}
}

function UpdateBossMap(table_name, key, data) {
	$("#" + key + "_Portrait").visible = true;
	$("#" + key + "_Portrait").style.saturation = (data.alive ? "1.0" : "0.0");
	$("#" + key + "_Portrait").style.brightness = (data.alive ? "1.0" : "0.4");
	$("#" + key + "_Background").style.saturation = (data.alive ? "1.0" : "0.0");
	$("#" + key + "_Background").style.brightness = (data.alive ? "1.0" : "0.4");
}

function HideBossmapBehindShop() {
	$("#Bossmap").SetHasClass("dota_shop_opened", DOTA_SHOP.BHasClass("ShopOpen"));
}