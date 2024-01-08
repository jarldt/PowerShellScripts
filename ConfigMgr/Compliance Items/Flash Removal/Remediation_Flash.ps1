<#
===========================================================================

Remediation_Flash.ps1
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

$ErrorActionPreference = "Continue"
$global:scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

Function UninstallOldApplication ( $Description ) {

    Set-Variable -Name ThirtyMachine -Value "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -Option Constant
    Set-Variable -Name SixtyMachine -Value "HKLM:\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall" -Option Constant
    Set-Variable -Name ThirtyUser -Value "HKCU:\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall" -Option Constant
    Set-Variable -Name SixtyUser -Value "HKCU:\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall" -Option Constant

    $regs = $ThirtyMachine,$SixtyMachine,$ThirtyUser,$SixtyUser

    foreach ($reg in $regs) { 
        if(Test-Path $reg){
            $SubKeys = Get-ItemProperty "$reg\*"
        } else {
            $SubKeys = $null
        }
        
        foreach($key in $SubKeys) {
            if($key.DisplayName -match "$Description") {

                Write-Host "Found Software " $key.DisplayName
                if($key.UninstallString -match "^msiexec") {
                    $startGUID = $key.UninstallString.IndexOf("{") + 1
                    $endGuid = $key.UninstallString.IndexOf("}") - $startGUID
                    $stringer = $key.UninstallString.Substring($startGUID,$endGuid)
                    $arguments = "/qn /x {$stringer}"
                    $Code = (Start-Process -FilePath "msiexec.exe" -ArgumentList $Arguments -Wait -Passthru).ExitCode 

                }

            }
        }
    }

}

UninstallOldApplication("Adobe Flash Player")