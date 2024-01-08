<#
===========================================================================

MoveUnusedDeviceCollections.ps1
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

$moveCollections = @()
$CollectionList = Get-CmCollection | Where-Object {$_.CollectionID -notlike 'SMS*' -and $_.CollectionType -eq '2'} | Select-Object -Property Name,MemberCount,CollectionID,IsReferenceCollection

$destCollFolder = "$($SiteCode):\DeviceCollection\Archive"

$settings = Get-CMClientSetting
$assignments = Get-CimInstance -Namespace "root\SMS\site_$siteCode" -ClassName "SMS_ClientSettingsAssignment"

foreach ( $Collection in $CollectionList )
{
    #$NumCollectionMembers = $Collection.MemberCount
    $collectionName = $Collection.Name
    $GetDeployment = Get-CMDeployment | Where-Object {$_.CollectionID -eq $Collection.CollectionID}  
    $canBeMoved = 0


    if ( $GetDeployment )
    {
        #Write-Verbose "$collectionName has deployments" -Verbose
        $canBeMoved = 0
    } elseif ( $GetDeployment -eq $null ) {
        Write-Verbose "$collectionName does not have deployments" -Verbose
        $canBeMoved = 1
    }

    foreach( $assignment in $assignments ) {
        $name = ( $settings | Where-Object { $_.SettingsID -eq $assignment.ClientSettingsID } ).Name
        #Write-Output "$name`: $( $assignment.CollectionId ) | $( $assignment.CollectionName )"
        if ( $assignment.CollectionId -eq $Collection.CollectionID ) {
            Write-Verbose "Client Setting: $name is assigned to collection: $collectionName." -Verbose
            $canBeMoved = 0
        }
    }

    if ( $canBeMoved -eq 1 ) {
        Write-Verbose "$collectionName can be moved." -Verbose
        $moveCollections += $Collection.CollectionID
    } else {
        Write-Verbose "$collectionName cannot be moved!" -Verbose
    }
}

try {
    Move-CMObject -ObjectId $moveCollections -FolderPath $destCollFolder
    Write-Verbose "Successfully moved collections." -Verbose
} catch {
    Write-Verbose "ERROR! Failed to move collections." -Verbose
}