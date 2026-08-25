@echo off
REM make.bat - Wrapper pour ex\u00e9cuter les commandes du Makefile sous Windows
REM Usage: make help, make tf.init

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0make.ps1" %*
exit /b %ERRORLEVEL%
