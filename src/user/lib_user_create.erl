%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 五月 2016 10:51
%%%-------------------------------------------------------------------
-module(lib_user_create).
-author("Administrator").

%% include
-include("common.hrl").
-include("record.hrl").
-include("proto_10_pb.hrl").

%% export
-export([create/4]).

%% record and define
-define(CREATE_SUCCESS,             1).
-define(CREATE_ERROR_NAME_EXIST,    2).
-define(CREATE_ERROR_NAME,          3).
-define(CREATE_ERROR_CAREER,        4).
-define(CREATE_ERROR_GENDER,        5).

%% ========================================================================
%% API functions
%% ========================================================================
create(#reader_state{socket = Sock} = State, Name, Career, Gender) ->
    case check_create(Name, Career, Gender) of
        ?TRUE ->
            {ok, State1} = do_create(State, Name, Career, Gender),
            {ok, State1};
        {?FALSE, Res} ->
            Data = #s2c10002{result = Res, user_id = 0, users = []},
            game_pack_send:send_to_socket(Sock, Data),
            {?FALSE, create_false}
    end.

%% ========================================================================
%% Local functions
%% ========================================================================
do_create(State, Name, Career, Gender) ->
    {ok, State1} = create_user(State, Name, Career, Gender),
    {ok, State1}.

check_create(Name, Career, Gender) ->
    case is_gender_allow(Gender) of
        ?TRUE ->
            check_create1(Name, Career);
        _ ->
            {?FALSE, ?CREATE_ERROR_GENDER}
    end.

check_create1(Name, Career) ->
    case is_career_allow(Career) of
        ?TRUE ->
            check_create2(Name);
        _ ->
            {?FALSE, ?CREATE_ERROR_CAREER}
    end.

check_create2(Name) ->
    is_name_allow(Name).

is_gender_allow(Gender) ->
    Gender =:= ?GENDER_MALE orelse Gender =:= ?GENDER_FEMALE.

is_career_allow(Career) ->
    lists:member(Career, [?CAREER_1, ?CAREER_2, ?CAREER_3]).

-define(NAME_MIN_LENGTH, 2).
-define(NAME_MAX_LENGTH, 6).
is_name_allow(Name) when byte_size(Name) < ?NAME_MIN_LENGTH ->
    {?FALSE, ?CREATE_ERROR_NAME};
is_name_allow(Name) when byte_size(Name) > ?NAME_MAX_LENGTH ->
    {?FALSE, ?CREATE_ERROR_NAME};
is_name_allow(Name) ->
    case lib_word:string_ver(Name) of           %% 检查非法字符
        ?TRUE ->
            case lib_word:words_ver(Name) of    %% 检查敏感字
                ?TRUE ->
                    %% 检查名字是否存在
                    ?TRUE;
                _ ->
                    {?FALSE, ?CREATE_ERROR_NAME}
            end;
        _ ->
            {?FALSE, ?CREATE_ERROR_NAME}
    end.

create_user(State, Name, Career, Gender) ->
    #reader_state{acc_name  = AccName
                 ,socket    = Sock} = State,
    UserID  = game_counter:get_user_id(),
    User    =
        #user{user_id       = UserID
            ,acc_name       = AccName
            ,name           = Name
            ,server_id      = ?CONFIG(server_id)
            ,reg_server_id  = ?CONFIG(server_id)
            ,ip             = util:socket_to_ip(Sock)
            ,reg_time       = util:unixtime()
            ,gender         = Gender
            ,career         = Career
        },
    {ok, User1} = user_action:create(User),
    %% 保存信息
    save_user(User1),
    {ok, State}.

save_user(User) ->
    User1       = User#user{other_data = <<>>},
    FieldValue  = lib_record:fields_value(User1),
    ets:insert(?ETS_USER, User1),       %% 存ets
    edb_util:insert(user, FieldValue),  %% 存库
    ok.
