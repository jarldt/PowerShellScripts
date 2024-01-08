<#
===========================================================================

ReportOldHomeDirs.ps1
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

$scriptDir = split-path -parent $MyInvocation.MyCommand.Definition
<#
====================
SelectFolderDialog

  Returns the folder selected in the Windows Folder browser dialog
====================
#>
Function SelectFolderDialog {
    param( [string]$Description="Select Folder",[string]$RootFolder="Desktop" )
    [System.Reflection.Assembly]::LoadWithPartialName( "System.windows.forms" ) | Out-Null     
    $objForm = New-Object System.Windows.Forms.FolderBrowserDialog
    $objForm.Rootfolder = $RootFolder
    $objForm.Description = $Description
    $Show = $objForm.ShowDialog()
    If ( $Show -eq "OK" ) {
        Return $objForm.SelectedPath
    } Else {
        Write-Host "Operation cancelled by user."
        Return $null
    }
}
<#
====================
TimeStamp

  Get the timestamp for the report
====================
#>
Function TimeStamp() {
    $GetDate = get-date
    return $GetDate
}
<#
====================
SetAlternatingRows

  Sets alternating row colors on HTML output
====================
#>
Function SetAlternatingRows {
    [CmdletBinding()]
   	Param(
       	[Parameter( Mandatory=$True,ValueFromPipeline=$True )]
        [string]$Line,
       
   	    [Parameter( Mandatory=$True )]
       	[string]$CSSEvenClass,
       
        [Parameter( Mandatory=$True )]
   	    [string]$CSSOddClass
   	)
	Begin {
		$ClassName = $CSSEvenClass
	}
	Process {
		If ( $Line.Contains( "<tr>" ) ) {
            $Line = $Line.Replace( "<tr>","<tr class=""$ClassName"">" )
			If ( $ClassName -eq $CSSEvenClass ) {
				$ClassName = $CSSOddClass
			}
			Else {
				$ClassName = $CSSEvenClass
			}
		}
		Return $Line
	}
}
<#
====================
Main

  Script main routine
====================
#>
Function Main() {
    $summary = @()
    #Get all folder with the zzz_ prefix at the root of the directory and iterate throuh
    $folders = Get-ChildItem -Path $homeDir | ? { $_.Name -like "zzz_*" }
    Foreach ( $folder in $folders ) {
        $Record = new-Object -typename System.Object
        $modRecent = 0
        #Check files in root folder
        $files = dir $folder.FullName -for -rec | ? { $_.LastWriteTime -ge (Get-Date).AddDays(-90) -and !$_.PsIsContainer }
        if ( $files ) {
                $modRecent = 1
        }
        #Recurse through every subfolder
        $subFolders = Get-ChildItem -Path $folder.FullName -Recurse | ? { $_.PSIsContainer }
        Foreach ( $subFolder in $subFolders ){
            $subFiles = dir $subFolder.FullName -for -rec | ? { $_.LastWriteTime -ge (Get-Date).AddDays(-90) -and !$_.PsIsContainer }
            if ( $subFiles ){
                $modRecent = 1
            }
        }
        $record | add-Member -memberType noteProperty -name "Folder Name" -Value $folder.FullName
        If ( $modRecent -eq 1 ) {
            $record | add-Member -memberType noteProperty -name "Modified Files Within 90 Days" -Value "Yes"
        } Else {
            $record | add-Member -memberType noteProperty -name "Modified Files Within 90 Days" -Value "No"
        }
	    $summary += $record
    }
    echo $summary #Write the report output
    $timeStamp = ( TimeStamp ).toString( "yyyyMMddHHmm" )
    $timeReport = ( TimeStamp ).toString( "MM/dd/yyyy h:mm tt" )
    $header = @"
    <style> H2 {font:bold 20px Verdana,Arial;} H3 {font:14px Verdana,Arial;} TABLE {border-width: 1px;border-style: none;border-color: black;border-collapse: collapse;} TH {font: bold 12px Verdana, Arial; color: white; border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #0066CC;} TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;} .odd  { background-color:#ffffff; } .even { background-color:#F0F0F0; } </style>
"@
    $summary | convertto-html -Head $header -title "Home Directories with No Files Modified in Last 90 Days" -body "<H2>Home Directories with No Files Modified in Last 90 Days</H2>" -PostContent "<H3>$timeReport</H3>" | SetAlternatingRows -CSSEvenClass even -CSSOddClass odd | Out-File $scriptDir\Report-HomeDir_Not_Modified_In_90_Days_$timeStamp.html
}
$homeDir = SelectFolderDialog #Can also provide as "C:\HomeDir" for example
If ( $homeDir ) {
    Main
}
exit