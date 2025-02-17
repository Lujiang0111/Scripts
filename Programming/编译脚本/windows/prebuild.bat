@echo off
setlocal enabledelayedexpansion

set lib_src_base=..\..\..\
set trd_base=..\..\3rd\vs2022
set dep_base=dep\
set bin_base=..\..\bin\

rmdir /Q /S %bin_base%
rmdir /Q /S %dep_base%

mkdir %dep_base%include
mkdir %dep_base%lib

set lib_name=libflow
if exist %lib_src_base%%lib_name% (
    mkdir %dep_base%include\%lib_name%
    xcopy %lib_src_base%%lib_name%\include %dep_base%include\%lib_name% /S /Y /C
    xcopy %lib_src_base%%lib_name%\bin %dep_base%lib /S /Y /C
) else if exist %trd_base%%lib_name% (
    mkdir %dep_base%include\%lib_name%
    xcopy %trd_base%%lib_name%\include %dep_base%include\%lib_name% /S /Y /C
    xcopy %trd_base%%lib_name%\lib %dep_base%lib /S /Y /C
) else (
    echo please put https://github.com/Lujiang0111/%lib_name% sourece in %lib_src_base%%lib_name% or lib in %trd_base%%lib_name%
    goto :error
)

endlocal
exit /b 0

:error
endlocal
exit /b 1