setlocal
setlocal enabledelayedexpansion
cd %~dp0
cd ..
set PA=
for /d %%i in (deps\*) do @ set PA=!PA! %%i\ebin
start werl ^
    -name game_zbb_s1_38001@127.0.0.1 ^
    -pa ebin %PA% ^
	-setcookie node-cookie ^
	-s server start
exit

PAUSE