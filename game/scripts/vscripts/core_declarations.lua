-- Link global modifiers
LinkLuaModifier("modifier_hero_base_state", "modifiers/hero_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_thrown_out", "modifiers/hero_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_respawn_grace_period", "modifiers/hero_base_state", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_golem_base_state", "modifiers/golem_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_golem_disabled_counter", "modifiers/golem_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dummy_state", "modifiers/modifier_dummy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_not_on_minimap", "modifiers/modifier_dummy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_speed_bonus", "modifiers/modifier_speed_bonus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_neutral_size", "modifiers/modifier_neutral_size", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_score_taunt", "modifiers/score_taunt", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_portal_teleporting", "modifiers/portal_buffs", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_portal_cooldown", "modifiers/portal_buffs", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_treasure_goblin_state", "modifiers/treasure_goblin_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lane_creep_state", "modifiers/lane_creep_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tower_state", "modifiers/tower_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jungle_tower_shield", "modifiers/tower_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_respawning_tower_state", "modifiers/tower_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tower_damage_up", "modifiers/tower_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_treasure_state", "modifiers/treasure_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nexus_state", "modifiers/nexus_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_knight_state", "modifiers/knight_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_samurai_state", "modifiers/knight_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_knight_nexus_debuff", "modifiers/knight_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_knight_state_blue", "modifiers/knight_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_knight_state_green", "modifiers/knight_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_knight_state_red", "modifiers/knight_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_portal_creep_state", "modifiers/portal_creep", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_portal_caster_state", "modifiers/portal_caster_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cart_objective_state", "modifiers/cart_objective_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cart_state", "modifiers/cart_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jungle_attacker", "modifiers/jungle_attacker", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_damage_taken", "modifiers/shrine_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_base_state_aura", "modifiers/shrine_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_base_state", "modifiers/shrine_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_active", "modifiers/shrine_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_buff_arcane", "modifiers/shrine_buffs", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_buff_frenzy", "modifiers/shrine_buffs", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_buff_catastrophe", "modifiers/shrine_buffs", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_buff_ultimate", "modifiers/shrine_buffs", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_objective_buff", "modifiers/objective_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stealth_prevention", "modifiers/stealth_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_minor_stealth_buff", "modifiers/stealth_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_major_stealth_buff", "modifiers/stealth_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_major_stealth_buff_detect", "modifiers/stealth_buff", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_goblin_item_tracker", "modifiers/goblin_item_tracker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wall_blocker", "modifiers/wall_blocker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ignore_wall", "modifiers/wall_blocker", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_brush_transparency", "modifiers/brush", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_brush_invisibility", "modifiers/brush", LUA_MODIFIER_MOTION_NONE)

-- GAME STATE CONSTANTS

GAME_STATE_INIT 	   			= 0
GAME_STATE_BATTLE				= 1
GAME_STATE_END					= 2

TEAM_STATE_INACTIVE			    = 0

PLAYER_STATE_INACTIVE			= 0
PLAYER_STATE_WAITING_FOR_HERO	= 1
PLAYER_STATE_ACTIVE		 		= 2
PLAYER_STATE_ELIMINATED	 		= 3
PLAYER_STATE_ABANDONED	 		= 4



-- GAME DESIGN CONSTANTS
FOG_OF_WAR_DISABLED = true
ENABLE_ULTIMATES = false

ROUNDS_TO_WIN = 5
MIN_ROUND_FOR_ULTIMATES = 3

RED_BUFF_DURATION = 30
GREEN_BUFF_DURATION = 30

TOWER_KILL_GOLD = 500
FLAG_DELIVERY_GOLD = 500
ROUND_WIN_GOLD = 1000

WALL_ACTIVATION_DELAY = 30
WALL_SLIDE_TIME = 60
WALL_MIN_HEIGHT = 100

CAMERA_LOCK = true

MAX_CAST_RADIUS = 1175
INITIAL_CIRCLE_RADIUS = 1550
CIRCLE_DELAY = 20
CIRCLE_SLIDE_TIME = 60
FINAL_CIRCLE_RADIUS = 375

ROUND_PREPARATION_TIME = (IsInToolsMode() and 1) or 10
INITIAL_LIVES = 3
SMASH_BROS_LIVES = 5
SMASH_BROS_GRACE_PERIOD = 4
SMASH_BROS_MODE = false
EXPERIMENTAL_POWERUPS = false