CustomNetTables.SubscribeNetTableListener("score", UpdateScore);

function UpdateScore(table_name, key, data) {
  $("#RadiantScore").text = data[DOTATeam_t.DOTA_TEAM_GOODGUYS];
  $("#DireScore").text = data[DOTATeam_t.DOTA_TEAM_BADGUYS];
}