<#
===========================================================================

RemoveChrome.ps1
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

$sysDrive = $env:SystemDrive
$path64 = "$sysDrive\Program Files\Google\Chrome\Application"
$path32 = "$sysDrive\Program Files (x86)\Google\Chrome\Application"
$exePath = ''

if ( test-path $path32 ) {
    $exePath = $path32
}

if ( test-path $path64 ) {
    $exePath = $path64
}

if ( $exePath ) {
    $setupExe = Get-ChildItem -path $exePath -recurse | Where-Object { $_.Name -eq 'setup.exe' }

    foreach ( $dir in $setupExe ) {
        $setupExePath = $dir.Directory
        $proc = start-process "$setupExePath\setup.exe" -arg '--uninstall --multi-install --chrome --system-level --force-uninstall' -wait
        $returnCode += $proc
    }
    exit $returnCode
}