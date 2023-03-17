# Define the computer name
$computerName = "YourComputerName"

# Establish a remote PowerShell session
try {
    $session = New-PSSession -ComputerName $computerName
} catch {
    Write-Error "Failed to establish a session with $computerName. $_"
    exit
}

# Disable sethc.exe execution on the remote computer
Invoke-Command -Session $session -ScriptBlock {
    $sethcPath = "$env:SystemRoot\System32\sethc.exe"

    if (Test-Path -Path $sethcPath) {
        try {
            # Rename sethc.exe to prevent its execution
            Rename-Item -Path $sethcPath -NewName "sethc_disabled.exe" -Force
            Write-Host "sethc.exe has been disabled on $env:COMPUTERNAME."
        } catch {
            Write-Error "Failed to disable sethc.exe on $env:COMPUTERNAME. $_"
        }
    } else {
        Write-Warning "sethc.exe not found on $env:COMPUTERNAME."
    }
}

# Close the remote PowerShell session
Remove-PSSession -Session $session
