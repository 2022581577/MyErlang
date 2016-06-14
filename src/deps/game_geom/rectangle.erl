%%-----------------------------------------------------
%% @Module:rectangle 
%% @Author:xiayong
%% @Email:xiayong@yy.com
%% @Created:2014-8-5
%% @Desc:
%%-----------------------------------------------------

-module(rectangle).

-compile(export_all).

-include("game_geom.hrl").
%% ------------------------------------------------------------------------------------------
%% API functions
%% ------------------------------------------------------------------------------------------
-export([
            new/4
            ,is_contain/3
            ,is_contain/2
        ]).

new(X, Y, Width, Height) ->
    #rectangle{
        x = X
        ,y = Y
        ,width = Width
        ,height = Height
    }.

is_contain({X, Y, Width, Height}, PointX, PointY) ->
    if
        (X + Width > PointX) andalso
        (X =< PointX) andalso
        (Y + Height > PointY) andalso
        (Y =< PointY) ->
             true;
        true ->
            false
    end;
is_contain(_Rectangle = #rectangle{x = X, y = Y, width = Width, height = Height}, PointX, PointY) ->
    is_contain({X, Y, Width, Height}, PointX, PointY).

is_contain(Rectangle, _Point = #vector2f{x = X, y = Y}) when is_record(Rectangle, rectangle) ->
    is_contain(Rectangle, X, Y).

%% @doc 判断两个矩形是否相交
cmp(#rectangle{x = X1, y = Y1, width = Width1, height = Height1}, #rectangle{x = X2, y = Y2, width = Width2, height = Height2}) ->
    cmp({X1, Y1, Width1, Height1}, {X2, Y2, Width2, Height2});
cmp({X1, Y1, Width1, Height1}, {X2, Y2, Width2, Height2})->
    MinX = erlang:max(X1, X2),
    MinY = erlang:max(Y1, Y2),
    MaxX = erlang:min(X1+Width1, X2+Width2),
    MaxY = erlang:min(Y1+Height1, Y2+Height2),
    case (MinX > MaxX) orelse (MinY > MaxY) of
        true ->
            false;
        _ ->
            true
    end.


%% ------------------------------------------------------------------------------------------
%% Internal functions
%% ------------------------------------------------------------------------------------------


