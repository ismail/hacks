@echo OFF

set TMPFILE=%TMP%\ccl-%RANDOM%-%TIME:~6,5%.exe
clang-cl -fms-compatibility-version=19 /Fe%TMPFILE% /Tp -
IF NOT ERRORLEVEL 1 %TMPFILE%
del %TMPFILE%
