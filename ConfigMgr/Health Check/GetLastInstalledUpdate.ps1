<#
===========================================================================

GetLastInstalledUpdate.ps1
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

$infoColl = @()

foreach ( $s in $servers ) {
    $update = ( Get-HotFix -ComputerName $s | Sort-Object -Property installedon )[ -1 ]
    $infoObject = New-Object PSObject
    Add-Member -inputObject $infoObject -memberType NoteProperty -name "Server" -value $s
    Add-Member -inputObject $infoObject -memberType NoteProperty -name "Description" -value $update.Description
    Add-Member -inputObject $infoObject -memberType NoteProperty -name "HotFixID" -value $update.HotFixID
    Add-Member -inputObject $infoObject -memberType NoteProperty -name "Installed By" -value $update.InstalledBy
    Add-Member -inputObject $infoObject -memberType NoteProperty -name "Installed On" -value $update.InstalledOn
    $infoColl += $infoObject
}

$infoColl | Export-Csv -path $dir\LastInstalledUpdate_$((Get-Date).ToString('MM-dd-yyyy')).csv -NoTypeInformation