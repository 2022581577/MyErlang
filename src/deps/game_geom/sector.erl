%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 六月 2016 17:18
%%%-------------------------------------------------------------------
-module(sector).
-author("Administrator").

%% include
-include("game_geom.hrl").

%% export
-export([new/4]).
-export([is_point_in/2]).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
-spec new(Center, R, Dir, Angle) -> #sector{} when
    Center :: #vector2f{},
    R :: integer(),
    Dir :: #vector2f{},
    Angle :: integer().
new(Center, R, Dir, Angle) ->
    #sector{
        center  = Center
        ,r      = R
        ,dir    = Dir
        ,angle  = Angle
    }.


%% @doc 判断是否在扇形区域内
-spec is_point_in_sector(Sector, TargetPoint) -> boolean() when
    Sector :: #sector{},
    TargetPoint :: #vector2f{}.
is_point_in(Sector, TargetPoint) ->
    #sector{center  = #vector2f{x = Cx, y = Cy}
        ,r      = R
        ,dir    = #vector2f{x = Ux, y = Uy}
        ,angle  = Angle} = Sector,
    #vector2f{x = Tx, y = Ty} = TargetPoint,
    Dx = Tx - Cx,
    Dy = Ty - Cy,
    DSquare  = Dx * Dx + Dy * Dy,
    case DSquare >= R * R of
        true ->
            false;
        _ ->
            Distance    = math:sqrt(DSquare),
            NormalDX    = Dx / Distance,
            NormalDY    = Dy / Distance,
            Camber      = 2 * math:pi() / 360 * (Angle / 2),    %% 角度转换为弧度
            math:acos(NormalDX * Ux + NormalDY * Uy) < Camber
    end.

%% ========================================================================
%% Local functions
%% ========================================================================

