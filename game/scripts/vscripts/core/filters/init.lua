Filters = Filters or {}

require("core/filters/damage")
require("core/filters/modifier")
require("core/filters/order")
require("core/filters/item")

function Filters:Init()
	local game_mode_entity = GameRules:GetGameModeEntity()

	game_mode_entity:SetModifierGainedFilter(Dynamic_Wrap(Filters, "ModifierFilter"), Filters)
	game_mode_entity:SetDamageFilter(Dynamic_Wrap(Filters, "DamageFilter"), Filters)
	game_mode_entity:SetExecuteOrderFilter(Dynamic_Wrap(Filters, "ExecuteOrderFilter"), Filters)
	game_mode_entity:SetItemAddedToInventoryFilter(Dynamic_Wrap(Filters, "ItemAddedToInventoryFilter"), Filters)
end