# Check if ExchangeOnlineManagement module is installed
if (-not (Get-Module -ListAvailable -Name "ExchangeOnlineManagement")) {
    # Install the module
    try {
        Install-Module -Name "ExchangeOnlineManagement" -Force -AllowClobber -Scope CurrentUser
        Import-Module -Name "ExchangeOnlineManagement"
    }
    catch {
        Write-Output "Failed to install the ExchangeOnlineManagement module. Please make sure you have the necessary permissions and an active internet connection."
        Exit
    }
}
else {
    # Import the module if already installed
    Import-Module -Name "ExchangeOnlineManagement"
}

# Connect to Microsoft 365
try {
    Connect-ExchangeOnline -ErrorAction Stop
}
catch {
    Write-Output "Failed to connect to Microsoft 365. Please make sure you have the necessary permissions and an active internet connection."
    Exit
}

# Define the email address to search for
$targetEmail = "amalie@freedome.no"

# Get all distribution lists
$groups = Get-EXOMailbox -RecipientTypeDetails DistributionGroup

# Search through each distribution list for the target email
foreach ($group in $groups) {
    $members = Get-EXOMailbox -Identity $group.PrimarySmtpAddress -RecipientType Member
    if ($members -contains $targetEmail) {
        Write-Output "Found the email '$targetEmail' in distribution list: $($group.PrimarySmtpAddress)"
    }
}

# Disconnect from Microsoft 365
Disconnect-ExchangeOnline
