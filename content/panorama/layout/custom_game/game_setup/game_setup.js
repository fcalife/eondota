TryGetHost();

$('#disable_fog').SetSelected(false);
$('#camera_lock').SetSelected(true);
$('#random_abilities').SetSelected(false);
$('#same_random_ability').SetSelected(true);

$('#same_random_ability_container').visible = false;

function UpdateOptions() {
	$('#same_random_ability_container').visible = $('#random_abilities').IsSelected();

	GameEvents.SendCustomGameEventToServer("host_options_updated", {
		disable_fog: $('#disable_fog').IsSelected(),
		camera_lock: $('#camera_lock').IsSelected(),
		random_abilities: $('#random_abilities').IsSelected(),
		same_random_ability: $('#same_random_ability').IsSelected(),
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