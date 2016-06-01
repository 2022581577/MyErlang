#!/usr/bin/env escript
%%% @author : kongqingquan <kqqsysu@gmail.com>

-mode(compile).

-include("../include/old/generation.hrl").

main(_Args) ->
    Name = "game_mmdb_preload",
    Str = get_header(Name) ++ fun_load_data() ++ fun_prelaod(),
    FileName = Name ++ ".erl",
    ?WRITE_FILE(FileName,Str),
    ok.

%% @doc 头信息
get_header(Mod) ->
    ?COPYRIGHT
    ?DESC("游戏内存数据库预加载")
    "-module(" ++ Mod ++ ").\n"
    "-include(\"common.hrl\").\n"
    "-include(\"record.hrl\").\n\n"
    "-export([preload/0]).\n\n".

fun_load_data() ->
    "preload() ->\n" ++
    lists:foldl(fun(#durable_record{name = Name, record_list = RecordList, is_preload = IsPreload},AccIn) ->
                    case IsPreload of
                        true when not RecordList ->
                            AccIn ++ "\tload_" ++ atom_to_list(Name) ++ "(),\n";
                        false ->
                            AccIn
                    end
                end,"",?DURABLE_RECORD_LIST) ++
    "\tok.\n\n".

%%fun_load_user() ->
%%    "%% @doc 加载玩家数据\n"
%%    "load_user() ->\n"
%%    "\t[begin\n"
%%    "\t\tgame_mmdb:add_account_mapping(AccName,UserID)\n"
%%    "\tend || #user_status{user_id = UserID, acc_name = AccName} <- "
%%    "\tMaxUserID = \n"
%%    "\tets:foldl(fun(#user_status{user_id = UserID,name = Name,acc_name = AccountName},AccIn) ->\n"
%%    "\t\t\t\t%% 帐号名称映射\n"
%%    "\t\t\t\tgame_mmdb:add_account_mapping(AccountName,UserID),\n"
%%    "\t\t\t\t%% 名称ID映射\n"
%%    "\t\t\t\tets:insert(?ETS_USER_NAME,#name_info{name = Name,user_id = UserID}),\n"
%%    "\t\t\t\t%% ID名称映射\n"
%%    "\t\t\t\tets:insert(?ETS_USER_ID, #uid_info{user_id = UserID, name = Name})\n"
%%    "\t\t\tend,0,?ETS_USER_STATUS),\n"
%%    "\tlib_counter:init_user_id(MaxUserID),\n"
%%	"\tok.\n".

fun_prelaod() ->
    fun_prelaod(?DURABLE_RECORD_LIST,"").
fun_prelaod([#durable_record{is_preload = true,name = Name,is_user = false} | T],AccIn) ->
    RecordName = atom_to_list(Name),
    EtsName = ?ETS_RECORD_NAME(Name),
    Var = string:to_upper(atom_to_list(Name)),
    Var1 = Var ++ "1",
    VarList = Var ++ string:to_upper("list"),

    AccIn1 =  
        AccIn ++
        "load_" ++ RecordName ++"() ->\n"
        "\t" ++ VarList ++ " = edb_util:get_all(" ++ RecordName ++ "),\n"
        "\t[begin\n"
        "\t\t" ++ Var1 ++ " = [util:to_tuple([" ++ RecordName ++ " | E]) || E <- "  ++ Var ++ "],\n"
        "\t\tets:insert(" ++ EtsName ++ ", " ++ Var1 ++ ")\n"
        "\tend || " ++ Var ++  " <- " ++ VarList ++ "],\n"
        "\tok.\n\n",
    fun_prelaod(T, AccIn1);
fun_prelaod([#durable_record{is_preload = true, name = Name, is_user = true} | T],AccIn) ->
    RecordName = atom_to_list(Name),
    EtsName = ?ETS_RECORD_NAME(Name),
    Var = string:to_upper(atom_to_list(Name)),
    Var1 = Var ++ "1",
    VarList = Var ++ string:to_upper("list"),

    AccIn1 =  
        AccIn ++
        "load_" ++ RecordName ++"() ->\n"
        "\t" ++ VarList ++ " = edb_util:get_all(" ++ RecordName ++ "),\n"
        "\t[begin\n"
        "\t\t" ++ Var1 ++ " = [util:to_tuple([" ++ RecordName ++ " | E]) || E <- "  ++ Var ++ "],\n"
         ++ case Name of
                user -> "\t\tgame_mmdb:add_account_mapping(" ++ Var1 ++ "#user.acc_name, " ++ Var1 ++ "#user.user_id),\n";
                _ ->    ""
            end ++
        "\t\tets:insert(" ++ EtsName ++ ", " ++ Var1 ++ ")\n"
        "\tend || " ++ Var ++  " <- " ++ VarList ++ "],\n"
        "\tok.\n\n",

    fun_prelaod(T, AccIn1);
fun_prelaod([_H | T],AccIn) ->
    fun_prelaod(T,AccIn);
fun_prelaod([],AccIn) ->
    AccIn.

