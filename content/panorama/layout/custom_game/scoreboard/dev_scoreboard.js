CustomNetTables.SubscribeNetTableListener("score", UpdateScore);

GameEvents.Subscribe("point_scored", PointScored);

function UpdateScore(table_name, key, data) {
 	$("#RadiantScore").text = data[DOTATeam_t.DOTA_TEAM_GOODGUYS];
 	$("#DireScore").text = data[DOTATeam_t.DOTA_TEAM_BADGUYS];
}

function PointScored(data) {
	let label = $("#Score_Indicator");
	let text = `${(data.team == DOTATeam_t.DOTA_TEAM_GOODGUYS) ? "Radiant" : "Dire"} just scored!`;

	label.text = text;
	label.visible = true;

	$.Schedule(4.5, () => {
		label.visible = false;
	})
}