<#
===========================================================================

Detection_Flash.ps1
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

Function CheckForApplication ( $Description ) {
    $compliance = $true
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
                    $compliance = $false
                }

            }
        }
        return $compliance
    }

$compliant = CheckForApplication("Adobe Flash Player")
return $compliant
