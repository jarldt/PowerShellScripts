<#
===========================================================================

ReportServiceAccounts.ps1
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
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$Name
)

$account = $Name

$scriptDir = split-path -parent $MyInvocation.MyCommand.Definition
$summary = @()

<#
====================
TimeStamp

  Get the timestamp for the report
====================
#>
Function TimeStamp() {
    $GetDate = get-date
    return $GetDate
}

<#
====================
SetAlternatingRows

  Sets alternating row colors on HTML output
====================
#>
Function SetAlternatingRows {
    [CmdletBinding()]
   	Param(
       	[Parameter( Mandatory=$True,ValueFromPipeline=$True )]
        [string]$Line,
       
   	    [Parameter( Mandatory=$True )]
       	[string]$CSSEvenClass,
       
        [Parameter( Mandatory=$True )]
   	    [string]$CSSOddClass
   	)
	Begin {
		$ClassName = $CSSEvenClass
	}
	Process {
		If ( $Line.Contains( "<tr>" ) ) {
            $Line = $Line.Replace( "<tr>","<tr class=""$ClassName"">" )
			If ( $ClassName -eq $CSSEvenClass ) {
				$ClassName = $CSSOddClass
			}
			Else {
				$ClassName = $CSSEvenClass
			}
		}
		Return $Line
	}
}
 
#Imports the Active Directory PowerShell module 

Import-Module ActiveDirectory    

# Gets all servers in the domain 

$servers = Get-ADComputer -Filter {OperatingSystem -Like "Windows *Server*"} -property *  

# For Each Server, find services running under the user specified in $Account 

ForEach ( $server in $servers ) { 
	
	$services = get-wmiobject win32_service -computer $server.Name | where-object {$_.StartName -like "*$account*"}  

	# List the services running as $account in the powershell console 

	# If there are no services running under $account, output this to the console. 

	If ( $services -ne $null ) { 

		Write-host $services
		
		foreach ( $service in $Services ) {
			$Record = new-Object -typename System.Object
			$record | add-Member -memberType noteProperty -name "Computer Name" -Value $server.CN
			$record | add-Member -memberType noteProperty -name "Service Name" -Value $service.Name
			$record | add-Member -memberType noteProperty -name "Account Name" -Value $service.StartName
			$summary += $record
		}

	} 

	Elseif ( $services -eq $null ) { 

		Write-Host "No Services found running under $account on Server $server" 

	}  
	
} 

echo $summary #Write the report output
    $timeStamp = ( TimeStamp ).toString( "yyyyMMddHHmm" )
    $timeReport = ( TimeStamp ).toString( "MM/dd/yyyy h:mm tt" )
    $header = @"
    <style> H2 {font:bold 20px Verdana,Arial;} H3 {font:14px Verdana,Arial;} TABLE {border-width: 1px;border-style: none;border-color: black;border-collapse: collapse;} TH {font: bold 12px Verdana, Arial; color: white; border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #0066CC;} TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;} .odd  { background-color:#ffffff; } .even { background-color:#F0F0F0; } </style>
"@
    $summary | convertto-html -Head $header -title "Services Set to Run as the Specified Account" -body "<H2>Services Set to Run as the Specified Account</H2>" -PostContent "<H3>$timeReport</H3>" | SetAlternatingRows -CSSEvenClass even -CSSOddClass odd | Out-File $scriptDir\ReportServiceAccounts_$timeStamp.html