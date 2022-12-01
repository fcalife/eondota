TryGetHost();

$('#reverse_ctf').SetSelected(false);
$('#enable_towers').SetSelected(false);
$('#enable_creeps').SetSelected(false);
$('#disable_fog').SetSelected(true);

$('#creeps_container').visible = false;

function UpdateOptions() {
 	GameEvents.SendCustomGameEventToServer("host_options_updated", {
 		reverse_ctf: $('#reverse_ctf').IsSelected(),
 		enable_towers: $('#enable_towers').IsSelected(),
 		enable_creeps: $('#enable_creeps').IsSelected(),
 		disable_fog: $('#disable_fog').IsSelected(),
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