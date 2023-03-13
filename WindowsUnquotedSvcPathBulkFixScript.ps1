# Define the path to the CSV file containing a list of target machines
$csvPath = "C:\Path\To\somename.csv"

# Import the CSV file into an array of objects
$targets = Import-Csv $csvPath

# Define the function to set the service path
function Set-ServicePath {
[CmdletBinding()]
Param(
[Parameter(Mandatory=$true)]
[string]$ServiceName,
[Parameter(Mandatory=$true)]
[string]$ServicePath
)

# Check if the service path contains a space
if ($ServicePath -match "\s") {
    
    # Enclose the service path in quotes
    $fixedPath = '"' + $ServicePath + '"'
    
    # Set the new service path
    Set-Service -Name $ServiceName -DisplayName $ServiceName -ImagePath $fixedPath -ErrorAction Stop

    # Output the result
    Write-Output "Service path fixed for $($ServiceName)"
    }
}

# Loop through each target machine in the CSV file
foreach ($target in $targets) {

    # Connect to the target machine using WMI
    $svc = Get-WmiObject -Class Win32_Service -ComputerName $target.Name -ErrorAction SilentlyContinue

    if ($svc) {
    
        # Loop through each service on the target machine
        foreach ($service in $svc) {
        
            # Check if the service path contains a space
            if ($service.PathName -match "\s") {
                try {
                
                    # Set the service path
                    Set-ServicePath -ServiceName $service.Name -ServicePath $service.PathName
            }
            catch {
                Write-Warning "Failed to fix service path for $($service.Name): $_"
            }
        }
    }
}
else {
    Write-Warning "Failed to connect to $($target.Name)"
    }
}

# The changes made to the script include:
# Adding [CmdletBinding()] to the Set-ServicePath function to enable common parameters like -Verbose and -ErrorAction.
# Adding Mandatory=$true to the ServiceName and ServicePath parameters to make sure they are passed to the function.
# Adding -ErrorAction Stop to the Set-Service command to make sure any errors are caught and displayed.
# Adding -ErrorAction SilentlyContinue to the Get-WmiObject command to suppress any errors related to unreachable machines.
# Adding a try-catch block to the loop that calls the Set-ServicePath function to catch and display any errors related to the service path fix.
# Adding -ErrorAction Stop to the Set-Service command to make sure any errors are caught and displayed.