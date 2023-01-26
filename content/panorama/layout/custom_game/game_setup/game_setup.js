TryGetHost();

$('#item_shop').SetSelected(false);

function UpdateOptions() {
 	GameEvents.SendCustomGameEventToServer("host_options_updated", {
 		item_shop: $('#item_shop').IsSelected(),
 	});
}

function TryGetHost() {
	if (Game.GetLocalPlayerInfo() != undefined) {
		if (Game.GetLocalPlayerInfo().player_has_host_privileges) {
			$("#Container").visible = true;
		}
	} else {
		$.Schedule(1, TryGetHost);
	}
}