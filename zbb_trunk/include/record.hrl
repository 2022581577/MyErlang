%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2016.02.16
%%% @desc   : record定义
%%%----------------------------------------------------------------------

-ifndef(RECORD_HRL).
-define(RECORD_HRL,"record.hrl").

-include("rd_user.hrl").
-include("rd_map.hrl").

%% 跨服服务器保存信息
-record(cross_server_config, {merge_list = []               %% 合服列表[{{Platform, ServerID}, {Platform, MainServerID}} | _]，用于根据平台和服务器id获取主服务器id
                             ,dict_node_info = dict:new()   %% node_info字典，key:{Platform, ServerID}，value:#node_info{}
                            }).

-endif.
