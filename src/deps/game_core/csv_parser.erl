%%-----------------------------------------------------
%% @Module:csv_parser 
%% @Author:xiayong
%% @Email:xiayong@yy.com
%% @Created:2014-8-20
%% @Desc:CSV文件解析器
%%-----------------------------------------------------

-module(csv_parser).


-record(ecsv,{ 
   state = field_start,      %%field_start|normal|quoted|post_quoted
   cols = undefined,         %%how many fields per record
   current_field = [], 
   current_record = [], 
   fold_state, 
   fold_fun                  %%user supplied fold function
   }).

%% ------------------------------------------------------------------------------------------
%% API functions
%% ------------------------------------------------------------------------------------------
-export([
            parse_file/3
            ,parse_file/1
            ,parse/1
            ,parse/3
        ]).



%% ------------------------------------------------------------------------------------------
%% Internal functions
%% ------------------------------------------------------------------------------------------

%% @return [tuple,....]|{false,Reason}
%% csv_parser:parse_file("../ebin/skill.csv").
%% [{"int","int","string","spec_string"},
%%  {"skill_id","skill_level","skill_desc","misc"},
%%  {"1","1",[230,138,128,232,131,189,49],"[{1,100},{2,200}]"},
%%  {"2","1",[230,138,128,232,131,189,50],"[{1,100},{2,200}]"},
%%  {"3","1",[230,138,128,232,131,189,51],"[{1,100},{2,200}]"}]
parse_file(FileName,InitialState,Fun) -> 
       case file:read_file(FileName) of
        {ok, Binary} ->
            parse(Binary,InitialState,Fun);
        R ->
            R
    end.

parse_file(FileName)  -> 
    case file:read_file(FileName) of
           {ok, Binary} ->
            parse(Binary);
        R ->
            R
    end.

parse(X) -> 
   R = parse(X,[],fun(Fold,Record) -> [Record|Fold] end), 
   lists:reverse(R). 

parse(X,InitialState,Fun) -> 
   do_parse(X,#ecsv{fold_state=InitialState,fold_fun = Fun}). 

%% The tree arguments functions provide the fold-like interface, while the single argument one returns a list with all the records in the file. 
%% Parsing 
%% 
%% Now the fun part!. 
%% The transitions (State X Input -> NewState ) are almost 1:1 derived from the diagram, with minor changes (like the handling of field and record delimiters, common to both the normal and post_quoted state). 
%% Inside a quoted field, a double quote must be escaped by preceding it with another double quote. Its really easy to distinguish this case by matching against 
%% 
%% <<$",$",_/binary>> 
%% 
%% sort of "lookahead" in yacc's lexicon. 

%% --------- Field_start state --------------------- 
%%whitespace, loop in field_start state 
do_parse(<<32,Rest/binary>>,S = #ecsv{state=field_start,current_field=Field})-> 
    do_parse(Rest,S#ecsv{current_field=[32|Field]});

%%its a quoted field, discard previous whitespaces 
do_parse(<<$",Rest/binary>>,S = #ecsv{state=field_start})-> 
    do_parse(Rest,S#ecsv{state=quoted,current_field=[]});

%%anything else, is a unquoted field 
do_parse(Bin,S = #ecsv{state=field_start})-> 
    do_parse(Bin,S#ecsv{state=normal});

%% --------- Quoted state --------------------- 
%%Escaped quote inside a quoted field 
do_parse(<<$",$",Rest/binary>>,S = #ecsv{state=quoted,current_field=Field})-> 
    do_parse(Rest,S#ecsv{current_field=[$"|Field]});

%%End of quoted field 
do_parse(<<$",Rest/binary>>,S = #ecsv{state=quoted})-> 
    do_parse(Rest,S#ecsv{state=post_quoted});

%%Anything else inside a quoted field 
do_parse(<<X,Rest/binary>>,S = #ecsv{state=quoted,current_field=Field}) when X =< 127 -> 
    do_parse(Rest,S#ecsv{current_field=[X|Field]});
do_parse(<<X1,X2,Rest/binary>>,S = #ecsv{state=quoted,current_field=Field}) ->
    <<KeyGBK:16>> = <<X1:8, X2:8>>,
    KeyUnicode = gbk_to_unicode:get(KeyGBK),
    <<B:16>> = <<KeyUnicode:16>>,
    do_parse(Rest,S#ecsv{current_field=[B|Field]});

do_parse(<<>>, #ecsv{state=quoted})-> 
    throw({ecsv_exception,unclosed_quote});

%% --------- Post_quoted state --------------------- 
%%consume whitespaces after a quoted field 
do_parse(<<32,Rest/binary>>,S = #ecsv{state=post_quoted})-> 
    do_parse(Rest,S);

%%---------Comma and New line handling. ------------------ 
%%---------Common code for post_quoted and normal state--- 

%%EOF in a new line, return the records 
do_parse(<<>>, #ecsv{current_record=[],fold_state=State})-> 
    State;
%%EOF in the last line, add the last record and continue 
do_parse(<<>>,S)-> 
    do_parse([],new_record(S));

%% skip carriage return (windows files uses CRLF) 
do_parse(<<$\r,Rest/binary>>,S = #ecsv{})-> 
    do_parse(Rest,S);

%% new record 
do_parse(<<$\n,Rest/binary>>,S = #ecsv{}) -> 
    do_parse(Rest,new_record(S));

do_parse(<<$, ,Rest/binary>>,S = #ecsv{current_field=Field,current_record=Record})-> 
    do_parse(Rest,S#ecsv{
        state=field_start,
          current_field=[],
          current_record=[lists:reverse(Field)|Record]});

%%A double quote in any other place than the already managed is an error 
do_parse(<<$",_Rest/binary>>, #ecsv{})-> 
    throw({ecsv_exception,bad_record});

%%Anything other than whitespace or line ends in post_quoted state is an error 
do_parse(<<_X,_Rest/binary>>, #ecsv{state=post_quoted})-> 
    throw({ecsv_exception,bad_record});

%%Accumulate Field value 
do_parse(<<X,Rest/binary>>,S = #ecsv{state=normal,current_field=Field})-> 
    do_parse(Rest,S#ecsv{current_field=[X|Field]}).

%% Record assembly and callback 
%% 
%% Convert each record to a tuple, and check that it has the same number of fields than the previous records. Invoke the callback function with the new record and the previous state. 

%%check    the record size against the previous, and actualize state.
new_record(S=#ecsv{cols=Cols,current_field=Field,current_record=Record,fold_state=State,fold_fun=Fun}) -> 
    NewRecord = list_to_tuple(lists:reverse([lists:reverse(Field)|Record])),
    if
        (tuple_size(NewRecord) =:= Cols) or (Cols =:= undefined) ->
            NewState = Fun(State,NewRecord),
            S#ecsv{state=field_start,cols=tuple_size(NewRecord),
            current_record=[],current_field=[],fold_state=NewState};
        (tuple_size(NewRecord) =/= Cols) ->
            throw({ecsv_exception,bad_record_size})
    end.




