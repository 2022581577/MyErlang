%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 六月 2016 17:18
%%%-------------------------------------------------------------------

-module(circle).

%% include
-include("game_geom.hrl").

%% export
-export([new/2]).
-export([new/3]).
-export([is_point_in/2]).

%% record and define

%% ========================================================================
%% API functions
%% ========================================================================
new(Center, R) when is_record(Center, vector2f) ->
	#circle{
		center = Center
		,r = R 
	}.

new(_Point1 = #vector2f{x = X1, y = Y1}, _Point2 = #vector2f{x = X2, y = Y2}, _Point3 = #vector2f{x = X3, y = Y3}) ->
	MX1 = (X1 + X2) / 2.0,
	MX2 = (X2 + X3) / 2.0,
	MY1 = (Y1 + Y2) / 2.0,
	MY2 = (Y2 + Y3) / 2.0,
	Guard1 = erlang:abs(Y2 - Y1) < ?EPSILON,
	Guard2 = erlang:abs(Y3 - Y2) < ?EPSILON,
	{FinalXC, FinalYC} =
	if
		Guard1 == true ->
			M2 = - (X3 - X2) / (Y3 - Y2),
			XC = (X2 + X1) / 2.0,
			YC = M2 * (XC - MX2) + MY2,
			{XC, YC};
		Guard2 == true ->
			M1 = - (X2 - X1) / (Y2 - Y1),
			XC = (X3 + X2) / 2.0,
			YC = M1 * (XC - MX1) + MY1,
			{XC, YC};
		true ->
			M1 = - (X2 - X1) / (Y2 - Y1),
			M2 = - (X3 - X2) / (Y3 - Y2),
			XC = (M1 * MX1 - M2 * MX2 + MY2 - MY1) / (M1 - M2),
			YC = M1 * (XC - MX1) + MY1,
			{XC, YC}
	end,
	DX = X2 - FinalXC,
	DY = Y2 - FinalYC,
	R = math:sqrt(DX*DX + DY*DY),
	?MODULE:new(vector2f:new(FinalXC, FinalYC), R).

is_point_in(Circle, #vector2f{x = Tx, y = Ty} = _Point) ->
    #circle{center = #vector2f{x = Cx, y = Cy}
            ,r = R} = Circle,
    Dx = Tx - Cx,
    Dy = Ty - Cy,
    Dx * Dx + Dy * Dy < R * R.


%% ========================================================================
%% Local functions
%% ========================================================================


