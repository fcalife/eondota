GameEvents.Subscribe("got_eon", GotEon);
GameEvents.Subscribe("reset_eon", ResetEon);

let eon_count = 0;

function GotEon() {
	eon_count = eon_count + 1;

	Game.EmitSound("ui.badge_levelup");

	if (eon_count == 5) {
		$("#Pip05").AddClass("ActivePip");

		$.Schedule(2.5, () => {
			$("#Pip05").AddClass("GlowingPip");
			$("#Pip04").AddClass("GlowingPip");
			$("#Pip03").AddClass("GlowingPip");
			$("#Pip02").AddClass("GlowingPip");
			$("#Pip01").AddClass("GlowingPip");
		})
	}

	if (eon_count == 4) $("#Pip04").AddClass("ActivePip");
	if (eon_count == 3) $("#Pip03").AddClass("ActivePip");
	if (eon_count == 2) $("#Pip02").AddClass("ActivePip");
	if (eon_count == 1) $("#Pip01").AddClass("ActivePip");
}

function ResetEon() {
	eon_count = 0;

	$("#Pip05").RemoveClass("GlowingPip");
	$("#Pip04").RemoveClass("GlowingPip");
	$("#Pip03").RemoveClass("GlowingPip");
	$("#Pip02").RemoveClass("GlowingPip");
	$("#Pip01").RemoveClass("GlowingPip");

	$("#Pip05").RemoveClass("ActivePip");
	$("#Pip04").RemoveClass("ActivePip");
	$("#Pip03").RemoveClass("ActivePip");
	$("#Pip02").RemoveClass("ActivePip");
	$("#Pip01").RemoveClass("ActivePip");
}