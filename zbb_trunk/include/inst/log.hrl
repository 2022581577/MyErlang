
-define(OPERATION_INSERT, insert).
-define(OPERATION_REPLACE, replace).

-define(LOG_LOGIN_STEP(AccName, Step, IsNew), srv_log:add_log(log_login_step, ?OPERATION_INSERT, [AccName, Step, IsNew, util:unixtime()])).
