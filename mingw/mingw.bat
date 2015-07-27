@echo off
IF [%1]==[] (
    set GCC_VERSION=6.0.0
    ) ELSE (
    set GCC_VERSION=%1
    )

set GCC_ROOT=C:\mingw-w64-%GCC_VERSION%

set PATH=%PATH%;%GCC_ROOT%\bin;
