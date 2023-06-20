<#
    User Account Creation Script
    The following script is designed to create user accounts based on different categories at SkyZone: AGM, GM, Franchise Users, and New Corporate Users. Please ensure that you have an email account, username, and initial password for each user. Additionally, make sure that the following criteria are met:

    Corporate User:
        If a laptop is requested, notify Justin/Josue/David.
        Use Business Premium License. If unavailable, use Office 365 E3.
        If accessories are requested, place an order in Precoro for monitors, docking stations, mouse keyboards, and cables.
        Required information:
        First and last name
        Email: firstname.lastname@skyzone.com
        Email credentials should be sent to the manager (cc on email)
        Job Title: [Job Title]
        Department: O&O Operations
        Office: Remote
        Add manager
        Add to "Remote@skyzone.com" group
        If Power BI is requested, ensure it is added
        Enforce MFA
    GM:
        Use Business Premium License. If unavailable, use Office 365 E3.
        Add Power BI Pro license.
        Required information:
        First and last name
        Email: firstname.lastname@skyzone.com
        Email credentials should be sent to the manager (cc on email)
        Job Title: GM
        Department: O&O Operations
        Office: Remote
        Add manager
        Add to GM Security Group
        Add to Skyzone Operators Group
        Enforce MFA
        Add to Jump and Events Shared Mailbox - Park Inbox (duplicate entry)
    AGM:
        Use MS 365 Business Basic. If unavailable, use Office 365 E1.
        Required information:
        First and last name
        Email: firstname.lastname@skyzone.com
        Email credentials should be sent to the manager (cc on email)
        Job Title: AGM
        Department: O&O Operations
        Office: Remote
        Add manager
        Add to AGM Security Group
        Add to Assistant General Managers
        Enforce MFA
        Add to Jump and Events Shared Mailbox - Park Inbox
        Add to Park SharePoint
    Franchise:
        Some requests go directly to me or Freshdesk.
        Use Exchange Online Plan 1 by default, unless specified in the request.
        Required information:
        First and last name
        Email: firstname.lastname@skyzone.com
        Email credentials should be sent to the requestor (cc on email)
        Job Title: Franchise Team Member
        Department: Sky Zone Franchise
        Office: Park Location
        Enforce MFA
        Add to Park group
        Add to Jump and Events Shared Mailbox - Park Inbox
        Add to Park SharePoint
#>

# Check if the MSOnline module is installed, and if not, install it
if (-not (Get-Module -ListAvailable -Name MSOnline)) {
    if (-not (Get-Module -ListAvailable -Name PowerShellGet)) {
        # PowerShellGet module is not installed, exit with an error
        Write-Host "PowerShellGet module is required to install the MSOnline module. Please install PowerShellGet module." -ForegroundColor Red
        Exit
    }

    # Install the MSOnline module
    Write-Host "Installing MSOnline module..."
    Install-Module -Name MSOnline -Force -AllowClobber
}

# Import the MSOnline module
Import-Module -Name MSOnline -Force

