@echo off

:ENV
echo Setting up build environment...
rem use `dir /X` to get the short name(s) when needed.
call %DEV_TOOL_HOME%\setDevelopmentEnvironmentVariables.bat

:BUILD
echo Making executable...
%VS_COMPILER% /Zp4 /O2 /nologo /arch:SSE2 /I. /c %WIN_INCLUDES% %AXON_INCLUDES% /FoMultiClampTelegraph.obj -DMCT_DEBUG ..\src\MultiClampTelegraph.cpp
%VS_LINKER% /nologo /SUBSYSTEM:console MultiClampTelegraph.obj %WIN_LIBS% /OUT:MultiClampTelegraph.exe

echo Making MEX file...
%VS_COMPILER% /Zp4 /O2 /nologo /arch:SSE2 /I. %MATLAB_INCLUDES% /c %WIN_INCLUDES% %AXON_INCLUDES% /FoMultiClampTelegraph.obj -DMATLAB_MEX_FILE ..\src\MultiClampTelegraph.cpp
%VS_LINKER% /nologo /SUBSYSTEM:console MultiClampTelegraph.obj %MATLAB_LIBS% %WIN_LIBS% /DLL /EXPORT:mexFunction /OUT:MultiClampTelegraph.mexw32

echo Making debug version of MEX file...
%VS_COMPILER% /Zp4 /O2 /nologo /arch:SSE2 /I. %MATLAB_INCLUDES% /c %WIN_INCLUDES% %AXON_INCLUDES% /FoMultiClampTelegraph.obj -DMCT_DEBUG -DMATLAB_MEX_FILE ..\src\MultiClampTelegraph.cpp
%VS_LINKER% /nologo /SUBSYSTEM:console MultiClampTelegraph.obj %MATLAB_LIBS% %WIN_LIBS% /DLL /EXPORT:mexFunction /OUT:MultiClampTelegraph_debug.mexw32

:DEPLOY
move MultiClampTelegraph.mexw32 ..\..
move MultiClampTelegraph_debug.mexw32 ..\..

:CLEAN
echo Cleaning...
del MultiClampTelegraph.obj
del MultiClampTelegraph.exp
del MultiClampTelegraph.lib
del MultiClampTelegraph_debug.exp
del MultiClampTelegraph_debug.lib

echo DONE