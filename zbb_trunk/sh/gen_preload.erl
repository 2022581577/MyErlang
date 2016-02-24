#!/usr/bin/env escript
%%% @author : kongqingquan <kqqsysu@gmail.com>

-mode(compile).

-include("../include/common.hrl").
-include("../include/generation.hrl").

main(_Args) ->
    Name = "lib_ets_preload",
    Str = get_header(Name) ++ fun_load_data() ++ fun_load_user() ++ fun_prelaod(),
    FileName = Name ++ ".erl",
    ?WRITE_FILE(FileName,Str),
    ok.

%% @doc 头信息
get_header(Mod) ->
    ?COPYRIGHT
    "-module(" ++ Mod ++ ").\n"
    "-include(\"common.hrl\").\n"
    "-include(\"record.hrl\").\n\n"
    "-export([load_data/0]).\n\n".

fun_load_data() ->
    "load_data() ->\n" ++
    lists:foldl(fun(#durable_record{name = Name,is_preload = IsPreload,is_user_preload = IsUserPreload,is_user = IsUser},AccIn) ->
                    case IsPreload orelse (IsUserPreload == true  andalso IsUser == true) of
                        true ->
                            AccIn ++ "\tload_" ++ atom_to_list(Name) ++ "(),\n";
                        false ->
                            AccIn
                    end
                end,"",?DURABLE_RECORD_LIST) ++
    "\tok.\n\n".

fun_load_user() ->
    "%% @doc 加载玩家数据\n"
    "load_user() ->\n"
    "\tMaxUserID = \n"
    "\tets:foldl(fun(#user_status{user_id = UserID,name = Name,account_name = AccountName},AccIn) ->\n"
    "\t\t\t\t%% 帐号名称映射\n"
    "\t\t\t\tlib_ets:add_account_mapping(AccountName,UserID),\n"
    "\t\t\t\t%% 名称ID映射\n"
    "\t\t\t\tets:insert(?ETS_USER_NAME,#name_info{name = Name,user_id = UserID}),\n"
    "\t\t\t\t%% ID名称映射\n"
    "\t\t\t\tets:insert(?ETS_USER_ID, #uid_info{user_id = UserID, name = Name}),\n"
    "\t\t\t\tmax(AccIn,UserID)\n"
    "\t\t\tend,0,?ETS_USER_STATUS),\n"
    "\tlib_counter:init_user_id(MaxUserID),\n"
	"\tok.\n".

fun_prelaod() ->
    fun_prelaod(?DURABLE_RECORD_LIST,"").
fun_prelaod([#durable_record{is_preload = true,name = pay_info,is_user = false} | T],AccIn) ->
    Name = pay_info,
    RecordName = atom_to_list(Name),
    EtsName = ?ETS_RECORD_NAME(Name),
    Var = string:to_upper(atom_to_list(Name)),
    NewAccIn =
    AccIn ++
    "load_" ++ RecordName ++"() ->\n"
    "\t?INFO(\"Loading "++ RecordName ++"\"),\n"
    "\tL = db_agent_" ++ RecordName ++ ":find_" ++ RecordName ++ "(),\n"
    "\tdo_init_" ++ RecordName ++"(L),\n"
    "\t?INFO(\"Load " ++ RecordName ++ " Finish\").\n\n"
    ++ fun_do_init(RecordName, Var, EtsName),

    fun_prelaod(T,NewAccIn);
fun_prelaod([#durable_record{is_preload = true,name = Name,is_user = false} | T],AccIn) ->
    RecordName = atom_to_list(Name),
    EtsName = ?ETS_RECORD_NAME(Name),
    DetsName = ?DETS_RECORD_NAME(Name),
    Var = string:to_upper(atom_to_list(Name)),
    NewAccIn =
    AccIn ++
    "load_" ++ RecordName ++"() ->\n"
    "\t?INFO(\"Loading "++ RecordName ++"\"),\n"
    "\tdets:to_ets(" ++ DetsName ++ "," ++ EtsName ++ "),\n" ++ 
    case Name of
        guild_user_list ->
            "\tets:delete(" ++ EtsName ++ ",?RECORD_FILES_NAME),\n"
            "\tets:delete(" ++ EtsName ++ ",?RECORD_FILES_NAME_2),\n";
        guild_request_list ->
            "\tets:delete(" ++ EtsName ++ ",?RECORD_FILES_NAME),\n"
            "\tets:delete(" ++ EtsName ++ ",?RECORD_FILES_NAME_2),\n";
        _ ->
            "\tets:delete(" ++ EtsName ++ ",?RECORD_FILES_NAME),\n"
    end ++
    "\tcase ets:info(" ++ EtsName ++ ", size) of\n"
    "\t\t0 ->\n"
    "\t\t\tL = db_agent_" ++ RecordName ++ ":find_" ++ RecordName ++ "(),\n"
    "\t\t\tdo_init_" ++ RecordName ++"(L),\n"
    "\t\t\tok;\n"
    "\t\t_ ->\n"
    "\t\t\tskip\n"
    "\tend,\n"
    "\t?INFO(\"Load " ++ RecordName ++ " Finish\").\n\n"
    ++ fun_do_init(RecordName, Var, EtsName),

    fun_prelaod(T,NewAccIn);
fun_prelaod([#durable_record{ is_user_preload = true,name = Name,is_user = true} | T],AccIn) ->
    RecordName = atom_to_list(Name),
    EtsName = ?ETS_RECORD_NAME(Name),
    DetsName = ?DETS_RECORD_NAME(Name),
    Var = string:to_upper(atom_to_list(Name)),

    %% 从mongo中加载
    AccIn2 =  AccIn ++
    "load_" ++ RecordName ++"() ->\n"
    "\tL = db_agent_" ++ RecordName ++ ":find_" ++ RecordName ++ "(),\n"
    "\tdo_init_" ++ RecordName ++"(L),\n",

    %% 把dets中的数据替换现有列表
    AccIn3 = AccIn2 ++
    "\tutil:dets_foldl(fun(T,DetsAccIn) ->\n"
    "\t\t\t\t\t\tcase T of\n"
    "\t\t\t\t\t\t\t#" ++ RecordName ++ "{} ->\n"
    "\t\t\t\t\t\t\t\tets:insert(" ++ EtsName ++ ",T),\n"
    "\t\t\t\t\t\t\t\tDetsAccIn;\n"
    "\t\t\t\t\t\t\t#record_files{} ->\n"
    "\t\t\t\t\t\t\t\tDetsAccIn\n"
    "\t\t\t\t\t\tend\n"
    "\t\t\t\t\tend,ok," ++ DetsName ++ "),\n" ++
    case Name of
        user_status ->
            "\tload_user(),\n";
        _ ->
            ""
    end ++
    "\t?INFO(\"Load " ++ RecordName ++ " Finish\").\n\n"
    ++ fun_do_init(RecordName, Var, EtsName),

    fun_prelaod(T,AccIn3);
fun_prelaod([_H | T],AccIn) ->
    fun_prelaod(T,AccIn);
fun_prelaod([],AccIn) ->
    AccIn.

fun_do_init(RecordName, Var, EtsName) ->
    "do_init_" ++ RecordName ++ "([H | T]) ->\n" ++
    case list_to_atom(RecordName) of
        guild_user_list ->
            "\t"++ Var ++" = H,\n";
        guild_request_list ->
            "\t"++ Var ++" = H,\n";
        rank ->
            "\t"++ Var ++" = H,\n";
        _ ->
            "\t" ++ Var ++ " = mongo_tool:gen_record(?RECORD_FIELDS(" ++ RecordName ++ "), H, #" ++ RecordName ++ "{}),\n"
    end ++
    "\tets:insert(" ++ EtsName ++ "," ++ Var ++ "),\n"
    "\tdo_init_" ++ RecordName ++ "(T);\n"
    "do_init_" ++ RecordName ++ "([]) ->\n"
    "\tship.\n\n".
