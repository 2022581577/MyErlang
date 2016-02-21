#! /bin/bash
cd ../ebin
erl -noshell -s cron_test parse -s c q  -s init stop
