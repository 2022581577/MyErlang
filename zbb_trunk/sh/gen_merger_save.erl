#!/usr/bin/env escript
%%% @author : yaoyang <air_time126.com>

-mode(compile).

-include("../include/common.hrl").
-include("../include/generation.hrl").

main(_Args) ->
    Name = "lib_merger_save",
    Str = get_header(Name) ++ fun_save_data() ++  fun_presave(),
    FileName = Name ++ ".erl",
    ?WRITE_FILE(FileName,Str),
    ok.

%% @doc 头信息
get_header(Mod) ->
    ?COPYRIGHT
    "-module(" ++ Mod ++ ").\n"
    "-include(\"common.hrl\").\n"
    "-include(\"record.hrl\").\n\n"
    "-export([save_data/0]).\n\n".

fun_save_data() ->
    "save_data() ->\n" ++
    lists:foldl(fun(#durable_record{name = Name, is_merger=IsMerger},AccIn) ->
                case IsMerger of
                    false ->
                        AccIn;
                    _ ->
                        AccIn ++ "\tsave_" ++ atom_to_list(Name) ++ "(),\n"
                end
                end,"",?DURABLE_RECORD_LIST) ++
    "\tok.\n\n".

fun_presave() ->
    fun_presave(?DURABLE_RECORD_LIST,"").
fun_presave([#durable_record{is_merger=false} | T],AccIn) ->
    fun_presave(T,AccIn);
fun_presave([#durable_record{name=Name,keypos=KeyPos,is_preload=false} | T],AccIn)  when is_integer(KeyPos) ->
    RecordName = atom_to_list(Name),
    EtsName = ?ETS_RECORD_NAME(Name),
    NewAccIn = AccIn ++
    "save_" ++ RecordName ++ "() ->\n" ++
    case Name of
        user_dic ->
            "\tets:foldl(fun({ID,List},_AccIn) ->\n"
            "\t\tDoc = {'_id',ID,list,List},\n"
            "\t\tmongo_tool:update(" ++ RecordName ++ ", ID, Doc)\n"
            "\tend,[]," ++ EtsName ++ ").\n";
        _ ->
            "\tets:foldl(fun({ID,List},_AccIn) ->\n"
            "\t\tDocList = [mongo_tool:gen_doc(?RECORD_FIELDS(" ++ RecordName ++ "), Item, 0) || Item <- List],\n"
            "\t\tDoc = {'_id', ID, list, DocList},\n"
            "\t\tmongo_tool:update(" ++ RecordName ++ ", ID, Doc)\n"
            "\tend,[]," ++ EtsName ++ ").\n\n"
    end,
    fun_presave(T,NewAccIn);

fun_presave([#durable_record{name=Name,keypos=KeyPos,is_preload=false} | T],AccIn)  ->
    RecordName = atom_to_list(Name),
    EtsName = ?ETS_RECORD_NAME(Name),
    NewAccIn = AccIn ++
    "save_" ++ RecordName ++ "() ->\n" ++
    "\tets:foldl(fun(#" ++ RecordName ++ "{" ++ atom_to_list(KeyPos) ++ " = ID}=Status,_AccIn) ->\n"
    "\t\tDoc = mongo_tool:gen_doc(?RECORD_FIELDS(" ++ RecordName ++ "), Status),\n"
    "\t\tmongo_tool:update(" ++ RecordName ++ ", ID, Doc)\n"
    "\tend,[]," ++ EtsName ++ ").\n\n",
    fun_presave(T,NewAccIn);
fun_presave([#durable_record{name=Name,is_preload=true,keypos=KeyPos} | T],AccIn) ->
    RecordName = atom_to_list(Name),
    EtsName = ?ETS_RECORD_NAME(Name),
    NewAccIn = AccIn ++
    "save_" ++ RecordName ++ "() ->\n" ++
    "\tets:foldl(fun(#" ++ RecordName ++ "{" ++ atom_to_list(KeyPos) ++ " = ID}=Info,_AccIn) ->\n"
    "\t\tDoc = mongo_tool:gen_doc(?RECORD_FIELDS(" ++ RecordName ++ "), Info),\n"
    "\t\tmongo_tool:update("++ RecordName ++",ID, Doc)\n"
    "\tend,[]," ++ EtsName ++ ").\n\n",
    fun_presave(T,NewAccIn);

fun_presave([],AccIn) ->
    AccIn.
