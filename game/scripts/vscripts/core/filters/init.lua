Filters = Filters or {}

require("core/filters/damage")
--require("core/filters/modifier")
require("core/filters/item")
require("core/filters/gold_exp")
require("core/filters/order")

function Filters:Init()
	local game_mode_entity = GameRules:GetGameModeEntity()

	--game_mode_entity:SetModifierGainedFilter(Dynamic_Wrap(Filters, "ModifierFilter"), Filters)
	game_mode_entity:SetDamageFilter(Dynamic_Wrap(Filters, "DamageFilter"), Filters)
	game_mode_entity:SetItemAddedToInventoryFilter(Dynamic_Wrap(Filters, "InventoryFilter"), Filters)
	game_mode_entity:SetModifyGoldFilter(Dynamic_Wrap(Filters, "GoldFilter"), Filters)
	game_mode_entity:SetModifyExperienceFilter(Dynamic_Wrap(Filters, "ExpFilter"), Filters)
	game_mode_entity:SetExecuteOrderFilter(Dynamic_Wrap(Filters, "OrderFilter"), Filters)
end