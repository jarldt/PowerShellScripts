<#
===========================================================================

GetEventLogEvents.ps1
Author: Joshua Arldt

===========================================================================
#>
$scriptpath = $MyInvocation.MyCommand.Definition 
$dir = Split-Path $scriptpath

##Configure the list of servers
#defined as array
#$servers = @( "SERVER1", "SERVER2" )
#read from file
$servers = Get-Content "$dir\Serverlist.txt"
$logPath = "$dir\EventLogs"

if ( -Not ( Test-Path -Path $logPath ) ) {
    New-Item -ItemType directory -Path $logPath -Force
}

foreach ( $server in $servers ) {
    $logs = Get-WinEvent -ComputerName $server -ListLog *

    foreach ( $log in $logs ) {
        Get-WinEvent -ComputerName $server -MaxEvents 100 -filterhashtable @{ logname = $log.LogName; level=1,2,3 } -ErrorAction SilentlyContinue | 
        Select-Object LogName,TimeCreated,Id,LevelDisplayName,Message |
        export-csv -append "$logPath\EventLog_$server.csv"
    }
}