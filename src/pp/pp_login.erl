%%%------------------------------------------------------------------------
%%% @author : 
%%% @date   :
%%% @desc   :
%%%------------------------------------------------------------------------

-module(pp_login).

%% include
-include("common.hrl").
-include("record.hrl").
-include("proto_10_pb.hrl").

%% export
-export([handle/3]).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
handle(_HeartBeta, #c2s10000{}, #reader_state{socket = Sock} = State) ->
    TimeStamp = util:unixtime(),
    game_pack_send:send_to_socket(Sock, #s2c10000{timestamp = TimeStamp}),
    {ok, State};

handle(_Login, #c2s10001{} = Info, State) ->
    #c2s10001{acct_name  = AccName,
             infant      = Infant,
             timestamp   = TimeStamp,
             sign        = Sign,
             server_id   = ServerID} = Info,
    lib_user_login:login(State, AccName, Infant, TimeStamp, Sign, ServerID);

handle(_Create, #c2s10002{} = Info, State) ->
    #c2s10002{user_name = Name, career = Career, gender = Gender} = Info,
    lib_user_create:create(State, Name, Career, Gender);

handle(Cmd, Info, State) ->
    ?WARNING("Error msg! Cmd:~w, Info:~w", [Cmd, Info]),
    {ok, State}.

%% ========================================================================
%% Local functions
%% ========================================================================

