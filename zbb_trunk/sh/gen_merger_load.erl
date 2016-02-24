#!/usr/bin/env escript
%%% @author : yaoyang <air_time126.com>

-mode(compile).

-include("../include/common.hrl").
-include("../include/generation.hrl").

main(_Args) ->
    Name = "lib_merger_load",
    Str = get_header(Name) ++ fun_load_data() ++ fun_preload(),
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
    %"\tload_user(),\n" ++
    lists:foldl(fun(#durable_record{name = Name, is_merger=IsMerger},AccIn) ->
                case IsMerger of
                    false ->
                        AccIn;
                    _ ->
                        case Name of
                            guild ->
                                AccIn;
                            guild_user_list ->
                                AccIn;
                            guild_request_list ->
                                AccIn;
                            rank ->
                                AccIn;
                            _ ->
                                AccIn ++ "\tload_" ++ atom_to_list(Name) ++ "(),\n"
                        end
                end
                end,"",?DURABLE_RECORD_LIST) ++
    "\tok.\n\n".

fun_preload() ->
    fun_preload(?DURABLE_RECORD_LIST,"").
fun_preload([#durable_record{is_merger=false} | T], AccIn) ->
    fun_preload(T,AccIn);
fun_preload([#durable_record{name=guild} | T], AccIn) ->
    fun_preload(T, AccIn);
fun_preload([#durable_record{name=guild_user_list} | T], AccIn) ->
    fun_preload(T, AccIn);
fun_preload([#durable_record{name=guild_request_list} | T], AccIn) ->
    fun_preload(T, AccIn);
fun_preload([#durable_record{name=rank} | T], AccIn) ->
    fun_preload(T, AccIn);
fun_preload([#durable_record{name=Name,keypos=KeyPos,record_list=true} | T], AccIn) when is_integer(KeyPos) ->
    RecordName = atom_to_list(Name),
    EtsName = ?ETS_RECORD_NAME(Name),
    %DetsName = ?DETS_RECORD_NAME(Name),
    Var = string:to_upper(atom_to_list(Name)),
    NewAccIn =
    AccIn ++
    "load_" ++ RecordName ++"() ->\n"
    "\t?INFO(\"Loading "++ RecordName ++"\"),\n"
    "\tL = db_agent_" ++ RecordName ++ ":find_" ++ RecordName ++ "(),\n"
    "\tdo_init_" ++ RecordName ++"(L),\n"
    "\tets:delete(" ++ EtsName ++ ",?RECORD_FILES_NAME),\n"
    "\t?INFO(\"Load " ++ RecordName ++ " Finish\").\n\n"
    ++ 
    fun_user_do_init3(RecordName, Var, EtsName),
    
    fun_preload(T, NewAccIn);
fun_preload([#durable_record{is_preload=true,name = mail_item} | T],AccIn) ->
    Name = mail_item,
    RecordName = atom_to_list(Name),
    EtsName = ?ETS_RECORD_NAME(Name),
    Var = string:to_upper(atom_to_list(Name)),
    NewAccIn =
    AccIn ++
    "load_" ++ RecordName ++"() ->\n"
    "\t?INFO(\"Loading "++ RecordName ++"\"),\n"
    "\tets:delete(" ++ EtsName ++ ",?RECORD_FILES_NAME),\n"

    "\tL = db_agent_" ++ RecordName ++ ":find_" ++ RecordName ++ "(),\n"
    "\tdo_init_" ++ RecordName ++"(L),\n"
    "\t?INFO(\"Load " ++ RecordName ++ " Finish\").\n\n"
    ++ fun_check_del_do_init(RecordName, Var, EtsName, Name),

    fun_preload(T, NewAccIn);
fun_preload([#durable_record{is_preload=true,name = Name} | T],AccIn) ->
    RecordName = atom_to_list(Name),
    EtsName = ?ETS_RECORD_NAME(Name),
    %DetsName = ?DETS_RECORD_NAME(Name),
    Var = string:to_upper(atom_to_list(Name)),
    NewAccIn =
    AccIn ++
    "load_" ++ RecordName ++"() ->\n"
    "\t?INFO(\"Loading "++ RecordName ++"\"),\n"
    %"\tdets:to_ets(" ++ DetsName ++ "," ++ EtsName ++ "),\n"
    "\tets:delete(" ++ EtsName ++ ",?RECORD_FILES_NAME),\n"
    %"\tcase dets:info(" ++ DetsName ++ ", size) =< 1 of\n"
    %"\t\ttrue ->\n"
    "\tL = db_agent_" ++ RecordName ++ ":find_" ++ RecordName ++ "(),\n"
    "\tdo_init_" ++ RecordName ++"(L),\n"
    %"\t\t\tok;\n"
    %"\t\tfalse ->\n"
    %"\t\t\tskip\n"
    %"\tend,\n"
    "\t?INFO(\"Load " ++ RecordName ++ " Finish\").\n\n"
    ++ fun_do_init(RecordName, Var, EtsName),

    fun_preload(T,NewAccIn);
fun_preload([#durable_record{name=Name,keypos=user_id} | T], AccIn) ->
    RecordName = atom_to_list(Name),
    EtsName = ?ETS_RECORD_NAME(Name),
    %DetsName = ?DETS_RECORD_NAME(Name),
    Var = string:to_upper(atom_to_list(Name)),
    NewAccIn =
    AccIn ++
    "load_" ++ RecordName ++"() ->\n"
    "\t?INFO(\"Loading "++ RecordName ++"\"),\n"
    "\tL = db_agent_" ++ RecordName ++ ":find_" ++ RecordName ++ "(),\n"
    "\tdo_init_" ++ RecordName ++"(L),\n"
    "\tets:delete(" ++ EtsName ++ ",?RECORD_FILES_NAME),\n"
    "\t?INFO(\"Load " ++ RecordName ++ " Finish\").\n\n"
    ++ fun_check_del_do_init(RecordName, Var, EtsName, Name),
    
    fun_preload(T, NewAccIn);
    

fun_preload([#durable_record{name=Name,keypos=KeyPos} | T], AccIn) when is_integer(KeyPos) ->
    RecordName = atom_to_list(Name),
    EtsName = ?ETS_RECORD_NAME(Name),
    %DetsName = ?DETS_RECORD_NAME(Name),
    Var = string:to_upper(atom_to_list(Name)),
    NewAccIn =
    AccIn ++
    "load_" ++ RecordName ++"() ->\n"
    "\t?INFO(\"Loading "++ RecordName ++"\"),\n"
    "\tL = db_agent_" ++ RecordName ++ ":find_" ++ RecordName ++ "(),\n"
    "\tdo_init_" ++ RecordName ++"(L),\n"
    "\tets:delete(" ++ EtsName ++ ",?RECORD_FILES_NAME),\n"
    "\t?INFO(\"Load " ++ RecordName ++ " Finish\").\n\n"
    ++ 
    case Name of
        user_dic ->
            fun_user_do_init1(RecordName, Var, EtsName);
        _ ->
            fun_user_do_init2(RecordName, Var, EtsName)
    end,
    
    fun_preload(T, NewAccIn);
fun_preload([#durable_record{name=Name} | T], AccIn) ->
    RecordName = atom_to_list(Name),
    EtsName = ?ETS_RECORD_NAME(Name),
    %DetsName = ?DETS_RECORD_NAME(Name),
    Var = string:to_upper(atom_to_list(Name)),
    NewAccIn =
    AccIn ++
    "load_" ++ RecordName ++"() ->\n"
    "\t?INFO(\"Loading "++ RecordName ++"\"),\n"
    "\tL = db_agent_" ++ RecordName ++ ":find_" ++ RecordName ++ "(),\n"
    "\tdo_init_" ++ RecordName ++"(L),\n"
    "\tets:delete(" ++ EtsName ++ ",?RECORD_FILES_NAME),\n"
    "\t?INFO(\"Load " ++ RecordName ++ " Finish\").\n\n"
    ++ fun_do_init(RecordName, Var, EtsName),
    
    fun_preload(T, NewAccIn);
fun_preload([],AccIn) ->
    AccIn.

fun_do_init(RecordName, Var, EtsName) ->
    "do_init_" ++ RecordName ++ "([H | T]) ->\n"
    "\t" ++ Var ++ " = mongo_tool:gen_record(?RECORD_FIELDS(" ++ RecordName ++ "), H, #" ++ RecordName ++ "{}),\n"
    "\tets:insert(" ++ EtsName ++ "," ++ Var ++ "),\n"
    "\tdo_init_" ++ RecordName ++ "(T);\n"
    "do_init_" ++ RecordName ++ "([]) ->\n"
    "\tship.\n\n".

fun_check_del_do_init(RecordName, Var, EtsName, Name) ->
    "do_init_" ++ RecordName ++ "([H | T]) ->\n"
    "\t" ++ Var ++ " = mongo_tool:gen_record(?RECORD_FIELDS(" ++ RecordName ++ "), H, #" ++ RecordName ++ "{}),\n" ++ 

    case Name of
        user_status ->
            "\tcase lib_merger_util:check_del_user(" ++ Var ++ ") of\n"
            "\t\ttrue ->\n"
            "\t\t\tskip;\n"
            "\t\tfalse ->\n"
            "\t\t\tets:insert(" ++ EtsName ++ "," ++ Var ++ ")\n"
            "\tend,\n";
        _ ->
            "\t#" ++ RecordName ++ "{user_id=UserID} = " ++ Var ++",\n"
            "\tcase ets:member(?ETS_USER_STATUS,UserID) of\n"
            "\t\tfalse ->\n"
            "\t\t\tskip;\n"
            "\t\ttrue ->\n"
            "\t\t\tets:insert(" ++ EtsName ++ "," ++ Var ++ ")\n"
            "\tend,\n"
    end ++
    "\tdo_init_" ++ RecordName ++ "(T);\n"
    "do_init_" ++ RecordName ++ "([]) ->\n"
    "\tship.\n\n".

fun_user_do_init1(RecordName, _Var, EtsName) ->
    "do_init_" ++ RecordName ++ "([{UserID,_}=H | T]) ->\n"
    "\tcase ets:member(?ETS_USER_STATUS,UserID) of\n"
    "\t\tfalse ->\n"
    "\t\t\tskip;\n"
    "\t\ttrue ->\n"
    "\t\t\tets:insert(" ++ EtsName ++ ",H)\n"
    "\tend,\n"
    "\tdo_init_" ++ RecordName ++ "(T);\n"
    "do_init_" ++ RecordName ++ "([]) ->\n"
    "\tship.\n\n".

fun_user_do_init2(RecordName, Var, EtsName) ->
    "do_init_" ++ RecordName ++ "([{ID, List} | T]) ->\n"
    "\t" ++ Var ++ "=[mongo_tool:gen_record_list(?RECORD_FIELDS("++ RecordName ++"),Doc,#"++ RecordName ++"{},0) || Doc <- List],\n"
    "\tcase ets:member(?ETS_USER_STATUS,ID) of\n"
    "\t\tfalse ->\n"
    "\t\t\tskip;\n"
    "\t\ttrue ->\n"
    "\t\t\tets:insert(" ++ EtsName ++ ",{ID," ++ Var ++ "})\n"
    "\tend,\n"
    "\tdo_init_" ++ RecordName ++ "(T);\n"
    "do_init_" ++ RecordName ++ "([]) ->\n"
    "\tship.\n\n".

fun_user_do_init3(RecordName, _Var, EtsName) ->
    "do_init_" ++ RecordName ++ "([{ID, List} | T]) ->\n"
    "\tcase ets:member(?ETS_USER_STATUS,ID) of\n"
    "\t\tfalse ->\n"
    "\t\t\tskip;\n"
    "\t\ttrue ->\n"
    "\t\t\tets:insert(" ++ EtsName ++ ",{ID,List})\n"
    "\tend,\n"
    "\tdo_init_" ++ RecordName ++ "(T);\n"
    "do_init_" ++ RecordName ++ "([]) ->\n"
    "\tship.\n\n".


