-ifndef(GAME_GEOM_HRL).
-define(GAME_GEOM_HRL,"game_geom.hrl").

-include("game_core.hrl").

-record(vector2f, {
	x = 0
  	,y = 0
}).

-record(line2d, {
	point_a
  	,point_b
	,normal
  	,normal_calculated = false
}).

-record(triangle, {
	center
  	,point_a
  	,point_b
	,point_c
	,sides = []			   
}).

-record(rectangle, {
	x
  	,y
  	,width
  	,height
}).

-record(circle, {
	center
  	,r
}).

-record(polygon, {
	vertex_num
  	,vertexs = []
	,sides = []
}).

-record(path_cell, {		
	index = 0					%% 三角形网格索引
	,seq = 0					%% 网格路径的序号
	,link_array = array:new(3, [{fixed, true}, {default, -1}])		%% 与该三角型连接的三角型索引,-1表示改边没有连接
	,triangle
	,f = 0					%% 权值
	,is_open = false
	,parent = -1			%% 父节点的index
	,arrival_wall = -1		%% 穿出边							
	,wall_distance_array
}).

-record(way_point, {
	cell
	,position					
}).

-define(POINT_ON_LINE, 		0).				%% The point is on, or very near, the line
-define(POINT_LEFT_SIDE, 	1).				%% looking from endpoint A to B, the test point is on the left
-define(POINT_RIGHT_SIDE, 	2).				%% looking from endpoint A to B, the test point is on the right

-define(COLLINEAR,			0).				%% both lines are parallel and overlap each other
-define(LINES_INTERSECT,	1).				%% lines intersect, but their segments do not
-define(SEGMENTS_INTERSECT,	2).				%% both line segments bisect each other
-define(A_BISECTS_B,		3).				%% line segment B is crossed by line A
-define(B_BISECTS_A,		4).				%% line segment A is crossed by line B
-define(PARALELL,			5).				%% the lines are paralell 

-define(EPSILON, 	 0.000001).

-define(TRIANGLE_SIDE_AB,	0).
-define(TRIANGLE_SIDE_BC,	1).
-define(TRIANGLE_SIDE_CA,	2).

-endif.