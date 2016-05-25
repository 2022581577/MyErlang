%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2016.02.20
%%% @desc   : 节点管理进程，用于管理本节点和各个跨服节点
%%%           节点通过注册来相互连通，连通后连接的节点信息保存起来
%%%           不通过nodes获取连通的节点，而是通过保存起来的信息确认
%%%           由分节点主动连接主节点
%%%----------------------------------------------------------------------
-module(srv_node).
-behaviour(behaviour_gen_server).

-include("common.hrl").
-include("record.hrl").

-export([start_link/0]).
-export([do_init/1, do_call/3, do_cast/2, do_info/2, do_terminate/2]).

-define(MODULE_LOOP_TICK, 5000).		%% 进程循环时间

-record(state, {cross_connects  = []}).   %% 已经连上的跨服节点

%% ====================================================================
%% API functions
%% ====================================================================
start_link() ->
    behaviour_gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


do_init([]) ->
    %% 监控节点
	net_kernel:monitor_nodes(true, [{node_type, all}]),
    erlang:send_after(?MODULE_LOOP_TICK, self(), loop),
    %% 获取连接列表信息
    {ok, #state{}}.


%% 跨服节点接受游戏服节点的注册信息
do_cast({register, RegNode}, State) ->
    #node{node_name = RegNodeName} = RegNode,
    %% 注册信息处理
    ets:insert(?ETS_NODE, key_node_name(RegNode)),
    ets:insert(?ETS_NODE, key_platf_server(RegNode)),
    %% 反馈
    behaviour_gen_server:cast({?MODULE, RegNodeName}, {register_reply, local_node()}),
    {noreply, State};

%% 游戏服中接收到注册反馈
do_cast({register_reply, ReplyNode}, #state{cross_connects = CrossConnects} = State) ->
    #node{node_name = ReplyNodeName
         ,node_type = ReplyServerType} = ReplyNode,
    case ReplyServerType of
        ?SERVER_TYPE_CROSS ->   %% 跨服注册返回
            case lists:member(ReplyNodeName, CrossConnects) of
                ?FALSE ->   
                    ets:insert(?ETS_NODE, key_node_name(ReplyNode)),
                    ets:insert(?ETS_NODE, key_platf_server(ReplyNode)),
                    CrossConnects1 = [ReplyNodeName | CrossConnects];
                _ ->
                    CrossConnects1 = CrossConnects
            end;
        _ ->
            CrossConnects1 = CrossConnects
    end,
    State1 = State#state{cross_connects = CrossConnects1},
    {noreply, State1};

do_cast(_Info, State) ->
    {noreply, State}.


do_call(get_state, _From, State) ->
	{reply, State, State};

do_call(_Info, _From, State) ->
    {reply, ok, State}.


%% 处理新节点加入事件
do_info({nodeup, NodeName, Info}, State) ->
    ?INFO("Node up! NodeName:~w, Info:~w", [NodeName, Info]),
    {noreply, State};


%% 处理节点关闭事件(如果跨服节点关闭，则游戏服会收到该消息；如果是游戏服节点关闭，跨服服务器会收到该消息。需要区分处理)
do_info({nodedown, NodeName, Info}, #state{cross_connects = CrossConnects} = State) ->
    ?INFO("Node down! NodeName:~w, Info:~w", [NodeName, Info]),
    case ets:lookup(?ETS_NODE, NodeName) of
        #node{key = NodeNameKey, node_type = NodeServerType} = Node ->
            #node{key = PlatfServerKey} = key_platf_server(Node),
            ets:delete(?ETS_NODE, NodeNameKey),
            ets:delete(?ETS_NODE, PlatfServerKey),
            case ?CONFIG(server_type) of
                ?SERVER_TYPE_GAME when NodeServerType =:= ?SERVER_TYPE_CROSS -> 
                    %% 游戏节点，需要把跨服链接列表去掉
                    ConnectList1 = lists:delete(NodeName, CrossConnects),
                    State1 = State#state{cross_connects = ConnectList1};
                _ ->    %% 其他的暂时先不处理
                    State1 = State
            end;
        _ ->
            State1 = State
    end,
    {noreply, State1};

do_info(loop, #state{cross_connects = CrossConnects} = State) ->
    erlang:send_after(?MODULE_LOOP_TICK, self(), loop),
    %% 检测节点连通情况并进行连通(如果是游戏节点，需要连接到对应的跨服节点)
    case ?CONFIG(server_type) of
        ?SERVER_TYPE_GAME ->    
            %% 连跨服
            CrossNode = game_config:get_config(cross_node),
            case lists:member(CrossNode, CrossConnects) of
                ?FALSE ->   
                    %% 没有在已连接的跨服节点列表中
                    net_kernel:connect_node(CrossNode), %% 连接节点
                    behaviour_gen_server:cast({?MODULE, CrossNode}, {register, local_node()}), %% 注册节点信息
                    ok;
                _ ->
                    skip
            end;
        _ ->
            skip
    end,
    {noreply, State};

do_info(_Info, State) ->
    {noreply, State}.


do_terminate(_Reason, State) ->
    {ok, State}.

%%% -----------------------------------
%%%           Local Fun
%%% -----------------------------------


%% @doc 获取当前节点的信息
local_node() ->
    NodeName = node(),
    NodeType = game_config:get_config(server_type),
    Platform = game_config:get_config(platform),
    ServerID = game_config:get_config(server_id),
    Port     = game_config:get_config(server_port),
    IP       = game_config:get_config(server_ip),
    Node     = #node{node_name = NodeName
                    ,node_type = NodeType
                    ,platform  = Platform
                    ,server_id = ServerID
                    ,ip        = IP
                    ,port      = Port},
    Node.

%% 节点名作为key
key_node_name(#node{node_name = NodeName} = Node) ->
    Node#node{key = NodeName}.

%% {平台,服务器id}作为key
key_platf_server(#node{platform = Platform, server_id = ServerID} = Node) ->
    Node#node{key = {Platform, ServerID}}.

