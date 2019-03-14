@echo off

rem https://docs.godotengine.org/en/3.0/tutorials/plugins/gdnative/gdnative-c-example.html

rem requires that TCC on path!

rem echo|set /p="compile: 'simple' ..."
echo compile: 'simple' ...
tcc -I ".\\godot_headers" -o ".\\simple\\bin\\libsimple.dll" -shared ".\\simple\\src\\simple.c" rem > NUL
rem if errorlevel 0 (
rem 	echo  done
rem )

echo "all tasks done!"