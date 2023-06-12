GameEvents.Subscribe("new_message", NewMessage);
GameEvents.Subscribe("display_custom_error", ShowCustomError);

GameEvents.Subscribe("boss_health", UpdateHealth);
GameEvents.Subscribe("boss_position", UpdatePosition);
GameEvents.Subscribe("boss_timer", UpdateTimer);
GameEvents.Subscribe("show_health", ShowHealth);
GameEvents.Subscribe("hide_health", HideHealth);

// CustomNetTables.SubscribeNetTableListener("score", UpdateScoreboard);
// CustomNetTables.SubscribeNetTableListener("round_timer", UpdateTimer);

let team_names = {}

team_names[2] = "BLUE";
team_names[3] = "RED";
team_names[6] = "GREEN";
team_names[7] = "PINK";
team_names[8] = "YELLOW";
team_names[9] = "CYAN";
team_names[10] = "LIGHT GRAY";
team_names[11] = "DARK GRAY";
team_names[12] = "MAUVE";
team_names[13] = "PLAID";

var RANGEFINDER = 0;

function ShowHealth() {
	$("#Boss_Health_Container").visible = true;
}

function HideHealth() {
	$("#Boss_Health_Container").visible = false;
}

function UpdateHealth(data) {
	$("#Boss_Health_Label").text = data.health + " / " + data.max_health;
	$("#Boss_Health").value = data.health;
	$("#Boss_Health").max = data.max_health;

	let normalHealth = Math.min(1, (Math.max(3000, data.health) - 3000) / 7000);

	let red = 240 - Math.round(175 * normalHealth);
	let green = 16 + Math.round(239 * normalHealth);
	let blue = 16 + Math.round(48 * normalHealth);

	let color = "#" + red.toString(16) + green.toString(16) + blue.toString(16)

	$("#Boss_Health_Left").style["background-color"] = color;
}

function UpdatePosition(data) {
	let hero_loc = Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()))
	let camera_loc = GameUI.GetCameraLookAtPosition();
	let boss_loc = [data.x, data.y, 0];

	let distance = Math.sqrt(Math.pow(camera_loc[0] - boss_loc[0], 2) + Math.pow(camera_loc[1] - boss_loc[1], 2));

	if (distance > 1350) {
		let direction = [boss_loc[0] - hero_loc[0], boss_loc[1] - hero_loc[1]];
		let modulo = Math.sqrt(direction[0] * direction[0] + direction[1] * direction[1]);

		direction = [direction[0] / modulo, direction[1] / modulo];

		let length = Math.min(1000, distance - 225);

		let arrow_loc = [hero_loc[0] + length * direction[0], hero_loc[1] + length * direction[1], hero_loc[2]];

		if (RANGEFINDER > 0) {
			Particles.SetParticleControl(RANGEFINDER, 1, hero_loc);
			Particles.SetParticleControl(RANGEFINDER, 2, arrow_loc);
		} else {
			RANGEFINDER = Particles.CreateParticle("particles/boss/boss_arrow.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0);
			$.Msg(RANGEFINDER)
			Particles.SetParticleControl(RANGEFINDER, 1, hero_loc);
			Particles.SetParticleControl(RANGEFINDER, 2, arrow_loc);
			Particles.SetParticleControl(RANGEFINDER, 3, [85, 40, 0]);
			Particles.SetParticleControl(RANGEFINDER, 4, [255, 14, 14]);
			Particles.SetParticleControl(RANGEFINDER, 6, [1, 1, 1]);
		}
	} else {
		if (RANGEFINDER > 0) {
			Particles.DestroyParticleEffect(RANGEFINDER, true);
			Particles.ReleaseParticleIndex(RANGEFINDER);

			RANGEFINDER = 0;
		}
	}
}

function UpdateTimer(data) {
	let minutes = Math.floor(data.time / 60)
	let seconds = data.time - 60 * minutes

	if (minutes < 10) minutes = "0" + minutes;
	if (seconds < 10) seconds = "0" + seconds;

	$("#Fight_Timer").text = minutes + ":" + seconds;
}

function NewMessage(data) {
	let container = $("#Message_Container");

	let label = $.CreatePanelWithProperties("Label", container, "", {
		class: "GlobalMessage",
		text: data.text
	});

	if (data.animate) label.AddClass("AnimatedMessage");
	if (data.team) label.text = team_names[data.team] + data.text;

	$.Schedule(6.0, () => {
		label.DeleteAsync(0.0);
	})
}

function UpdateScoreboard(table_name, key, data) {
	if (key == "scoreboard") {
		$("#Blue_Score").text = parseInt(data[DOTATeam_t.DOTA_TEAM_GOODGUYS]);
		$("#Red_Score").text = parseInt(data[DOTATeam_t.DOTA_TEAM_BADGUYS]);
		$("#Green_Score").text = parseInt(data[DOTATeam_t.DOTA_TEAM_CUSTOM_1]);
		$("#Pink_Score").text = parseInt(data[DOTATeam_t.DOTA_TEAM_CUSTOM_2]);
	}
}

// function UpdateTimer(table_name, key, data) {
// 	if (key == "timer") {
// 		$("#Fight_Timer").text = parseInt(data.round_time_remaining);
// 	}
// }

function ShowCustomError(data) {
	GameEvents.SendEventClientSide("dota_hud_error_message", {
		splitscreenplayer: 0,
		reason: 80,
		message: data.message,
	});
}

// Vanilla UI tweaks
let hud_root = $.GetContextPanel()

while (hud_root.GetParent() != null) {
	hud_root = hud_root.GetParent();
}

function HideBaseHud(panel_name) {
	const panel = hud_root.FindChildTraverse(panel_name);

	if (panel != null) {
		panel.visible = false;
	}
}

HideBaseHud("inventory_neutral_slot_container");
HideBaseHud("inventory_tpscroll_container");
HideBaseHud("left_flare");
HideBaseHud("xp");
HideBaseHud("StatBranch");
HideBaseHud("StatBranchHotkey");
HideBaseHud("ButtonWell");
HideBaseHud("level_stats_frame");