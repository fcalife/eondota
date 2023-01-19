GameEvents.Subscribe("new_message", NewMessage);
GameEvents.Subscribe("display_custom_error", ShowCustomError);

CustomNetTables.SubscribeNetTableListener("charge", UpdateScore);

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
	} else if (key == "PINK") {
		$("#Pink_Score").text = parseInt(data.score);
	}
}