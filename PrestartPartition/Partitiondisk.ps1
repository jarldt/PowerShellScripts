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