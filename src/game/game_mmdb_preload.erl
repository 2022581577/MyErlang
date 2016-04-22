%% Generate by code robot @ binbinjnu@163.com>
%% All rights reserved
%% @desc 游戏内存数据库预加载

-module(game_mmdb_preload).
-include("common.hrl").
-include("record.hrl").

-export([preload/0]).

preload() ->
	load_user(),
	load_guild(),
	ok.

load_user() ->
	USERLIST = edb_util:get_all(user),
	[begin
		USER1 = [util:to_tuple([user | E]) || E <- USER],
		game_mmdb:add_account_mapping(USER1#user.acc_name, USER1#user.user_id),
		ets:insert(?ETS_USER, USER1)
	end || USER <- USERLIST],
	ok.

load_guild() ->
	GUILDLIST = edb_util:get_all(guild),
	[begin
		GUILD1 = [util:to_tuple([guild | E]) || E <- GUILD],
		ets:insert(?ETS_GUILD, GUILD1)
	end || GUILD <- GUILDLIST],
	ok.

