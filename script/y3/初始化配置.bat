@echo off
xcopy /Y "%~dp0��ʾ\��Ŀ����\extensions.json" "%~dp0..\.vscode\extensions.json"
xcopy /Y "%~dp0��ʾ\��Ŀ����\launch.json" "%~dp0..\.vscode\launch.json"
xcopy /Y "%~dp0��ʾ\��Ŀ����\luarc.json" "%~dp0..\.luarc.json"
cd "%~dp0/.."
md log
pause
