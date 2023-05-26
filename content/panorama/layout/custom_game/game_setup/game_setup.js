TryGetHost();

$('#camera_lock').SetSelected(false);
$('#fast_abilities').SetSelected(false);
$('#faster_abilities').SetSelected(false);

$('#faster_abilities_container').visible = false;

function UpdateOptions() {
	$('#faster_abilities_container').visible = $('#fast_abilities').IsSelected();

	GameEvents.SendCustomGameEventToServer("host_options_updated", {
		camera_lock: $('#camera_lock').IsSelected(),
		fast_abilities: $('#fast_abilities').IsSelected(),
		faster_abilities: $('#faster_abilities').IsSelected(),
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