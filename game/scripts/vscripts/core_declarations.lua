-- Link global modifiers
LinkLuaModifier("modifier_hero_base_state", "modifiers/hero_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_golem_base_state", "modifiers/golem_base_state", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_speed_bonus", "modifiers/modifier_speed_bonus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dummy_state", "modifiers/modifier_dummy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_not_on_minimap", "modifiers/modifier_dummy", LUA_MODIFIER_MOTION_NONE)

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



-- GAME DESIGN CONSTANTS

GAME_MAX_DURATION = 900			-- Time after which the game will end in favor of the team with the highest score
GAME_END_WARNING_TIME = 30		-- Time before the game's end for it to start being counted down to
GAME_TARGET_SCORE = 50			-- Score a team needs to achieve in order to end the game before the time limit

BOUNTY_RUNE_BASE_GOLD = 200			-- Base gold granted to the whole team when picking up a bounty rune
BOUNTY_RUNE_GOLD_PER_SECOND = 1		-- Amount by which the above increases every second
BOUNTY_RUNE_BASE_EXP = 200			-- Base experience granted to the whole team when picking up a bounty rune
BOUNTY_RUNE_EXP_PER_SECOND = 2		-- Amount by which the above increases every second
BOUNTY_RUNE_SPAWN_INTERVAL = 45		-- Time between two consecutive bounty rune spawns

PATROL_GOLEM_AGGRO_RANGE = 900

EON_STONE_SCORE = 7											-- How many points an eon stone is worth when delivered to the enemy goal
EON_STONE_FIRST_SPAWN_TIME = (IsInToolsMode() and 0) or 60	-- How long does it take for the first eon stone to spawn
EON_STONE_RESPAWN_TIME = 180								-- How long does it take for each subsequent eon stone to spawn
EON_STONE_COUNTDOWN_TIME = 15								-- How long does it take for the eon stone to spawn after it is announced to players
EON_STONE_VISION_RADIUS = 750								-- How much vision each eon stone gives to both teams around itself when dropped on the ground
EON_STONE_GOAL_RADIUS = 240									-- How big is the radius of both teams' goals

EON_STONE_THROW_DISTANCE = 1000			-- Maximum distance the stone travels when thrown
EON_STONE_THROW_SPEED = 800				-- Speed the stone travels at when being thrown
EON_STONE_CATCH_RADIUS = 80				-- Radius of the stone's "hitbox" while flying
EON_STONE_CATCH_COOLDOWN = 1.0			-- Time a player must wait to throw the stone again after a successful catch