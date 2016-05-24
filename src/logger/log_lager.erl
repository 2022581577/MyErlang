%%%----------------------------------------------------------------------
%%% @author : 
%%% @date   :
%%% @desc   :
%%%----------------------------------------------------------------------

-module(log_lager).

%% include
-include("common.hrl").
-include("record.hrl").

%% export
-export([init/0]).

-export([lager/5]).
-export([fun_info/1]).
-export([fun_warning/1]).
-export([fun_error/1]).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
init() ->
    % error_logger:tty(false),

    BaseDir     = "./log/",
    filelib:ensure_dir(BaseDir),
    InfoFile    = util:lager_filename(BaseDir, info),
    WarningFile = util:lager_filename(BaseDir, warning),
    ErrorFile   = util:lager_filename(BaseDir, error),

    application:load(lager),
    application:set_env(lager, handlers,
        [{lager_file_backend,
                [{file, InfoFile}
                ,{level, info}
                ,{formatter_config, [date, " ", time," [",severity,"] ", message, "\n"]}]}
        ,{lager_file_backend, 
                [{file, WarningFile}
                ,{level, warning}
                ,{formatter_config, [date, " ", time," [",severity,"] ", message, "\n"]}]}
        ,{lager_file_backend, 
                [{file, ErrorFile}
                ,{level, error}
                ,{formatter_config, [date, " ", time," [",severity,"] ", message, "\n"]}]}
    ]),
    application:set_env(lager, error_logger_redirect, true),
    lager:start(),
    io:format("log_lager finish!~n"),
    ok.

lager(LogFun, Module, Line, Format, Args) ->
    Msg = io_lib:format("(~p:~p:~p) : " ++ Format, [self(), Module, Line | Args]),
    erlang:apply(?MODULE, LogFun, [Msg]),
    ok.

fun_info(Msg) ->
    lager:info(Msg).

fun_warning(Msg) ->
    lager:warning(Msg).

fun_error(Msg) ->
    lager:error(Msg).

%% ========================================================================
%% Local functions
%% ========================================================================

