<#
===========================================================================

GetEventLogEvents.ps1
Copyright (C) 2024 Joshua Arldt

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

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