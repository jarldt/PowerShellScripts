<#
===========================================================================

Detection_LyncOAuthUsed.ps1
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