TryGetHost();

$('#small_grid').SetSelected(false);
$('#smaller_grid').SetSelected(false);
$('#camera_lock').SetSelected(true);
$('#fast_abilities').SetSelected(false);
$('#faster_abilities').SetSelected(false);

$('#smaller_grid_container').visible = false;
$('#faster_abilities_container').visible = false;

function UpdateOptions() {
	$('#smaller_grid_container').visible = $('#small_grid').IsSelected();
	$('#faster_abilities_container').visible = $('#fast_abilities').IsSelected();

	GameEvents.SendCustomGameEventToServer("host_options_updated", {
		small_grid: $('#small_grid').IsSelected(),
		smaller_grid: $('#smaller_grid').IsSelected(),
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