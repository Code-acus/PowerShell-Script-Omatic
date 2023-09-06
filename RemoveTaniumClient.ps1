# PowerShell Script to Uninstall Tanium Client

try {
    # Query the registry to find installed programs
    $installedPrograms = Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
        -ErrorAction Stop

    # Search for Tanium Client
    $tanium = $installedPrograms | Where-Object { $_.DisplayName -eq "Tanium Client" }

    # If Tanium Client is found, uninstall it
    if ($tanium) {
        $uninstallString = $tanium.UninstallString

        Write-Host "Found Tanium Client. Uninstalling..."

        # Execute the uninstall command
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallString /quiet /norestart" -Wait -PassThru
        Write-Host "Tanium Client has been uninstalled."
    }
    else {
        Write-Host "Tanium Client not found. No action taken."
    }
}
catch {
    Write-Host "An error occurred: $_"
}
