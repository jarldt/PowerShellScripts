<#
===========================================================================

RemoveChromeDetectionMethod.ps1
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

$prog32 = "$sysDrive\Program Files\Google\Chrome\Application\chrome.exe"

$prog64 = "$sysDrive\Program Files (x86)\Google\Chrome\Application\chrome.exe"

$path1 = test-path $prog32
$path2 = test-path $prog64

if ( $Path1 -or $path2 ) {
} else {
        write-host "Installed"
}