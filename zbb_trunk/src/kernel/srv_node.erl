%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2016.02.20
%%% @desc   : 节点管理进程，用于管理本节点和各个跨服节点
%%%           节点通过注册来相互连通，连通后连接的节点信息保存起来
%%%           不通过nodes获取连通的节点，而是通过保存起来的信息确认
%%%           TODO 如果用游戏服来作为跨服节点，需要特殊处理
%%%----------------------------------------------------------------------
-module(srv_node).
-behaviour(game_gen_server).

-include("common.hrl").
-include("map.hrl").
-include("user.hrl").
-include_lib("stdlib/include/ms_transform.hrl").

-export([start_link/0]).
-export([do_init/1, do_call/3, do_cast/2, do_info/2, do_terminate/2]).

-define(CONNECT_FLAG_FALSE, 0).
-define(CONNECT_FLAG_TRUE, 1).

-define(MODULE_LOOP_TICK, 5000).		%% 进程循环时间10秒

-record(state, {loop_count = 0      %% 循环次数
               ,connect_list = []   %% 链接列表 [{CrossNode,ConnectFlag} | _] 
               ,node_info           %% 本节点的节点信息
           }).

-record(node_info, {node            %% 节点
                   ,node_type       %% 节点类型(config中的server_type)
                   ,platform        %% 平台(config中的platform)
                   ,server_id       %% 服务器编号(config中的server_id)
                   ,port            %% 端口(config中的server_port)
                   ,ip              %% ip(config中的server_ip)
               }).

%% 注册信息
-record(register_info, {node
                       ,merge_list = []
                    }).


%% ====================================================================
%% API functions
%% ====================================================================
start_link() ->
    game_gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


do_init([]) ->
    %% 监控节点
	net_kernel:monitor_nodes(true, [{node_type, all}]),
    erlang:send_after(?MODULE_LOOP_TICK, self(), loop),
    %% 初始化本节点信息
    NodeInfo = node2node_info(node()),
    %% 获取连接列表信息
    ConnectList = init_connect_list(),
    {ok, #state{connect_list = ConnectList, node_info = NodeInfo}}.


%% 跨服节点接受游戏服节点的注册信息
do_cast({register, #register_info{node = ClinetNode, merge_list = _MergeList}}, State) ->
    %% TODO 注册信息处理

    %% 反馈
	game_gen_server:cast({?MODULE, ClinetNode}, {register_reply, node()}),
    {noreply, State};

%% 游戏服中接收到注册反馈
do_cast({register_reply, ServerNode}, #state{connect_list = ConnectList} = State) ->
    case lists:keyfind(ServerNode, 1, ConnectList) of
        false ->
            ?WARNING("register_reply false, ServerNode:~w, ConnectList:~w", [ServerNode, ConnectList]),
            {noreply, State};
        {ServerNode, _ConnectFlag} ->
            ConnectList1 = lists:keystore(ServerNode, 1, ConnectList, {ServerNode, ?CONNECT_FLAG_TRUE}),
            %% TODO 处理游戏服中的跨服服务器信息
            {noreply, State#state{connect_list = ConnectList1}}
    end;

%% 重新获取连接列表并重置(游戏服节点) net_kernel:disconnect()
do_cast({reset_connect_list}, #state{connect_list = _ConnectList} = State) ->
    _NewConnectList = init_connect_list(),
    %% TODO 需要根据跨服类型判断是否有新的跨服加入，如果有跨服类型相同的但节点不同，需要删除旧的，加入新的
    {noreply, State};

do_cast(_Info, State) ->
    {noreply, State}.


do_call(get_state, _From, State) ->
	{reply, State, State};

do_call(_Info, _From, State) ->
    {reply, ok, State}.


%% 处理新节点加入事件(跨服节点才会收到对应的消息)
do_info({nodeup, Node, _InfoList}, State) ->
    case node2node_info(Node) of
        #node_info{} = _NodeInfo ->
            %% TODO 将连接上来的节点信息保存
            ok;
        _ ->
            skip
    end,
    {noreply, State};


%% 处理节点关闭事件(如果跨服节点关闭，则游戏服会收到该消息；如果是游戏服节点关闭，跨服服务器会收到该消息。需要区分处理)
do_info({nodedown, Node, _InfoList}, #state{connect_list = ConnectList} = State) ->
    ServerType = ?CONFIG(server_type),
    
    case node2node_info(Node) of
        #node_info{} = _NodeInfo when ServerType == ?SERVER_TYPE_GAME ->  
            %% 游戏服处理时不需要把该节点从connect_list中删除，只需要把flag置为0，跨服重开时能连上
            case lists:keyfind(Node) of
                {Node, _} ->
                    ConnectList1 = lists:keystore(Node, 1, ConnectList, {Node, ?CONNECT_FLAG_FALSE}),
                    %% 需要把ets中保存的一些跨服信息删除
                    {noreply, State#state{connect_list = ConnectList1}};
                _ ->
                    {noreply, State}
            end;
        #node_info{} -> %% 跨服服务器中，把存储的游戏服的数据删除
            {noreply, State};
        _ ->
            {noreply, State}
    end;

do_info(loop, State) ->
    erlang:send_after(?MODULE_LOOP_TICK, self(), loop),
    %% 检测节点连通情况并进行连通(如果是游戏节点，需要连接到对应的跨服节点)
    case ?CONFIG(server_type) of
        ?SERVER_TYPE_GAME ->
            State1 = connect(State),
            {noreply, State1};
        _ ->
            {noreply, State}
    end;

do_info(_Info, State) ->
    {noreply, State}.

do_terminate(_Reason, State) ->
    {ok, State}.

%%% -----------------------------------
%%%           Local Fun
%%% -----------------------------------

%% @doc 获取需要连接的节点信息
%% @return [{} | _]
init_connect_list() ->
    case ?CONFIG(server_type) of
        ?SERVER_TYPE_GAME ->    %% 游戏服，需要获取跨服节点信息
            case ?CONFIG(center_server_flag) of
                1 ->    %% 通过中央服获取跨服节点信息
                    [];
                _ ->    %% 没连接中央服，给默认的跨服节点信息
                    []
            end;
        _ ->                    %% 非游戏服，没有跨服节点信息
            []
    end.

%% @doc 根据节点名获取#node_info{}
%% @return #node_info{}
node2node_info(Node) ->
	case string:tokens(util:to_list(Node), "_@") of
		[NodeTypeStr, PlatformStr, PrefixServerIDStr, PortStr, IpStr] ->
            #node_info{node = Node
                      ,node_type = util:to_atom(NodeTypeStr)
                      ,platform = PlatformStr
                      ,server_id = util:prefix_server_id_str2server_id(PrefixServerIDStr)
                      ,port = util:to_integer(PortStr)
                      ,ip = IpStr};
		R ->
            ?WARNING("node2node_info false, Res:~w", [R]),
			{false, <<"illegal node name">>}
	end.

%% @doc 连接跨服A/B/C区服务器
%% @return {true,State}
connect(#state{connect_list = ConnectList} = _State) ->
    [begin 
        net_kernel:connect_node(CrossNode), %% 连接节点
        game_gen_server:cast({?MODULE, CrossNode}, {register, #register_info{node = node()}})   %% 注册节点信息
     end || {CrossNode, ?CONNECT_FLAG_FALSE} <- ConnectList],
    ok.


