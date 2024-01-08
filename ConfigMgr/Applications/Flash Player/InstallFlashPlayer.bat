taskkill /F /IM iexplore.exe
PowerShell.exe -executionPolicy Bypass %~dp0InstallFlashPlayerActiveX.ps1
COPY /Y "%~DP0mms.cfg" "%WinDir%\System32\Macromed\Flash\"