@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\link-seguro-refeito\stop_all.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\link-seguro-refeito\start_all.ps1"
pause

