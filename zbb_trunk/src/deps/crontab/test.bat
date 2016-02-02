@echo off

echo --------- crontab test ------------
cd ../ebin
erl -s cron_test parse -s c q -s init stop
pause
