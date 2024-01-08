<#
===========================================================================

PartitionServerUEFI.ps1
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

$shell = New-Object -ComObject "WScript.Shell"
 
# Set variables
$DiskPartFile = "X:\Windows\Temp\DiskpartConfig.txt"


<#
====================
Get-MachineType

  Determines if the machines is physical or a VM.
====================
#>
function Get-MachineType() {

    $ComputerName=$env:COMPUTERNAME
    $Credential = [ System.Management.Automation.PSCredential ]::Empty

    foreach ( $computer in $computerName ) {
        Write-Verbose "Checking $computer"
        try {
            $null = [ System.Net.DNS ]::GetHostEntry( $computer )
            $computerSystemInfo = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Computer -ErrorAction Stop -Credential $Credential
            
            switch ( $computerSystemInfo.Model ) {
                
                'Virtual Machine' {
                    $machineType='VM'
                }

                'VMware Virtual Platform' {
                    $machineType='VM'
                }

                'VirtualBox' {
                    $machineType='VM'
                }

                # Xen
                'HVM domU' {
                    $machineType='VM'
                }

                default {
                    $machineType='Physical'
                }
            }

            } catch [ Exception ] {
                Write-Output "$computer`: $( $_.Exception.Message )"
            }
    }
    return $machineType
}

if ( Get-MachineType -eq  'VM' ) {

    $button = $shell.Popup('The drive needs to be formatted before a Task Sequence can run. Proceeding will wipe all local data from all local drives on this VM. Would you like to proceed?',0,"Prepare UEFI VM Drive",48+4)

    # Quit if the Yes button was not pressed.
    if ( $button -ne 6 ) {
        Exit
    }

    
    if ( Get-Volume | Where-Object { $_.DriveLetter -eq 'C' -and $_.DriveType -eq 'Removable' } ) {
        Get-Partition -DriveLetter 'C' | Set-Partition -NewDriveLetter 'U'
    }
    
    # Create contents of DiskPart configuration file
    Write-Output "SELECT DISK 0" | Out-File -Encoding utf8 -FilePath "$DiskpartFile"
    Write-Output "CLEAN" | Out-File -Encoding utf8 -FilePath "$DiskpartFile" -Append
    Write-Output "CONVERT GPT" | Out-File -Encoding utf8 -FilePath "$DiskpartFile" -Append
    Write-Output "CREATE PARTITION EFI SIZE=200" | Out-File -Encoding utf8 -FilePath "$DiskpartFile" -Append
    Write-Output "ASSIGN LETTER=S" | Out-File -Encoding utf8 -FilePath "$DiskpartFile" -Append
    Write-Output "FORMAT QUICK FS=FAT32" | Out-File -Encoding utf8 -FilePath "$DiskpartFile" -Append
    Write-Output "CREATE PARTITION MSR SIZE=128" | Out-File -Encoding utf8 -FilePath "$DiskpartFile" -Append
    Write-Output "CREATE PARTITION PRIMARY" | Out-File -Encoding utf8 -FilePath "$DiskpartFile" -Append
    Write-Output "ASSIGN LETTER=C" | Out-File -Encoding utf8 -FilePath "$DiskpartFile" -Append
    Write-Output "FORMAT QUICK FS=NTFS" | Out-File -Encoding utf8 -FilePath "$DiskpartFile" -Append
    Write-Output "EXIT" | Out-File -Encoding utf8 -FilePath "$DiskpartFile" -Append
    
    # Run DiskPart
    Start-Process -WindowStyle hidden -FilePath "diskpart.exe" -ArgumentList "/s $DiskPartFile" -Wait
}