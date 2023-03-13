# Read in the CSV file of computers with Paint and Paint 3D
$computers = Import-Csv -Path "C:\path\to\computers.csv"

# Define a function to remove Paint and Paint 3D
function Remove-Paint {
    $appNames = "Microsoft.MicrosoftPaint", "Microsoft.MSPaint", "Microsoft.MSPaint3D"
    $appNames | ForEach-Object {
        Get-AppxPackage -Name $_ -AllUsers | Remove-AppxPackage -AllUsers
    }
}

# Iterate over the list of computers and remove Paint and Paint 3D
foreach ($computer in $computers) {
    # Check if the computer is running Windows 10 or Windows 11
    if ($computer.OS -match "Windows 10" -or $computer.OS -match "Windows 11") {
        # Use PowerShell remoting to connect to the computer and run the removal function
        Invoke-Command -ComputerName $computer.Name -ScriptBlock ${function:Remove-Paint}
    }
}
