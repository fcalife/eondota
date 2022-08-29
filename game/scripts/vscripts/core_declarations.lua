-- Link global modifiers
LinkLuaModifier("modifier_hero_base_state", "modifiers/hero_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_golem_base_state", "modifiers/golem_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dummy_state", "modifiers/modifier_dummy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_not_on_minimap", "modifiers/modifier_dummy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_speed_bonus", "modifiers/modifier_speed_bonus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_neutral_size", "modifiers/modifier_neutral_size", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_lane_creep_state", "modifiers/lane_creep_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tower_state", "modifiers/tower_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_respawning_tower_state", "modifiers/tower_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_treasure_state", "modifiers/treasure_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nexus_state", "modifiers/nexus_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nexus_state_debuff", "modifiers/nexus_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_knight_state", "modifiers/knight_state", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_damage_taken", "modifiers/shrine_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_base_state_aura", "modifiers/shrine_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_base_state", "modifiers/shrine_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_active", "modifiers/shrine_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_buff_arcane", "modifiers/shrine_buffs", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_buff_frenzy", "modifiers/shrine_buffs", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_buff_catastrophe", "modifiers/shrine_buffs", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_buff_ultimate", "modifiers/shrine_buffs", LUA_MODIFIER_MOTION_NONE)

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

IS_EXPERIMENTAL_MAP = GetMapName() == "eon_lane"



-- GAME DESIGN CONSTANTS

GAME_MAX_DURATION = 900			-- Time after which the game will end in favor of the team with the highest score
GAME_END_WARNING_TIME = 30		-- Time before the game's end for it to start being counted down to
GAME_TARGET_SCORE = 5			-- Score a team needs to achieve in order to end the game before the time limit

NEUTRAL_CREEP_FIRST_SPAWN_TIME = IsInToolsMode() and 1 or 20
NEUTRAL_CREEP_RESPAWN_TIME = 60

GOLD_SHARING_RADIUS = 1200
GOLD_COIN_DURATION = 30

BOUNTY_RUNE_BASE_GOLD = 75			-- Base gold granted to the whole team when picking up a bounty rune
BOUNTY_RUNE_GOLD_PER_SECOND = 0.25	-- Amount by which the above increases every second
BOUNTY_RUNE_BASE_EXP = 0			-- Base experience granted to the whole team when picking up a bounty rune
BOUNTY_RUNE_EXP_PER_SECOND = 0		-- Amount by which the above increases every second
BOUNTY_RUNE_SPAWN_INTERVAL = 60		-- Time between two consecutive bounty rune spawns

PATROL_GOLEM_AGGRO_RANGE = 1000		-- Maximum distance at which the patrol golems will "see" and attack enemy players

DRAGON_BUFF_DURATION = 60
DRAGON_SPAWN_TIME = IsInToolsMode() and 3 or 180
DRAGON_RESPAWN_TIME = IsInToolsMode() and 10 or 180

ROSHAN_GOLD_BOUNTY = 200

TREASURE_GOLD_PER_HIT = 1
TOWER_RESPAWN_TIME = 60

SHRINE_CAPTURE_ZONE_RADIUS = 500
SHRINE_CAPTURE_TIME = 5
SHRINE_COOLDOWN_TIME = 30

OBJECTIVE_CAPTURE_TIME = 10

EON_STONE_SCORE = 1											-- How many points an eon stone is worth when delivered to the enemy goal
EON_STONE_FIRST_SPAWN_TIME = (IsInToolsMode() and 0) or (IS_EXPERIMENTAL_MAP and 180 or 35)	-- How long does it take for the first eon stone to spawn
EON_STONE_RESPAWN_TIME = 120								-- How long does it take for each subsequent eon stone to spawn
EON_STONE_COUNTDOWN_TIME = 15								-- How long does it take for the eon stone to spawn after it is announced to players
EON_STONE_VISION_RADIUS = 750								-- How much vision each eon stone gives to both teams around itself when dropped on the ground
EON_STONE_GOAL_RADIUS = 750									-- How big is the radius of both teams' goals
EON_STONE_GOLD_REWARD = 150

EON_STONE_NEXUS_DAMAGE = 0.2

EON_STONE_MIN_THROW_DISTANCE = 500			-- Maximum distance the stone travels when thrown
EON_STONE_MAX_THROW_DISTANCE = 1300			-- Maximum distance the stone travels when thrown
EON_STONE_THROW_DURATION = 1.0				-- Time the stone stays in the air when being thrown