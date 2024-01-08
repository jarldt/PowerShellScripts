<#
===========================================================================

RemoveFirefox.ps1
Author: Joshua Arldt

===========================================================================
#>

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


function Main() {

    taskkill.exe /f /im firefox.exe

    $x86App  = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object { $_ -match 'Firefox' }

    $x64App = Get-ChildItem 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object { $_ -match 'Firefox' }

    if ( $x86App ) {
        $uninstallPath = ( $x86App | Get-ItemProperty ).UninstallString
        Start-Process -NoNewWindow -FilePath $uninstallPath -ArgumentList ' /s'
    } elseif ( $x64App ) {
        $uninstallPath = ( $x64App | Get-ItemProperty ).UninstallString
        Start-Process -NoNewWindow -FilePath $UninstallPath -ArgumentList ' /s'
    }

    UninstallOldApplication "Mozilla Firefox*"
}

Main