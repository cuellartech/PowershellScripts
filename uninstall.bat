set "up=%~1"
for /D %%i in ("%up%\appdata\Local\Google\Chrome\Application\*") do (
if exist "%%i\installer\setup.exe" "%%i\installer\setup.exe" --uninstall --multi-install --chrome --verbose-logging --force-uninstall
)
ping 127.0.0.1 -n 10
rd "%up%\appdata\Local\Google\Chrome" /S /Q
del "%up%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk" /F /Q
exit /b 0