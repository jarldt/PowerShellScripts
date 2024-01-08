<#
===========================================================================

Detection_Firefox.ps1
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

$prog32 = "$sysDrive\Program Files\Mozilla Firefox\firefox.exe"

$prog64 = "$sysDrive\Program Files (x86)\Mozilla Firefox\firefox.exe"

if ( ( test-path $prog32 ) -or ( test-path $prog64 ) ) {
    $compliance = $false
   } else {
    $compliance = $true
}

return $compliance