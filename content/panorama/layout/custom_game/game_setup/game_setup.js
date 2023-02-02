TryGetHost();

$('#lock_camera').SetSelected(true);

function UpdateOptions() {
 	GameEvents.SendCustomGameEventToServer("host_options_updated", {
 		lock_camera: $('#lock_camera').IsSelected(),
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