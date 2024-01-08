<#
===========================================================================

GetBrokenDrivers.ps1
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

param( [ string ]$SiteCode )

$ErrorActionPreference = "Continue"

$global:smsSiteCode = $SiteCode
$global:scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

$regPath1 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\ConfigMgr10\Setup'
$regPath2 = 'HKLM:\SOFTWARE\Microsoft\SMS\Setup'
$regPath3 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\ConfigMgr10\AdminUI\Connection'

if ( Test-Path $regPath1 ) {

    $modulePath = ( Get-ItemProperty $regPath1 -Name "UI Installation Directory" -ErrorAction SilentlyContinue )."UI Installation Directory"

}

if ( Test-Path $regPath2 ) {
    $modulePath = ( Get-ItemProperty $regPath2 -Name "UI Installation Directory" -ErrorAction SilentlyContinue )."UI Installation Directory"
    $global:smsProvider = ( Get-ItemProperty $regPath2 -Name "Provider Location" -ErrorAction SilentlyContinue )."Provider Location"
}

if ( Test-Path $regPath3 ) {
    $global:smsProvider = ( Get-ItemProperty $regPath3 -Name "Server" -ErrorAction SilentlyContinue ).Server
}

Write-Verbose "The SMS Provider is: $global:smsProvider" -Verbose


<#
====================
LogStamp

  Generates the timestamp for a file.
====================
#>
function LogStamp 
{
    $getDate = ( get-date ).toString( ‘yyyyMMddHHmm’ )
    return $getDate
}

$global:timeStamp = LogStamp

<#
====================
Main

  Script entry point.
====================
#>
function Main () {

    $summary = @()

    Write-Verbose 'Retrieving list of drivers from WMI...' -Verbose

    $drivers = Get-WmiObject sms_driver -namespace root\sms\site_$global:smsSiteCode -Computer $global:smsProvider

    foreach ( $driver in $drivers ) {

        Write-Verbose "Testing $driver.LocalizedDisplayName" -Verbose

        if ( Test-Path $driver.ContentSourcePath ) {
            #Do nothing if successful
        } Else {

            $record = new-Object -typename System.Object

            $record | add-Member -memberType noteProperty -Name "CI ID" -Value $driver.CI_ID
            $record | add-Member -memberType noteProperty -Name "Driver Name" -Value $driver.LocalizedDisplayName
            $record | add-Member -memberType noteProperty -Name "Driver Version" -Value $driver.DriverVersion
            $record | add-Member -memberType noteProperty -Name "Driver Class" -Value $driver.DriverClass
            $record | add-Member -memberType noteProperty -Name "Source Path" -Value $driver.ContentSourcePath
            $record | add-Member -memberType noteProperty -Name "New Source Path" -Value ""
            $summary += $record
        }
    }

    if ( $summary ) {

        $summary | Export-Csv -Path $global:scriptPath\GetBrokenDrivers_$global:timeStamp.csv -Encoding ascii -NoTypeInformation

    } else {
        Write-Verbose 'No drivers with broken paths to report.' -Verbose
    }

    Write-Verbose 'The script has finished executing.' -Verbose
}

Main