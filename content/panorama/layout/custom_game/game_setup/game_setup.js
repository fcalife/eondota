TryGetHost();

$('#enable_towers').SetSelected(true);
$('#enable_creeps').SetSelected(false);
$('#disable_fog').SetSelected(false);
$('#extra_hp').SetSelected(false);

function UpdateOptions() {
 	GameEvents.SendCustomGameEventToServer("host_options_updated", {
 		enable_towers: $('#enable_towers').IsSelected(),
 		enable_creeps: $('#enable_creeps').IsSelected(),
 		disable_fog: $('#disable_fog').IsSelected(),
 		extra_hp: $('#extra_hp').IsSelected(),
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