GameEvents.Subscribe("new_message", NewMessage);
GameEvents.Subscribe("display_custom_error", ShowCustomError);

CustomNetTables.SubscribeNetTableListener("coins", UpdateCoins);

function UpdateCoins(table_name, key, data) {
	if (key == "player" + Game.GetLocalPlayerID()) {
		$("#Radiant_Charge_Label").text = "Your coins: " + data.coins.toFixed(0);
	}
}

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