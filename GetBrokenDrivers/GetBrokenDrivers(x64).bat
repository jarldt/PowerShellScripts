@ECHO OFF
CD %WinDir%\SysWOW64\WindowsPowerShell\v1.0
PowerShell.exe -executionPolicy Bypass -noexit %~dp0GetBrokenDrivers.ps1 -SiteCode "CMS"