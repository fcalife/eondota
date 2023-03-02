CustomNetTables.SubscribeNetTableListener("score", UpdateMenu);

function UpdateMenu(table_name, key, data) {
	let pID = Game.GetLocalPlayerID().toString();

	if (key == "menu_access") {
		$("#UnitColumn").visible = (data[pID] != null) && (data[pID].unit_access);
		$("#UpgradeColumn").visible = (data[pID] != null) && (data[pID].upgrade_access);

		$("#choice_marauder").visible = (data[pID] != null) && (data[pID].t2_access);
		$("#choice_reaper").visible = (data[pID] != null) && (data[pID].t2_access);
		$("#choice_knight").visible = (data[pID] != null) && (data[pID].t3_access);
		$("#choice_golem").visible = (data[pID] != null) && (data[pID].t3_access);

		$("#choice_economy_1").visible = (data[pID] != null) && (data[pID].economy_1);
		$("#choice_creeps_1").visible = (data[pID] != null) && (data[pID].creeps_1);
		$("#choice_nexus_1").visible = (data[pID] != null) && (data[pID].nexus_1);
		$("#choice_tech_1").visible = (data[pID] != null) && (data[pID].tech_1);
		$("#choice_economy_2").visible = (data[pID] != null) && (data[pID].economy_2);
		$("#choice_creeps_2").visible = (data[pID] != null) && (data[pID].creeps_2);
		$("#choice_nexus_2").visible = (data[pID] != null) && (data[pID].nexus_2);
		$("#choice_tech_2").visible = (data[pID] != null) && (data[pID].tech_2);
		$("#choice_creeps_3").visible = (data[pID] != null) && (data[pID].creeps_3);
	}

	if (key == "menu_cooldowns") {
		$("#choice_footman").style.saturation = (data[pID] != null && data[pID].footman) ? 0 : 1;
		$("#choice_archer").style.saturation = (data[pID] != null && data[pID].archer) ? 0 : 1;
		$("#choice_marauder").style.saturation = (data[pID] != null && data[pID].marauder) ? 0 : 1;
		$("#choice_reaper").style.saturation = (data[pID] != null && data[pID].reaper) ? 0 : 1;
		$("#choice_knight").style.saturation = (data[pID] != null && data[pID].knight) ? 0 : 1;
		$("#choice_golem").style.saturation = (data[pID] != null && data[pID].golem) ? 0 : 1;
	}

	if (key == "player_spheres") {
		let player_spheres = (data[pID] || 0)

		$("#SphereCount").text = parseInt(player_spheres);
		$("#label_footman").style.color = (player_spheres >= 100) ? "gold" : "white";
		$("#label_archer").style.color = (player_spheres >= 100) ? "gold" : "white";
		$("#label_marauder").style.color = (player_spheres >= 200) ? "gold" : "white";
		$("#label_reaper").style.color = (player_spheres >= 250) ? "gold" : "white";
		$("#label_knight").style.color = (player_spheres >= 500) ? "gold" : "white";
		$("#label_golem").style.color = (player_spheres >= 500) ? "gold" : "white";
		$("#label_economy_1").style.color = (player_spheres >= 300) ? "gold" : "white";
		$("#label_creeps_1").style.color = (player_spheres >= 300) ? "gold" : "white";
		$("#label_nexus_1").style.color = (player_spheres >= 400) ? "gold" : "white";
		$("#label_tech_1").style.color = (player_spheres >= 500) ? "gold" : "white";
		$("#label_economy_2").style.color = (player_spheres >= 400) ? "gold" : "white";
		$("#label_creeps_2").style.color = (player_spheres >= 600) ? "gold" : "white";
		$("#label_nexus_2").style.color = (player_spheres >= 700) ? "gold" : "white";
		$("#label_tech_2").style.color = (player_spheres >= 1000) ? "gold" : "white";
		$("#label_creeps_3").style.color = (player_spheres >= 800) ? "gold" : "white";
	}
}

function SummonUnit(unit) {
	GameEvents.SendCustomGameEventToServer("player_attempted_summon", {unit: unit});
}

function TryToUpgrade(upgrade) {
	GameEvents.SendCustomGameEventToServer("player_attempted_upgrade", {upgrade: upgrade});
}



const FindDotaHudElement = (id) => dotaHud.FindChildTraverse(id);

const dotaHud = (() => {
	let panel = $.GetContextPanel();
	while (panel) {
		if (panel.id === "DotaHud") return panel;
		panel = panel.GetParent();
	}
})();

const DOTA_SHOP = FindDotaHudElement("shop");

function ToggleShopVisibility() {
	$("#Container").SetHasClass("dota_shop_open", DOTA_SHOP.BHasClass("ShopOpen"));
}

$.RegisterEventHandler("PanelStyleChanged", DOTA_SHOP, ToggleShopVisibility);