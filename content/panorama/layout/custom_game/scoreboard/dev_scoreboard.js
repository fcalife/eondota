GameEvents.Subscribe("new_message", NewMessage);
GameEvents.Subscribe("display_custom_error", ShowCustomError);

CustomNetTables.SubscribeNetTableListener("charge", UpdateCharge);

function UpdateCharge(table_name, key, data) {
	if (key == "radiant") {
		$("#Radiant_Charge_Label").text = "Blue coins: " + data.current.toFixed(0);
		$("#Radiant_Progress").value = parseInt(data.current);
		$("#Radiant_Progress").max = parseInt(data.max);
	} else if (key == "dire") {
		$("#Dire_Charge_Label").text = "Red coins: " + data.current.toFixed(0);
		$("#Dire_Progress").value = parseInt(data.current);
		$("#Dire_Progress").max = parseInt(data.max);
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