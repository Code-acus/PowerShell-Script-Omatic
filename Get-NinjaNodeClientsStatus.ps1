# NinjaRMM API key and Base URL
$NinjaApiKey = "your_ninjarmm_api_key"
$NinjaApiBaseUrl = "your_ninjarmm_base_url"

# Define the list of clients to search for
$clientsToSearchFor = @(
    @{
        Name = "Tanium Client"
        ProcessName = "TaniumClient"
    },
    @{
        Name = "Tenable Client"
        ProcessName = "NessusAgent"
    },
    @{
        Name = "Cybereason Client"
        ProcessName = "CybereasonRaccine"
    }
)

function Get-NinjaOnlineDevices {
    param (
        [string]$ApiKey,
        [string]$ApiBaseUrl
    )

    # Set the API request headers
    $headers = @{
        "Authorization" = "Basic $ApiKey"
        "Content-Type"  = "application/json"
    }

    # Send the API request
    $response = Invoke-WebRequest -Uri "$ApiBaseUrl/v2.1/devices" -Headers $headers -Method Get

    # Parse the response JSON
    $devices = $response | ConvertFrom-Json

    # Filter the devices to get only online ones
    $onlineDevices = $devices | Where-Object { $_.online -eq $true }

    return $onlineDevices
}

# Get the list of online devices from NinjaRMM
$onlineDevices = Get-NinjaOnlineDevices -ApiKey $NinjaApiKey -ApiBaseUrl $NinjaApiBaseUrl

# Extract the machine names from the online devices
$machines = $onlineDevices | ForEach-Object { [PSCustomObject]@{ ComputerName = $_.name } }

# Initialize the results array
$results = @()

# Iterate through each machine
foreach ($machine in $machines) {
    $computerName = $machine.ComputerName

    try {
        # Check if the machine is reachable
        $ping = Test-Connection -ComputerName $computerName -Count 1 -ErrorAction Stop

        # Get the list of installed services on the machine
        $services = Get-WmiObject -Class Win32_Service -ComputerName $computerName -ErrorAction Stop

        # Initialize the client statuses
        $clientStatuses = @{}

        # Iterate through the clients to search for
        foreach ($client in $clientsToSearchFor) {
            $clientName = $client.Name
            $processName = $client.ProcessName

            # Check if the client is installed on the machine
            $clientInstalled = $services | Where-Object { $_.Name -eq $processName }

            # Set the client status
            $clientStatuses[$clientName] = if ($clientInstalled) { "Installed" } else { "Not Installed" }
        }

        # Add the result for the machine
        $results += [PSCustomObject]@{
            ComputerName   = $computerName
            Status         = "Online"
            TaniumClient   = $clientStatuses["Tanium Client"]
            TenableClient  = $clientStatuses["Tenable Client"]
            CybereasonClient = $clientStatuses["Cybereason Client"]
        }
    }
    catch {
        # Add the result for an unreachable machine
        $results += [PSCustomObject]@{
            ComputerName   = $computerName
            Status         = "Offline"
            TaniumClient   = "N/A"
            TenableClient  = "N/A"
            CybereasonClient = "N/A"
        }
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "ClientStatusReport.csv" -NoTypeInformation

Write-Host "Client status report generated: ClientStatusReport.csv"
