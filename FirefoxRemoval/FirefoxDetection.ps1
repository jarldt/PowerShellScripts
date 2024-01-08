<#
===========================================================================

FirefoxDetection.ps1
Author: Joshua Arldt

===========================================================================
#>

$sysDrive = $env:SystemDrive

$prog32 = "$sysDrive\Program Files\Mozilla Firefox\firefox.exe"

$prog64 = "$sysDrive\Program Files (x86)\Mozilla Firefox\firefox.exe"

if ( ( test-path $prog32 ) -or ( test-path $prog64 ) ) {
    $compliance = $false
   } else {
    $compliance = $true
}

return $compliance