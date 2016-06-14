%%-----------------------------------------------------
%% @Module:vector2f 
%% @Author:xiayong
%% @Email:xiayong@yy.com
%% @Created:2014-8-4
%% @Desc:
%%-----------------------------------------------------

-module(vector2f).
-compile(export_all).

-include("game_geom.hrl").
%% ------------------------------------------------------------------------------------------
%% API functions
%% ------------------------------------------------------------------------------------------
-export([
			new/2
			,angle/1
			,length/1
			,length_squared/1
			,distance/2
			,distance_squared/2
			,add/2
			,subtract/2
			,dot/2
			,cross/2
			,mult/2
			,divide/2
			,normalize/1
			,angle_between/2
			,interpolate/3
			,equal/2
		]).

new(X, Y) ->
	#vector2f{x = X, y = Y}.

angle(#vector2f{x = X, y = Y}) ->
	-math:atan2(Y, X).


length(#vector2f{x = X, y = Y}) ->
	math:sqrt(X*X + Y*Y).

length_squared(#vector2f{x = X, y = Y}) ->
	X*X + Y*Y.

distance(#vector2f{x = X, y = Y}, #vector2f{x = TargetX, y = TargetY}) ->
	Dx = X - TargetX,
	Dy = Y - TargetY,
	math:sqrt(Dx*Dx + Dy*Dy).

distance_squared(#vector2f{x = X, y = Y}, #vector2f{x = TargetX, y = TargetY}) ->
	Dx = X - TargetX,
	Dy = Y - TargetY,
	Dx*Dx + Dy*Dy.

add(#vector2f{x = X, y = Y}, #vector2f{x = TargetX, y = TargetY}) ->
	vector2f:new(X+TargetX, Y+TargetY).

subtract(#vector2f{x = X, y = Y}, #vector2f{x = TargetX, y = TargetY}) ->
	vector2f:new(X - TargetX, Y - TargetY).

%% @doc 点积
dot(#vector2f{x = X, y = Y}, #vector2f{x = TargetX, y = TargetY}) ->
	X*TargetX + Y*TargetY.

%% @doc 叉积
cross(#vector2f{x = X, y = Y}, #vector2f{x = TargetX, y = TargetY}) ->
	X*TargetY - TargetX*Y.

mult(#vector2f{x = X, y = Y}, Scalar) ->
	vector2f:new(X*Scalar, Y*Scalar).

divide(#vector2f{x = X, y = Y}, Scalar) ->
	vector2f:new(X/Scalar, Y/Scalar).

normalize(Vector) ->
	case vector2f:length(Vector) of
		Length when Length =/= 0 ->
			vector2f:divide(Vector, Length);
		_ ->
			vector2f:divide(Vector, 1)
	end.

%% @doc Vector到OtherVector的弧度(顺时针为正 逆时针为负)
angle_between(Vector, OtherVector) ->
	vector2f:angle(Vector) - vector2f:angle(OtherVector).


%% @doc 确定两个指定点之间的点。 参数 changeAmnt(比例 0.x) 确定新的内插点相对于参数 pt1 和 pt2 指定的两个端点所处的位置 
%% @doc changeAmnt=0 内插点为{X,Y}
interpolate(#vector2f{x = X, y = Y}, #vector2f{x = TargetX, y = TargetY}, ChangeAmnt) ->
	TempX = (1 - ChangeAmnt) * X + ChangeAmnt * TargetX,
	TempY = (1 - ChangeAmnt) * Y + ChangeAmnt * TargetY,
	vector2f:new(TempX, TempY).

equal(#vector2f{x = X, y = Y}, #vector2f{x = TargetX, y = TargetY}) ->
	Epsilon = 0.000001,
	erlang:abs(X-TargetX) < Epsilon andalso erlang:abs(Y-TargetY) < Epsilon.
%% ------------------------------------------------------------------------------------------
%% Internal functions
%% ------------------------------------------------------------------------------------------


