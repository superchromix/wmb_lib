@ECHO OFF

REM 
REM      Windows "make" script for RHTgrAABB and MS VC6
REM 
REM      Edit IDL_DIR appropriately
REM 
REM 

SETLOCAL

IF "%1" == "" GOTO SET_IDLDIR
SET IDL_DIR=%1
GOTO CONTINUE

:SET_IDLDIR

SET IDL_DIR=c:\progra~1\rsi\idl60
SET IDL_LIBDIR=%IDL_DIR%\bin\bin.x86

:CONTINUE

IF NOT EXIST %IDL_LIBDIR%\idl32.lib GOTO NO_IDL_LIB
IF NOT EXIST %IDL_DIR%\external\export.h GOTO NO_EXPORT_H

cl /Ob2gity /GDd6 -I%IDL_DIR%\external -nologo -DWIN32_LEAN_AND_MEAN -DWIN32 -c RHTgrAABB.c
link /DLL /OUT:RHTgrAABB.dll /DEF:RHTgrAABB.def RHTgrAABB.obj %IDL_LIBDIR%\idl32.lib

@ECHO OFF

GOTO END

:NO_IDL_LIB
ECHO.
ECHO Unable to locate %IDL_LIBDIR%\idl32.lib.
ECHO.
GOTO END

:NO_EXPORT_H
ECHO.
ECHO Unable to locate %IDL_DIR%\external\export.h.
ECHO.

:END

ENDLOCAL


