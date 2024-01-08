<#
===========================================================================

DetectLyncOAuthUsed.ps1
Author: Joshua Arldt

===========================================================================
#>

$keys = ( Get-ChildItem 'REGISTRY::HKEY_USERS\' )
$compliance = 'Yes'

foreach ( $key in $keys ) {
    $regPath = $key.PSPath + '\Software\Microsoft\Office\16.0\Lync\'

    if ( Test-Path $regPath ) {
        $subKeys = ( Get-ChildItem $regPath )
        $sipKey = $subKeys | Where-Object { $_.PSChildName -Like '*.com' }

        if ( $sipKey ) {
            $regValue = Get-ItemProperty -Path $sipKey.PSPath -Name 'OAuthUsed'

            if ( $regValue.OAuthUsed -eq 0 ) {
                # Return noncompliant
                $compliance = 'No'
            }
        }
    }
}

$compliance