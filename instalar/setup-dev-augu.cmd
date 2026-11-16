@echo off
REM Lanzador: corre setup-dev-augu.ps1 sin cambiar la politica de ejecucion del sistema.
REM Uso: doble clic, o desde CMD:  setup-dev-augu.cmd   (o  setup-dev-augu.cmd -Verificar)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-dev-augu.ps1" %*
pause
