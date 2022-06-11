-- Link global modifiers
--LinkLuaModifier("modifier_auto_attack",			    "libraries/modifiers/modifier_auto_attack", LUA_MODIFIER_MOTION_NONE)

-- game states
GAME_STATE_INITIALIZATION 	    = 0

-- team states
TEAM_STATE_INACTIVE			    = 0

-- Player states
PLAYER_STATE_INACTIVE			= 0
PLAYER_STATE_WAITING_FOR_HERO	= 1
PLAYER_STATE_ACTIVE		 		= 2
PLAYER_STATE_ELIMINATED	 		= 3
PLAYER_STATE_ABANDONED	 		= 4

EON_STONE_TARGET = {}
EON_STONE_TARGET[DOTA_TEAM_GOODGUYS] = Vector(6944, 2800, 256)
EON_STONE_TARGET[DOTA_TEAM_BADGUYS] = Vector(-6944, -5408, 256)