@echo off
setlocal enabledelayedexpansion

set lib_src_base=..\..\..\
set trd_base=..\..\3rd\vs2022
set bin_base=..\..\bin\

if not exist %bin_base% (
    echo %bin_base% not exist
    goto :error
)

set lib_name=libflow
if exist %lib_src_base%%lib_name% (
    xcopy %lib_src_base%%lib_name%\bin %bin_base% /S /Y /C
) else if exist %trd_base%%lib_name% (
    xcopy %trd_base%%lib_name%\lib %bin_base% /S /Y /C
) else (
    echo please put https://github.com/Lujiang0111/%lib_name% sourece in %lib_src_base%%lib_name% or lib in %trd_base%%lib_name%
    goto :error
)

endlocal
exit /b 0

:error
endlocal
exit /b 1