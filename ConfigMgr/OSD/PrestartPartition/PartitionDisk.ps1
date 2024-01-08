<#
===========================================================================

PartitionDisk.ps1
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

$computerSystem = Get-WMIObject –class Win32_ComputerSystem
$manufacturer = $computerSystem.Manufacturer

if ($manufacturer -like "VMware*"){

((@"
select disk 0
Clean
Convert gpt
Create partition efi size=200
Assign letter=s
Format quick fs=FAT32
Create partition msr size=128
Create Partition Primary
Select Partition 3
Assign letter=c
Format quick fs=NTFS
exit
"@
)|diskpart)
} else {
    exit
}