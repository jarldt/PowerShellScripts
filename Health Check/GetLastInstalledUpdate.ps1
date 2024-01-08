<#
===========================================================================

GetLastInstalledUpdate.ps1
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