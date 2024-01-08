<#
===========================================================================

InstallJava.ps1
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
$global:msiFileName64 = "jre1.8.0_16164.msi"
$global:msiFileName32 = "jre1.8.0_161.msi"
$global:processList = @( "iexplorer", "iexplore", "firefox", "chrome", "javaw", "jqs", "jusched" )
$global:os_type_x64 = (Get-WmiObject -Class Win32_ComputerSystem).SystemType -match ‘(x64)’
$global:os_type_x86 = (Get-WmiObject -Class Win32_ComputerSystem).SystemType -match ‘(x86)’

<#
====================
UninstallOldApplication

  Remove previous installations of an application. Only works for MSI packages.
====================
#>
function UninstallOldApplication ( $Description ) {

    Set-Variable -Name ThirtyMachine -Value "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -Option Constant
    Set-Variable -Name SixtyMachine -Value "HKLM:\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall" -Option Constant
    Set-Variable -Name ThirtyUser -Value "HKCU:\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall" -Option Constant
    Set-Variable -Name SixtyUser -Value "HKCU:\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall" -Option Constant

    $regs = $ThirtyMachine,$SixtyMachine,$ThirtyUser,$SixtyUser

    foreach ( $reg in $regs ) { 
        if( Test-Path $reg ){
            $SubKeys = Get-ItemProperty "$reg\*"
        } else {
            $SubKeys = $null
        }
        
        foreach( $key in $SubKeys ) {
            if( $key.DisplayName -like "$Description" ) {
                $keyDisplayName = $key.DisplayName
                Write-Verbose "Found Software $keyDisplayName" -Verbose
                if( $key.UninstallString -match "^msiexec" ) {
                    $startGUID = $key.UninstallString.IndexOf( "{" ) + 1
                    $endGuid = $key.UninstallString.IndexOf( "}" ) - $startGUID
                    $stringer = $key.UninstallString.Substring( $startGUID,$endGuid )
                    Write-Verbose "Uninstaller Known, now uninstalling" -Verbose
                    $arguments = "/qn /x {$stringer}"
                    $code = ( Start-Process -FilePath "msiexec.exe" -ArgumentList $Arguments -Wait -Passthru ).ExitCode 

                }

            }
        }
    }
    return $code
}

<#
====================
Main

  Script entry point.
====================
#>
function main () {

    # Kill the processes
    foreach ( $process in $processList ) {
		TASKKILL /IM $process /T /F
    }

    # Uninstall previous versions
    UninstallOldApplication "Java(TM) ? Update*"
    UninstallOldApplication "Java ? Update*"

    if ( $os_type_x64 ) {
        $arguments = '/I "' + $scriptPath + '\' + $msiFileName64 + '" /qn'
        try {
            $code1 = ( Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru ).ExitCode
        } catch {
            [System.Environment]::Exit(1)
        }
    } 
    
    if ( $os_type_x86 ) { # ( ( $os_type_x86 ) -OR ( $os_type_x64 ) )
        $arguments = '/I "' + $scriptPath + '\' + $msiFileName32 + '" /qn'
        try {
            $code2 = ( Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru ).ExitCode
        } catch {
            [System.Environment]::Exit(1)
        }
    }

    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v SunJavaUpdateSched /f
    reg add "HKEY_LOCAL_MACHINE\Software\JavaSoft\Java Update\Policy" /v EnableJavaUpdate /t REG_DWORD /d 0 /f

}

$exitCode = main

Write-Verbose "Setup completed with exit code: $exitCode" -Verbose
[System.Environment]::Exit(0)