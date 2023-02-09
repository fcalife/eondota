TryGetHost();

$('#lock_camera').SetSelected(true);
$('#smash_mode').SetSelected(false);
$('#extra_powerups').SetSelected(false);

function UpdateOptions() {
 	GameEvents.SendCustomGameEventToServer("host_options_updated", {
 		lock_camera: $('#lock_camera').IsSelected(),
 		smash_mode: $('#smash_mode').IsSelected(),
 		extra_powerups: $('#extra_powerups').IsSelected(),
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