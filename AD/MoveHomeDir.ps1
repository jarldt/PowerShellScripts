<#
===========================================================================

MoveHomeDir.ps1
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

#requires -Module ActiveDirectory
#requires -Module NTFSSecurity
#requires -RunAsAdministrator
#requires -Version 3.0

$global:scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$global:logfile = "$scriptPath\MoveHomeDir.log"
$global:domain = 'contoso'
$global:oldServerPath = '\\server\homedir_old'
$global:newServerPath = '\\server\homedir_new'
$global:users = Get-Content -Path "$scriptPath\users.txt"
$global:disableOldHomeDrive = $false

<#
====================
WriteLog

  Writes messages to the log file.
====================
#>
function WriteLog ( $logString ) {
    Write-Verbose $logString -Verbose
    Add-Content $logFile -Value "$( Get-Date ): $logString"
}

<#
====================
MoveHomeFolder

  Changes a users home direcyory
====================
#>
function MoveHomeFolder ( $UserNames, $OldServerPath, $NewServerPath, $Domain ) {
	
	foreach ( $name in $UserNames ) {
		if ( [bool](Get-ADUser -Filter { samaccountname -eq $name } ) ) {
			WriteLog "Changing the home direcyory for user: $name..."
			try {
				Get-ADUser $name | Set-ADUser -HomeDrive Z: -HomeDirectory "$NewServerPath\$name"
				WriteLog "Successfully changed the home directory for user: $name."
			} catch {
				WriteLog "ERROR: Failed to change the home directory for user: $name."
			}
			
			<#WriteLog "Attempting to grant Administrators permissions to: $OldServerPath\$name..."
			try {
				Set-NTFSOwner -Path "$OldServerPath\$name" -Account Administrators
				WriteLog "Successfully granted Administrators permissions to: $OldServerPath\$name."
			} catch {
				WriteLog "ERROR: Failed to grant Administrators permissions to: $OldServerPath\$name."
			}#>
			sleep 2
			
			WriteLog "Attempting to grant $domain\$name permissions to: $NewServerPath\$name..."
			try {
				Add-NTFSAccess -Path "$NewServerPath\$name" -Account "$domain\$name" -AccessRights FullControl -AccessType Allow -AppliesTo ThisFolderSubfoldersAndFiles
				WriteLog "Successfully granted $domain\$name permissions to: $NewServerPath\$name."
			} catch {
				WriteLog "ERROR: Failed to grant $domain\$name permissions to: $NewServerPath\$name."
			}
			
			if ( $disableOldHomeDrive ) {
				WriteLog "Attempting to restrict access to $OldServerPath\$name for user: $name..."
				try{
					Get-NTFSAccess -Path "$OldServerPath\$name" -Account "$domain\$name" -ExcludeInherited | Remove-NTFSAccess
					Add-NTFSAccess -Path "$OldServerPath\$name" -Account "$domain\$name" -AccessRights Read -AccessType Allow -AppliesTo ThisFolderSubfoldersAndFiles
					WriteLog "Successfully restricted access to $OldServerPath\$name for user: $name."
				} catch {
					WriteLog "Failed to restrict access to $OldServerPath\$name for user: $name."
				}
			}
		}
	}
	
}

<#
====================
Main

  Script entry point.
====================
#>
function Main () {
	WriteLog "Script execution has started."
	MoveHomeFolder $users $oldServerPath $newServerPath $domain
	WriteLog "Script execution has completed."
}

Main