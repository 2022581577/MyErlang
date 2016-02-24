%% Generate by code robot @ binbinjnu@163.com>
%% All rights reserved
%% @desc 游戏内存数据库

-module(game_mmdb).

-include("common.hrl").
-include("record.hrl").

-export([
		init/0,
		get_user/1,
		get_user_item/1,
		get_guild/1,
		new_user_init_ets/1
		]).


init() ->
	ets:new(?ETS_USER,[{keypos,#user.user_id},named_table,public,set,{read_concurrency,true}]),
	ets:new(?ETS_USER_ITEM,[{keypos,1},named_table,public,set,{read_concurrency,true}]),
	ets:new(?ETS_GUILD,[{keypos,#guild.guild_id},named_table,public,set,{read_concurrency,true}]),
	ok.


get_user(Key) ->
	case ets:lookup(?ETS_USER, Key) of
		[#user{} = USER] ->
			USER;
		[] ->
			load_user(Key)
	end.

load_user(Key) ->
	 case edb_util:get_row(user, [{user_id, Key}]) of
		[] ->
			?WARNING("Data:~w Not Exit", [Key]),
			false;
		USER ->
			ets:insert(?ETS_USER, USER),
			USER
	end.

get_user_item(Key) ->
	case ets:lookup(?ETS_USER_ITEM, Key) of
		[{Key,USER_ITEM}] ->
			USER_ITEM;
		[] ->
			load_user_item(Key)
	end.

load_user_item(Key) ->
	USER_ITEM = edb_util:get_all(user_item, [{user_id, Key}]),
	USER_ITEM1 = [util:to_tuple([user_item | E]) || E <- USER_ITEM],
	ets:insert(?ETS_USER_ITEM,{Key,USER_ITEM1}),
	USER_ITEM1.

get_guild(Key) ->
	case ets:lookup(?ETS_GUILD, Key) of
		[#guild{} = GUILD] ->
			GUILD;
		[] ->
			false
	end.

%% @doc 新号初始化ets
new_user_init_ets(UserID) ->
	ets:insert(?ETS_USER_ITEM, {UserID, []}),
	ok.

