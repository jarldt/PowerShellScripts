<#
===========================================================================

ShutdownScript.ps1
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

$min = Get-Date '02:00'
$max = Get-Date '04:00'

$now = Get-Date

if ( $min.TimeOfDay -le $now.TimeOfDay -and $max.TimeOfDay -ge $now.TimeOfDay ) {
    # Falls within the min and max timeframe
    Write-Verbose -Verbose "Current time ($( $now.TimeOfDay )) falls between $( $min.TimeOfDay ) and $( $max.TimeOfDay ). Initiating reboot prompt."
    c:\wilsav_shutdown\ShutdownTool_NoBack.exe /r /f /t:450 /m:180
} else {
    Write-Verbose -Verbose "Current time ($( $now.TimeOfDay )) does not fall between $( $min.TimeOfDay ) and $( $max.TimeOfDay ). Skipping reboot execution."
}