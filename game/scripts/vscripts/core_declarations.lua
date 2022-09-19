-- Link global modifiers
LinkLuaModifier("modifier_hero_base_state", "modifiers/hero_base_state", LUA_MODIFIER_MOTION_NONE)
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

LinkLuaModifier("modifier_damage_taken", "modifiers/shrine_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_base_state_aura", "modifiers/shrine_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_base_state", "modifiers/shrine_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_active", "modifiers/shrine_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_buff_arcane", "modifiers/shrine_buffs", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_buff_frenzy", "modifiers/shrine_buffs", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_buff_catastrophe", "modifiers/shrine_buffs", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_buff_ultimate", "modifiers/shrine_buffs", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_objective_buff", "modifiers/objective_buff", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_goblin_item_tracker", "modifiers/goblin_item_tracker", LUA_MODIFIER_MOTION_NONE)

-- GAME STATE CONSTANTS

GAME_STATE_INIT 	   			= 0
GAME_STATE_BATTLE				= 1
GAME_STATE_END_TIMER			= 2
GAME_STATE_END					= 3

TEAM_STATE_INACTIVE			    = 0

PLAYER_STATE_INACTIVE			= 0
PLAYER_STATE_WAITING_FOR_HERO	= 1
PLAYER_STATE_ACTIVE		 		= 2
PLAYER_STATE_ELIMINATED	 		= 3
PLAYER_STATE_ABANDONED	 		= 4

IS_CART_MAP = GetMapName() == "eon_lane_experimental"
IS_LANE_MAP = GetMapName() == "eon_lane" or GetMapName() == "eon_lane_experimental"
IS_EXPERIMENTAL_MAP = GetMapName() == "eon_lane_experimental"



-- GAME DESIGN CONSTANTS

GAME_MAX_DURATION = 900			-- Time after which the game will end in favor of the team with the highest score
GAME_END_WARNING_TIME = 30		-- Time before the game's end for it to start being counted down to
GAME_TARGET_SCORE = 5			-- Score a team needs to achieve in order to end the game before the time limit

NEUTRAL_CREEP_FIRST_SPAWN_TIME = IsInToolsMode() and 0 or 0
NEUTRAL_CREEP_RESPAWN_TIME = IsInToolsMode() and 3 or 60
NEUTRAL_CREEP_SCALING_LIMIT = IsInToolsMode() and 1 or 25

GOLD_SHARING_RADIUS = 1200
GOLD_COIN_DURATION = 7

BOUNTY_RUNE_BASE_GOLD = 75			-- Base gold granted to the whole team when picking up a bounty rune
BOUNTY_RUNE_GOLD_PER_SECOND = 0.25	-- Amount by which the above increases every second
BOUNTY_RUNE_BASE_EXP = 0			-- Base experience granted to the whole team when picking up a bounty rune
BOUNTY_RUNE_EXP_PER_SECOND = 0		-- Amount by which the above increases every second
BOUNTY_RUNE_SPAWN_INTERVAL = 60		-- Time between two consecutive bounty rune spawns

PATROL_GOLEM_AGGRO_RANGE = 1000		-- Maximum distance at which the patrol golems will "see" and attack enemy players

DRAGON_BUFF_DURATION = 60
DRAGON_SPAWN_TIME = IsInToolsMode() and 3 or 180
DRAGON_RESPAWN_TIME = IsInToolsMode() and 10 or 180
DRAGON_MAX_KILLS = 3

ROSHAN_GOLD_BOUNTY = 200

TREASURE_GOLD_PER_HIT = 1
TOWER_RESPAWN_TIME = 60
TOWER_KILL_GOLD = 100
TOWER_MAX_DAMAGE_STACKS = 3

SHRINE_INITIAL_SPAWN_DELAY = IsInToolsMode() and 3 or 20
SHRINE_CAPTURE_ZONE_RADIUS = 500
SHRINE_CAPTURE_TIME = 5
SHRINE_ACTIVE_TIME = 60
SHRINE_COOLDOWN_TIME = 60

CART_INITIAL_SPAWN_DELAY = IsInToolsMode() and 3 or 180
CART_COUNTDOWN_TIME = IsInToolsMode() and 1 or 15

OBJECTIVE_CAPTURE_TIME = 10

SECONDARY_CAPTURE_TIME = 10
SECONDARY_CAPTURE_RADIUS = 275
SECONDARY_CAPTURE_GOLD = 100
SECONDARY_CAPTURE_DURATION = 60
SECONDARY_CAPTURE_SPAWN_TIME = 60
SECONDARY_NEXUS_DAMAGE = 0.08

CATASTROPHE_BUFF_DURATION = 15
DEMON_BUFF_DURATION = 60

EON_STONE_FIRST_SPAWN_TIME = 180
if IS_CART_MAP then EON_STONE_FIRST_SPAWN_TIME = 210 end
if IsInToolsMode() then EON_STONE_FIRST_SPAWN_TIME = 0 end

EON_STONE_SCORE = 1											-- How many points an eon stone is worth when delivered to the enemy goal
EON_STONE_RESPAWN_TIME = 120								-- How long does it take for each subsequent eon stone to spawn
EON_STONE_COUNTDOWN_TIME = 15								-- How long does it take for the eon stone to spawn after it is announced to players
EON_STONE_VISION_RADIUS = 750								-- How much vision each eon stone gives to both teams around itself when dropped on the ground
EON_STONE_GOAL_RADIUS = 750									-- How big is the radius of both teams' goals
EON_STONE_GOLD_REWARD = 200
EON_STONE_TIME_ON_GROUND = 15

EON_STONE_NEXUS_DAMAGE = 0.2

EON_STONE_MIN_THROW_DISTANCE = 500			-- Maximum distance the stone travels when thrown
EON_STONE_MAX_THROW_DISTANCE = 1300			-- Maximum distance the stone travels when thrown
EON_STONE_THROW_DURATION = 1.0				-- Time the stone stays in the air when being thrown

SPEED_BUFF_DURATION = 30