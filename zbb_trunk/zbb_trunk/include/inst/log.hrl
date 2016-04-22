-ifndef(LOG_HRL).
-define(LOG_HRL,"log.hrl").

-define(OPERATION_INSERT, insert).
-define(OPERATION_REPLACE, replace).

%% ---------------- 直接发到srv_log的 -----------------
-define(LOG_LOGIN_STEP(AccName, Step, IsNew), srv_log:add_log(log_login_step, ?OPERATION_INSERT, [AccName, Step, IsNew, util:unixtime()])).



%% ---------------- 玩家进程内部的log -----------------
-define(LOG_TEST(Test1, Test2), {log_test, ?OPERATION_INSERT, [Test1, Test2, util:unixtime()]}).

-endif.
