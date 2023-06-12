TryGetHost();

$('#camera_lock').SetSelected(false);
// $('#fast_abilities').SetSelected(false);
// $('#faster_abilities').SetSelected(false);

// $('#faster_abilities_container').visible = false;

$('#hard_mode').SetSelected(true);
$('#nightmare_mode').SetSelected(false);

function UpdateOptions() {
	// $('#faster_abilities_container').visible = $('#fast_abilities').IsSelected();
	if ($('#nightmare_mode').IsSelected()) $('#hard_mode').SetSelected(false);

	GameEvents.SendCustomGameEventToServer("host_options_updated", {
		camera_lock: $('#camera_lock').IsSelected(),
		// fast_abilities: $('#fast_abilities').IsSelected(),
		// faster_abilities: $('#faster_abilities').IsSelected(),
		hard_mode: $('#hard_mode').IsSelected(),
		nightmare_mode: $('#nightmare_mode').IsSelected(),
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