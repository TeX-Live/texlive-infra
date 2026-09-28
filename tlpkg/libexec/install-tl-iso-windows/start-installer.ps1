### PowerShell script to start install-tl-windows.bat from the
### TeX Live ISO image
##
## Copyright (C) 2026 Vincent Goulet
##
## This file is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published
## by the Free Software Foundation, either version 2 of the License,
## or (at your option) any later version.

param (
    [Parameter(Mandatory=$true)]
    [string]$IsoPath
)

$Installer = "install-tl-windows.bat"

try {
    # Mount the ISO and extract the drive letter assigned by Windows
    $DriveLetter = (Mount-DiskImage -ImagePath $IsoPath -PassThru | Get-Volume).DriveLetter

    if (-not $DriveLetter) {
        throw "Could not retrieve the drive letter for the mounted ISO."
    }

    # Construct the full path to the TeX Live installer
    $InstallerFullPath = Join-Path ("$DriveLetter" + ":") $Installer

    if (Test-Path $InstallerFullPath) {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$InstallerFullPath`"" -Wait -NoNewWindow
    } else {
        Write-Warning "Could not find '$Installer' on drive $DriveLetter."
    }
}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    Dismount-DiskImage -ImagePath $IsoPath
}