# Create a new form
$userForm = New-Object System.Windows.Forms.Form
$userForm.Text = 'Create User'
$userForm.Size = New-Object System.Drawing.Size(300, 200)
$userForm.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(10, 170)
$okButton.Size = New-Object System.Drawing.Size(75, 23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$userForm.AcceptButton = $okButton
$userForm.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(100, 170)
$cancelButton.Size = New-Object System.Drawing.Size(75, 23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$userForm.CancelButton = $cancelButton
$userForm.Controls.Add($cancelButton)

# Instantiate $firstNameBox, $lastNameBox, and $categoryDropdown according to your requirements
$firstNameBox = New-Object System.Windows.Forms.TextBox
$firstNameBox.Location = New-Object System.Drawing.Point(10, 10)
$firstNameBox.Size = New-Object System.Drawing.Size(100, 20)
$userForm.Controls.Add($firstNameBox)

$lastNameBox = New-Object System.Windows.Forms.TextBox
$lastNameBox.Location = New-Object System.Drawing.Point(120, 10)
$lastNameBox.Size = New-Object System.Drawing.Size(100, 20)
$userForm.Controls.Add($lastNameBox)

$categoryDropdown = New-Object System.Windows.Forms.ComboBox
$categoryDropdown.Location = New-Object System.Drawing.Point(10, 40)
$categoryDropdown.Size = New-Object System.Drawing.Size(210, 20)
# Add your desired categories to the dropdown list
$categoryDropdown.Items.Add("AGM")
$categoryDropdown.Items.Add("GM")
$categoryDropdown.Items.Add("Franchise Users")
$categoryDropdown.Items.Add("New Corporate Users")
$categoryDropdown.Items.Add("Corporate SkyZone Users")
$categoryDropdown.Items.Add("SkyZone GMs")
$categoryDropdown.SelectedIndex = 0
$userForm.Controls.Add($categoryDropdown)

# Prompt for admin credentials
$credentials = Get-Credential

# Connect to AzureAD
Connect-AzureAD -Credential $credentials

# Define user types and associated licenses and properties
$categories = @{
    "AGM" = @{
        "License" = "MS 365 Business Basic"
        "JobTitle" = "AGM"
        "Department" = "O&O Operations"
        "Groups" = @("AGM Security Group", "Assistant General Managers")
    }
    "GM" = @{
        "License" = "Business Premium"
        "JobTitle" = "GM"
        "Department" = "O&O Operations"
        "Groups" = @("GM Security Group", "Skyzone Operators Group")
    }
    "Franchise Users" = @{
        "License" = "Exchange Online Plan 1"
        "JobTitle" = "Franchise Team Member"
        "Department" = "Sky Zone Franchise"
        "Groups" = @("Park Group")
    }
    "New Corporate Users" = @{
        "License" = "MS 365 Business Basic"
        "JobTitle" = "Corporate Team Member"
        "Department" = "Sky Zone Corporate"
        "Groups" = @("Corporate Team Members")
    }
}

# Function to create user
function Create-AzureADUser($userPrincipalName, $displayName, $license, $jobTitle, $department, $groups) {
    # Generate a random password
    $password = [System.Web.Security.Membership]::GeneratePassword(12, 3)

    # Create a password profile
    $passwordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $passwordProfile.Password = $password
    $passwordProfile.ForceChangePasswordNextSignIn = $true

    # Create a user
    $newUser = New-AzureADUser -UserPrincipalName $userPrincipalName -DisplayName $displayName -PasswordProfile $passwordProfile -UsageLocation "US"

    # Set user properties
    Set-AzureADUser -ObjectId $newUser.ObjectId -Title $jobTitle -Department $department

    # Add the user to the specified groups
    foreach ($group in $groups) {
        Add-AzureADGroupMember -ObjectId $group -RefObjectId $newUser.ObjectId
    }

    # Return the user with the temporary password
    $newUser | Select-Object UserPrincipalName, Password
}

# Show dialog
$userForm.Topmost = $true

$result = $userForm.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $firstName = $firstNameBox.Text
    $lastName = $lastNameBox.Text
    $category = $categoryDropdown.SelectedItem.ToString()

    $email = "$firstName.$lastName@skyzone.com"
    $displayName = "$firstName $lastName"
    $license = $categories[$category]["License"]
    $jobTitle = $categories[$category]["JobTitle"]
    $department = $categories[$category]["Department"]
    $groups = $categories[$category]["Groups"]

    # Check if the preferred license is available, if not, fallback to alternative license
    if (!(Get-AzureADSubscribedSku | Where-Object { $_.SkuPartNumber -eq $license })) {
        if ($category -eq "Corporate SkyZone Users" -or $category -eq "SkyZone GMs") {
            $license = "Office 365 E3"
        }
    }

    # Create the user
    $user = Create-AzureADUser -userPrincipalName $email -displayName $displayName -license $license -jobTitle $jobTitle -department $department -groups $groups

    # Show the user's temporary password
    $userForm.Close()
    $userForm.Dispose()

    $password = $user.Password
    $message = "The user $($user.UserPrincipalName) has been created with the temporary password: $password"

    # Show the user's temporary password
    $passwordForm = New-Object System.Windows.Forms.Form
    $passwordForm.Text = 'User Created'
    $passwordForm.Size = New-Object System.Drawing.Size(300, 200)
    $passwordForm.StartPosition = 'CenterScreen'
    $passwordForm.Topmost = $true

    $passwordLabel = New-Object System.Windows.Forms.Label
    $passwordLabel.Location = New-Object System.Drawing.Point(10, 20)
    $passwordLabel.Size = New-Object System.Drawing.Size(280, 20)
    $passwordLabel.Text = 'Temporary Password:'
    $passwordForm.Controls.Add($passwordLabel)

    $passwordBox = New-Object System.Windows.Forms.TextBox
    $passwordBox.Location = New-Object System.Drawing.Point(10, 40)
    $passwordBox.Size = New-Object System.Drawing.Size(260, 20)
    $passwordBox.Text = $password
    $passwordBox.ReadOnly = $true
    $passwordForm.Controls.Add($passwordBox)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(10, 170)
    $okButton.Size = New-Object System.Drawing.Size(75, 23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $passwordForm.AcceptButton = $okButton
    $passwordForm.Controls.Add($okButton)

    $passwordForm.ShowDialog()
    $passwordForm.Dispose()
}

if ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
    $userForm.Close()
    $userForm.Dispose()
}

# Disconnect from AzureAD
Disconnect-AzureAD






