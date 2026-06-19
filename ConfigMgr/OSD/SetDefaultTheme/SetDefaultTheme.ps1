<#
===========================================================================

SetDefaultTheme.ps1
Copyright (C) 2026 Joshua Arldt

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

<#
===========================================================================

DESCRIPTION
Copies a wallpaper and theme file to their final locations, configures the
Default User profile to use the theme, and disables Windows Spotlight.
Intended for use during Operating System Deployment (OSD).

EXAMPLE
.\SetDefaultTheme.ps1 -Verbose

===========================================================================
#>

[CmdletBinding()]
param()

#------------------------------------------------------------
# Config
#------------------------------------------------------------

$WallpaperSource = ".\CorporateWallpaper.jpg"
$ThemeSource     = ".\CorporateDefault.theme"

$WallpaperFolder = "C:\Windows\Web\Wallpaper\Windows\CompanyName"
$ThemeFolder     = "C:\Windows\Resources\Themes"

$WallpaperDestination = Join-Path $WallpaperFolder "CorporateWallpaper.jpg"
$ThemeDestination     = Join-Path $ThemeFolder "CorporateDefault.theme"

$DefaultUserHivePath = "C:\Users\Default\NTUSER.DAT"
$MountedHiveName     = "HKLM\TempDefault"

#------------------------------------------------------------
# Admin Check
#------------------------------------------------------------

$CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($CurrentIdentity)

if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "This script must be run as Administrator."
}

#------------------------------------------------------------
# Validation
#------------------------------------------------------------

if (-not (Test-Path $WallpaperSource)) {
    throw "Wallpaper file not found: $WallpaperSource"
}

if (-not (Test-Path $ThemeSource)) {
    throw "Theme file not found: $ThemeSource"
}

#------------------------------------------------------------
# Create folders
#------------------------------------------------------------

Write-Verbose "Creating destination folders..."

New-Item -Path $WallpaperFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
New-Item -Path $ThemeFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null

#------------------------------------------------------------
# Copy files
#------------------------------------------------------------

Write-Verbose "Copying wallpaper..."

Copy-Item `
    -Path $WallpaperSource `
    -Destination $WallpaperDestination `
    -Force `
    -ErrorAction Stop

Write-Verbose "Copying theme..."

Copy-Item `
    -Path $ThemeSource `
    -Destination $ThemeDestination `
    -Force `
    -ErrorAction Stop

Write-Verbose "Wallpaper copied to $WallpaperDestination"
Write-Verbose "Theme copied to $ThemeDestination"

#------------------------------------------------------------
# Load Default User Hive
#------------------------------------------------------------

$HiveLoaded = $false

try {

    Write-Verbose "Loading Default User registry hive..."

    & reg.exe load $MountedHiveName $DefaultUserHivePath | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to load Default User registry hive."
    }

    $HiveLoaded = $true

    $ThemeKey     = "Registry::HKEY_LOCAL_MACHINE\TempDefault\Software\Microsoft\Windows\CurrentVersion\Themes"
    $DesktopKey   = "Registry::HKEY_LOCAL_MACHINE\TempDefault\Control Panel\Desktop"
    $SpotlightKey = "Registry::HKEY_LOCAL_MACHINE\TempDefault\Software\Microsoft\Windows\CurrentVersion\DesktopSpotlight\Settings"

    #--------------------------------------------------------
    # Theme Configuration
    #--------------------------------------------------------

    Write-Verbose "Configuring default theme..."

    if (-not (Test-Path $ThemeKey)) {
        New-Item -Path $ThemeKey -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty `
        -Path $ThemeKey `
        -Name "CurrentTheme" `
        -Value $ThemeDestination `
        -ErrorAction Stop

    Set-ItemProperty `
        -Path $ThemeKey `
        -Name "ThemeFile" `
        -Value $ThemeDestination `
        -ErrorAction Stop

    #--------------------------------------------------------
    # Wallpaper Configuration
    #--------------------------------------------------------

    Write-Verbose "Configuring default wallpaper..."

    Set-ItemProperty `
        -Path $DesktopKey `
        -Name "Wallpaper" `
        -Value $WallpaperDestination `
        -ErrorAction Stop

    #--------------------------------------------------------
    # Disable Windows Spotlight
    #--------------------------------------------------------

    Write-Verbose "Disabling Windows Spotlight..."

    if (-not (Test-Path $SpotlightKey)) {
        New-Item -Path $SpotlightKey -Force -ErrorAction Stop | Out-Null
    }

    New-ItemProperty `
        -Path $SpotlightKey `
        -Name "EnabledState" `
        -PropertyType DWord `
        -Value 0 `
        -Force `
        -ErrorAction Stop | Out-Null

    Write-Verbose "Default User profile updated successfully."

}
finally {

    if ($HiveLoaded) {

        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()

        Write-Verbose "Unloading Default User registry hive..."

        & reg.exe unload $MountedHiveName | Out-Null

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to unload Default User registry hive. A reboot may be required."
        }
    }
}

Write-Verbose "Corporate wallpaper configuration completed successfully."
