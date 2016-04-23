{application,server,
             [{description,"game_server"},
              {vsn,"1.0"},
              {modules,[a_star,binary_heap,circle,client_protobuf_encode,
                        common_pb,cron,cron_lib,cron_test,csv_parser,data_map,
                        delaunay,dynamic_compile,dynarec,edb,edb_util,emysql,
                        emysql_app,emysql_auth,emysql_conn,emysql_conn_mgr,
                        emysql_conv,emysql_statements,emysql_sup,emysql_tcp,
                        emysql_util,emysql_worker,error_logger_lager_h,
                        fsm_lock,game_config,game_counter,game_ctl,
                        game_ets_init,game_gen_server,game_geom_astar,
                        game_geom_bstar,game_mmdb,game_mmdb_preload,
                        game_node_interface,game_pack_send,game_reloader,
                        gbk_to_unicode,global_data_disk,global_data_ram,lager,
                        lager_app,lager_backend_throttle,
                        lager_common_test_backend,lager_config,
                        lager_console_backend,lager_crash_log,
                        lager_default_formatter,lager_file_backend,
                        lager_format,lager_handler_watcher,
                        lager_handler_watcher_sup,lager_msg,lager_stdlib,
                        lager_sup,lager_transform,lager_trunc_io,lager_util,
                        lib_map,lib_record,lib_server,lib_user,line2d,
                        logger_h,loglevel,main,map_aoi,map_block,map_config,
                        math_util,mmake,mtop,navmesh,navmesh_test,
                        packet_encode,path_cell,polygon,proto_10_pb,
                        proto_11_pb,proto_12_pb,proto_13_pb,proto_14_pb,
                        proto_15_pb,proto_16_pb,proto_17_pb,proto_18_pb,
                        proto_19_pb,proto_20_pb,proto_21_pb,proto_22_pb,
                        proto_23_pb,proto_24_pb,proto_25_pb,proto_26_pb,
                        proto_27_pb,proto_28_pb,proto_29_pb,proto_30_pb,
                        proto_31_pb,proto_32_pb,proto_33_pb,proto_34_pb,
                        proto_35_pb,proto_60_pb,protobuf_encode,
                        rebar_file_utils,rebar_utils,rectangle,rfc4627,
                        rfc4627_jsonrpc,rfc4627_jsonrpc_app,
                        rfc4627_jsonrpc_http,rfc4627_jsonrpc_inets,
                        rfc4627_jsonrpc_mochiweb,rfc4627_jsonrpc_registry,
                        rfc4627_jsonrpc_sup,server_app,server_sup,simple_pb,
                        smdl,sort_test,srv_log,srv_map,srv_map_manager,
                        srv_node,srv_reader,srv_timer,srv_user,sys_info,
                        tcp_acceptor,tcp_acceptor_sup,tcp_client_sup,
                        tcp_listener,tcp_listener_sup,time_format,triangle,
                        user_load,user_log,user_loginout,user_online,
                        user_routing,user_send,util,vector2f,
                        wg_dynamic_config]},
              {registered,[game_server]},
              {applications,[kernel,sasl,stdlib]},
              {mod,{server_app,[]}},
              {start_phases,[]},
              {env,[]}]}.