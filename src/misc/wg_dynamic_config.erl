%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2013.06.15.
%%% @desc   : 动态编译模块,由 mochiweb mochiglobal.erl 修改
%%%----------------------------------------------------------------------

-module(wg_dynamic_config).
-export([get/2, get/3, list/1]).
-export([compile/2,compile_kv/2,compile_record/2,compile/4,compile/5]).

%% @equiv get(K, undefined)
get(Mod,K) ->
    get(Mod,K, undefined).

%% @doc Get the term for K or return Default.
get(Mod,K, Default) ->
    try 
		Mod:get(K)
    catch 
		_:_ ->
        	Default
    end.
list(Mod) ->
	try
		Mod:list()
	catch
		_:_ ->
			[]
	end.

%% @doc Store term V at K, replaces an existing term if present.
compile(Mod, L) ->
    compile(Mod, L,0,"").

compile_kv(Mod,L) ->
	compile(Mod,L,1,"").

compile_record(Mod,L) ->
	compile(Mod,L,2,"").

compile(Mod,L,KeyPos,Dir) ->
	compile(Mod,L,KeyPos,Dir,[]).

compile(Mod, L, KeyPos,_Dir,CompileOtps) ->
    Bin = do_compile(Mod, L,KeyPos,CompileOtps),
    code:purge(Mod),
    {module, Mod} = code:load_binary(Mod, atom_to_list(Mod) ++ ".erl", Bin),
    ok.


do_compile(Module,L, KeyPos, CompileOtps) ->
    {ok, Module, Bin} = compile:forms(forms(Module, KeyPos,L),
                                     CompileOtps ++  [verbose, warnings_as_errors,report_errors]),
    Bin.

forms(Module, KeyPos,L) ->
    [erl_syntax:revert(X) || X <- term_to_abstract(Module, KeyPos, L)].

term_to_abstract(Module, _KeyPos,[]) ->
    [%% -module(Module).
     erl_syntax:attribute(
       erl_syntax:atom(module),
       [erl_syntax:atom(Module)]
	   ),
     %% -export([list/0]).
     erl_syntax:attribute(
       erl_syntax:atom(export),
       [erl_syntax:list(
         [erl_syntax:arity_qualifier(
            erl_syntax:atom(list),
            erl_syntax:integer(0))])
	   ]
	  ),
     %% list() -> T.
     erl_syntax:function(
       erl_syntax:atom(list),
       [erl_syntax:clause([], none, [erl_syntax:abstract([])])]
	   )
	];

term_to_abstract(Module,KeyPos,L) ->
    [%% -module(Module).
     erl_syntax:attribute(
       erl_syntax:atom(module),
       [erl_syntax:atom(Module)]
	   ),
     %% -export([list/0,get/1]).
     erl_syntax:attribute(
       erl_syntax:atom(export),
       [erl_syntax:list(
         [erl_syntax:arity_qualifier(
            erl_syntax:atom(list),
            erl_syntax:integer(0)
			),
		  erl_syntax:arity_qualifier(
			  erl_syntax:atom(get),
			  erl_syntax:integer(1)
		    )
		 ])
	   ]
	  )
	 ] ++
     %% list() -> T.
     [erl_syntax:function(
       erl_syntax:atom(list),
       [erl_syntax:clause([], none, [erl_syntax:abstract(L)])]
	   )
     ] ++
	 %% get(K)-> T
     [erl_syntax:function(
       erl_syntax:atom(get),
       [ begin 
	   		case {E,KeyPos} of
				{_,0} ->
					K = E,
					V = true;
				{{_,_},1} ->
					{K,V} = E;
				{_,KeyPos} when KeyPos >0 andalso erlang:is_tuple(E) ->
					K = erlang:element(KeyPos,E),
					V = E
			end,
			erl_syntax:clause([erl_syntax:abstract(K)], none, [erl_syntax:abstract(V)])
		end || E <-L]
	   )
     ].

