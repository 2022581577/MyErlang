-ifndef(COMMON_HRL).
-define(COMMON_HRL,"common.hrl").


-define(CONFIG(Key), game_config:get_config(Key)).

-include("game.hrl").
-include("logger.hrl").
-include("ets.hrl").
-include("user.hrl").
-include("map.hrl").

-define(TRUE, true).
-define(FALSE, false).

-endif.
