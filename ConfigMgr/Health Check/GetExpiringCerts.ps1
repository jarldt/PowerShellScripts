<#
===========================================================================

GetExpiringCerts.ps1
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

    $certs = Invoke-Command -ComputerName  $s -ScriptBlock  { Get-ChildItem Cert:\LocalMachine\My  | 

    Where-Object { $_.NotAfter -lt  ( Get-Date ).AddDays( 75 ) } } | ForEach-Object {
    
        [ pscustomobject ]@{
    
            Computername =  $_.PSComputername
            IssuedBy = $_.Issuer
            Subject =  $_.Subject
            Thumbprint = $_.Thumbprint
            ExpiresOn =  $_.NotAfter

            DaysUntilExpired = Switch ( ( New-TimeSpan -End $_.NotAfter ).Days ) {
                { $_  -gt 0 } { $_ }
                Default  { 'Expired' }
            }
        }
    } 

    foreach ( $cert in $certs ){
        $infoObject = New-Object PSObject
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Server" -value $cert.Computername
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "Issued By" -value $cert.IssuedBy
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Subject" -value $cert.Subject
        Add-Member -InputObject $infoObject -memberType NoteProperty -name "Thumbprint" -value $cert.Thumbprint
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Expires On" -value $cert.ExpiresOn
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Days Until Expired" -value $cert.DaysUntilExpired
		$infoColl += $infoObject
    }
}

$infoColl | Export-Csv -path $dir\ExpiringCerts_$((Get-Date).ToString('MM-dd-yyyy')).csv -NoTypeInformation