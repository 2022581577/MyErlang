{
    application, server,
    [
        {description, "game_server"}
        ,{vsn, "1.0"}
        ,{module, [main]}
        ,{registered, [game_server]}
        ,{applications, [kernel, sasl, stdlib]}
        ,{mod, {server_app, []}}
        ,{start_phases, []}
        ,{env, []}
    ]
}.
