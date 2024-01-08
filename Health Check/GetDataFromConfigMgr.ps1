# Get Site System Servers
Get-CMSiteSystemServer 

# Get Administrative Users
get-cmadministrativeuser | select-object -property @{N='Account Name';E={$_.LogonName}}, @{N='Account Display Name';E={$_.DisplayName}}, @{Name='Role Names';Expression={[string]::join(",", ($_.RoleNames))}} 

# Get Boundaries
# 0 = IP Subnet, 2 = IPv6 Prefix, 3 = IP Address Range, 1 = AD Site
get-cmboundary | select-object -property Value, BoundaryType, DisplayName, GroupCount, CreatedOn

# Get Service Accounts
get-cmaccount | select-object -property @{N='Account Name';E={$_.ItemName}}, @{Name='Role';Expression={[string]::join(",", ($_.AccountUsage))}} 

#Get Distribution Points
$dps = Get-CMDistributionPoint | Select-Object NetworkOsPath | % {($_.NetworkOsPath.Split(“\\”)[-1]).Split(‘.’)[0]}

| Export-Csv c:\scripts\test.txt -notype

#Get Management Points
$mps = Get-CMManagementPoint | Select-Object NetworkOsPath #| % {($_.NetworkOsPath.Split(“\\”)[-1]).Split(‘.’)[0]}


# Expor to CSV

| Export-Csv c:\scripts\test.txt -notype

# Incremental update collections

# The following refresh types exist for ConfigMgr collections
# 6 = Incremental and Periodic Updates
# 4 = Incremental Updates Only
# 2 = Periodic Updates only
# 1 = Manual Update only

$refreshtypes = "4","6"
$CollectionsWithIncrement = Get-CMDeviceCollection | Where-Object {$_.RefreshType -in $refreshtypes}

$Collections = @()

foreach ($collection in $CollectionsWithIncrement) {
    $object = New-Object -TypeName PSobject
    $object| Add-Member -Name CollectionName -value $collection.Name -MemberType NoteProperty
    $object| Add-Member -Name CollectionID -value $collection.CollectionID -MemberType NoteProperty
    $object| Add-Member -Name MemberCount -value $collection.LocalMemberCount -MemberType NoteProperty
    $collections += $object
}

if ($ExportCSV -eq $null) {
        $collections | Out-GridView -Title "Collections with auto incremental update"
    } else {
        $collections | Export-Csv -Path $ExportCSV -NoTypeInformation
    }

$total = $CollectionsWithIncrement.count

Write-Host "You have $total collections with Incremental Update in your environment"

############################################################
# Get last date Windows Updates were installed
############################################################
$Session = New-Object -ComObject Microsoft.Update.Session 
$Searcher = $Session.CreateUpdateSearcher()
$HistoryCount = $Searcher.GetTotalHistoryCount()
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa386532%28v=vs.85%29.aspx
$date = $Searcher.QueryHistory(0,$HistoryCount) | Sort-Object Date desc
$msg = "Last time updates were applied: $($date[0].Date.tostring("f"))"
Write-Output $msg

############################################################
# Get certificates
############################################################
$global:summary = @()

function GetCerts ( $storePath ) {

    $certs = Get-ChildItem -Path Cert:\$storePath -recurse | Where-object { $_.PSIsContainer -eq $false } #Format-List -Property *

    foreach ( $cert in $certs ) {
        $obj = New-Object -TypeName PSObject
	    $obj | Add-Member -MemberType NoteProperty -Name "PSPath" -value $cert.PSPath
	    $obj | Add-Member -MemberType NoteProperty -Name "FriendlyName" -value $cert.FriendlyName
	    $obj | Add-Member -MemberType NoteProperty -Name "Issuer" -value $cert.Issuer
	    $obj | Add-Member -MemberType NoteProperty -Name "NotAfter" -value $cert.NotAfter
	    $obj | Add-Member -MemberType NoteProperty -Name "NotBefore" -value $cert.NotBefore
	    $obj | Add-Member -MemberType NoteProperty -Name "SerialNumber" -value $cert.SerialNumber
	    $obj | Add-Member -MemberType NoteProperty -Name "Thumbprint" -value $cert.Thumbprint
	    $obj | Add-Member -MemberType NoteProperty -Name "DnsNameList" -value $cert.DnsNameList
	    $obj | Add-Member -MemberType NoteProperty -Name "Subject" -value $cert.Subject
	    $obj | Add-Member -MemberType NoteProperty -Name "Version" -value $cert.Version
	    $global:summary += $obj
        $obj = $null
    }
}

function main () {
    GetCerts ( 'LocalMachine\My' )
    GetCerts ( 'LocalMachine\SMS' )
    $summary | Export-Csv -Path "C:\Users\bp_sa.jarldt\Desktop\temp.csv"
}

main


#TODO
#Get OS
#Get Processor
#Get RAM ammount
#Get errors from event viewer
#Check for autostart and autostart delay services that are not running
#Check drives for missing no_sms_on_drive.sms folder if ContentLibray folder does not exist