%%-----------------------------------------------------
%% @Module:circle 
%% @Author:xiayong
%% @Email:xiayong@yy.com
%% @Created:2014-8-5
%% @Desc:
%%-----------------------------------------------------

-module(circle).

-compile(export_all).

-include("game_geom.hrl").
%% ------------------------------------------------------------------------------------------
%% API functions
%% ------------------------------------------------------------------------------------------
-export([]).

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

%% ------------------------------------------------------------------------------------------
%% Internal functions
%% ------------------------------------------------------------------------------------------


