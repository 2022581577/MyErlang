#!/usr/bin/env escript
%%% @author : kongqingquan <kqqsysu@gmail.com>

-mode(compile).

-include("../include/common.hrl").
-include("../include/generation.hrl").
-include("../include/generation_logtype.hrl").

main(_Args) ->
    gen_hrl(),
    gen_erl(),
    ok.

%% 构建宏定义文件
gen_hrl() ->
    check_macro(?LOGTYPE_LIST),
    FileName = "include_log_type.hrl",
    Fun =
    fun({Val, Term, Detail}, Acc) ->
            Add = "-define(" ++ Term ++ ",\t" ++ lists:concat([Val]) ++ ").\t%% " ++ Detail ++ "\n",
            Add ++ Acc
    end,
    Str = lists:foldr(Fun, "", ?LOGTYPE_LIST),
    ?WRITE_FILE(FileName,Str),
    ok.

%% 检查定义的合法
check_macro(List) ->
    Len = length(List),
    Len = length(lists:ukeysort(1, List)),
    Len = length(lists:ukeysort(2, List)),
    Len.

%% 构建源文件
gen_erl() ->
    Name = "lib_parse_logtype",
    Str = get_header(Name) ++ fun_get_body(),
    FileName = Name ++ ".erl",
    ?WRITE_FILE(FileName,Str),
    ok.


%% @doc 头信息
get_header(Name) ->
    "-module(" ++ Name ++ ").\n"
    "-include(\"common.hrl\").\n"
    "-include(\"record.hrl\").\n\n"
    "-export([init/0]).\n\n".

%% @doc 函数体
fun_get_body() ->
    {DropSql, CreateSql, InserSqls} = fun_init(),
    "%% 插入logtype数据到数据库\n"
    "init() ->\n"
    "\tdb_util:execute(" ++ DropSql ++ ", ?CFG_SQL_TIMEOUT),\n"
    "\tdb_util:execute(" ++ CreateSql ++ ", ?CFG_SQL_TIMEOUT),\n" ++
    lists:foldl(fun(Sql, Acc) -> 
                "\tdb_util:execute(" ++ Sql ++ ", ?CFG_SQL_TIMEOUT),\n" ++ Acc
        end, "", InserSqls) ++
    "\tok.\n".

%% 初始化
fun_init() ->
    DropSql = "\"DROP TABLE IF EXISTS `game_project`;\"",
    CreateSql = "\"CREATE TABLE `game_project` (
                `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID标识',
                `project_id` int(11) NOT NULL COMMENT '项目ID',
                `project_name` varchar(255) NOT NULL COMMENT '项目内容',
                `type` tinyint(2) DEFAULT NULL COMMENT '类型0后台1礼盒2掉落3任务',
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8;\"",
    L = [{Value, Detail} || {Value, _Term, Detail} <- ?LOGTYPE_LIST],
    InserSqls = fun_get_insert(L, []),
    {DropSql, CreateSql, InserSqls}.

fun_get_insert([{ProjectID, Name}|T], Result) ->
    InsertSql = "\"INSERT INTO `game_project`(`Project_id`,`project_name`,`type`) VALUES('" ++ lists:concat([ProjectID]) ++ "','" ++ Name ++ "','0');\"",
    fun_get_insert(T, [InsertSql|Result]);
fun_get_insert([], Result) ->
    Result.

