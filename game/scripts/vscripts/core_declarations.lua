-- Link global modifiers
LinkLuaModifier("modifier_hero_base_state", "modifiers/hero_base_state", LUA_MODIFIER_MOTION_NONE)

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

GAME_MAX_DURATION = 1200	-- 20 minutes

EON_STONE_RESPAWN_TIME = 15
MAX_EON_STONES = 5