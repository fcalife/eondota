-- Link global modifiers
LinkLuaModifier("modifier_hero_base_state", "modifiers/hero_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dummy_state", "modifiers/modifier_dummy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_not_on_minimap", "modifiers/modifier_dummy", LUA_MODIFIER_MOTION_NONE)

-- game states
GAME_STATE_INIT 	   			= 0
GAME_STATE_BATTLE				= 1
GAME_STATE_END					= 2

-- team states
TEAM_STATE_INACTIVE			    = 0

-- Player states
PLAYER_STATE_INACTIVE			= 0
PLAYER_STATE_WAITING_FOR_HERO	= 1
PLAYER_STATE_ACTIVE		 		= 2
PLAYER_STATE_ELIMINATED	 		= 3
PLAYER_STATE_ABANDONED	 		= 4

GAME_MAX_DURATION = 1200		-- 20 minutes
GAME_TARGET_SCORE = 50

EON_STONE_SCORE = 20
EON_STONE_SPAWN_TIME = 300		-- 5 minutes
EON_STONE_COUNTDOWN_TIME = 15
EON_STONE_GOAL_RADIUS = 260