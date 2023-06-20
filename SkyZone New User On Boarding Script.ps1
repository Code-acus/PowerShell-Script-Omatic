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

$selectUserButton = New-Object System.Windows.Forms.Button
$selectUserButton.Location = New-Object System.Drawing.Point(190, 170)
$selectUserButton.Size = New-Object System.Drawing.Size(100, 23)
$selectUserButton.Text = 'Select User'
$selectUserButton.Add_Click({
    # Confirm if the tech is certain
    $confirmationResult = [System.Windows.Forms.MessageBox]::Show("Are you certain you want to create this user?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo)

    if ($confirmationResult -eq 'Yes') {
        $startScriptForm = New-Object System.Windows.Forms.Form
        $startScriptForm.Text = 'Start Script'
        $startScriptForm.Size = New-Object System.Drawing.Size(300, 200)
        $startScriptForm.StartPosition = 'CenterScreen'

        $startScriptButton = New-Object System.Windows.Forms.Button
        $startScriptButton.Location = New-Object System.Drawing.Point(10, 170)
        $startScriptButton.Size = New-Object System.Drawing.Size(100, 23)
        $startScriptButton.Text = 'Start Script'
        $startScriptButton.Add_Click({
            # Start the creation process
            Start-UserCreation $categoryDropdown.SelectedItem.ToString()
            $startScriptForm.Close()
            $startScriptForm.Dispose()
        })
        $startScriptForm.Controls.Add($startScriptButton)
        $startScriptForm.ShowDialog()
    }
})
$userForm.Controls.Add($selectUserButton)

# Instantiate $firstNameBox, $lastNameBox, and $categoryDropdown according to your requirements
$firstNameBox = New-Object System.Windows.Forms.TextBox
$firstNameBox.Location = New-Object System.Drawing.Point(10, 10)
# Continue from the creation of form elements
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

# Show dialog
$userForm.Topmost = $true
$userForm.ShowDialog()

# Create a function for the user creation process
function Start-UserCreation($category) {
    $firstName = $firstNameBox.Text
    $lastName = $lastNameBox.Text

    $email = "$firstName.$lastName@skyzone.com"
    $displayName = "$firstName $lastName"
    $license = $categories[$category]["License"]
    $jobTitle = $categories[$category]["JobTitle"]
    $department = $categories[$category]["Department"]
    $groups = $categories[$category]["Groups"]

    # Call function to create user
    $user = Create-AzureADUser -userPrincipalName $email -displayName $displayName -license $license -jobTitle $jobTitle -department $department -groups $groups

    # Show the user's temporary password
    $password = $user.Password
    $message = "The user $($user.UserPrincipalName) has been created with the temporary password: $password"

    # Show a dialog box with user creation report
    [System.Windows.Forms.MessageBox]::Show($message, "User Created")
}

# Function to create user
function Create-AzureADUser($userPrincipalName, $displayName, $license, $jobTitle, $department, $groups) {
    # User creation parameters
    $userParams = @{
        "UserPrincipalName" = $userPrincipalName
        "DisplayName" = $displayName
        "AccountEnabled" = $true
        "PasswordProfile" = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    }
    $userParams.PasswordProfile.Password = "TemporaryPassword1"  # Please replace this with a real temporary password
    $userParams.PasswordProfile.ForceChangePasswordNextLogin = $true

    # Create the user
    $user = New-AzureADUser @userParams

    # Assign license
    $licenseObject = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
    $licenseObject.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $license -EQ).SkuId
    $licenseAssignment = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
    $licenseAssignment.AddLicenses = $licenseObject

    # Set license, job title, and department
    Set-AzureADUser -ObjectId $user.ObjectId -AssignedLicenses $licenseAssignment -JobTitle $jobTitle -Department $department

    # Add user to groups
    foreach ($group in $groups) {
        Add-AzureADGroupMember -ObjectId (Get-AzureADGroup -SearchString $group).ObjectId -RefObjectId $user.ObjectId
    }

    # Return the user and their temporary password
    return @{
        "UserPrincipalName" = $user.UserPrincipalName
        "Password" = $userParams.PasswordProfile.Password
    }
}

# Trigger the user form
$userForm.ShowDialog() | Out-Null






