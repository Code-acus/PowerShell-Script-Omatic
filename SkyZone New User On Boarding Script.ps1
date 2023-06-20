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
#># Check if the MSOnline module is installed, if not, install it
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

# Get credentials for Azure AD
$cred = Get-Credential -Message "Enter your Azure AD credentials"

# Connect to Azure AD
Connect-MsolService -Credential $cred

# Create a new form
$userForm = New-Object System.Windows.Forms.Form
$userForm.Text = 'Create User'
$userForm.Size = New-Object System.Drawing.Size(300, 200)
$userForm.StartPosition = 'CenterScreen'

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
$categoryDropdown.Items.AddRange(@("AGM", "GM", "Franchise Users", "New Corporate Users", "Corporate SkyZone Users", "SkyZone GMs"))
$categoryDropdown.SelectedIndex = 0
$userForm.Controls.Add($categoryDropdown)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(10, 170)
$okButton.Size = New-Object System.Drawing.Size(75, 23)
$okButton.Text = 'OK'
$userForm.Controls.Add($okButton)

$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Location = New-Object System.Drawing.Point(100, 170)
$resetButton.Size = New-Object System.Drawing.Size(75, 23)
$resetButton.Text = 'Reset'
$userForm.Controls.Add($resetButton)

# Event handler for the OK button click
$okButton.Add_Click({
    $category = $categoryDropdown.SelectedItem.ToString()
    $firstName = $firstNameBox.Text
    $lastName = $lastNameBox.Text

    $confirmationForm = New-Object System.Windows.Forms.Form
    $confirmationForm.Text = 'Confirmation'
    $confirmationForm.Size = New-Object System.Drawing.Size(300, 200)
    $userForm.StartPosition = 'CenterScreen'

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
$categoryDropdown.Items.AddRange(@("AGM", "GM", "Franchise Users", "New Corporate Users", "Corporate SkyZone Users", "SkyZone GMs"))
$categoryDropdown.SelectedIndex = 0
$userForm.Controls.Add($categoryDropdown)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(10, 170)
$okButton.Size = New-Object System.Drawing.Size(75, 23)
$okButton.Text = 'OK'
$userForm.Controls.Add($okButton)

$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Location = New-Object System.Drawing.Point(100, 170)
$resetButton.Size = New-Object System.Drawing.Size(75, 23)
$resetButton.Text = 'Reset'
$userForm.Controls.Add($resetButton)

# Event handler for the OK button click
$okButton.Add_Click({
    $category = $categoryDropdown.SelectedItem.ToString()
    $firstName = $firstNameBox.Text
    $lastName = $lastNameBox.Text

    $confirmationForm = New-Object System.Windows.Forms.Form
    $confirmationForm.Text = 'Confirmation'
    $confirmationForm.Size = New-Object System.Drawing.Size(300, 200)
    $confirmationForm.StartPosition = 'CenterScreen'

    $confirmationLabel = New-Object System.Windows.Forms.Label
    $confirmationLabel.Location = New-Object System.Drawing.Point(10, 20)
    $confirmationLabel.Size = New-Object System.Drawing.Size(280, 120)
    $confirmationLabel.Text = "Are you sure you want to create the user with these details:`nFirst Name: $firstName`nLast Name: $lastName`nUser Type: $category"
    $confirmationForm.Controls.Add($confirmationLabel)

    $yesButton = New-Object System.Windows.Forms.Button
    $yesButton.Location = New-Object System.Drawing.Point(10, 140)
    $yesButton.Size = New-Object System.Drawing.Size(75, 23)
    $yesButton.Text = 'Yes'
    $yesButton.Add_Click({
        $confirmationForm.Close()

        $runScriptForm = New-Object System.Windows.Forms.Form
        $runScriptForm.Text = 'Run Script'
        $runScriptForm.Size = New-Object System.Drawing.Size(300, 150)
        $runScriptForm.StartPosition = 'CenterScreen'

        $runScriptLabel = New-Object System.Windows.Forms.Label
        $runScriptLabel.Location = New-Object System.Drawing.Point(10, 20)
        $runScriptLabel.Size = New-Object System.Drawing.Size(280, 60)
        $runScriptLabel.Text = "Press OK to run the script and create the user with these details:`nFirst Name: $firstName`nLast Name: $lastName`nUser Type: $category"

        $yesButton.Add_Click({
            $confirmationForm.Close()
        
            $runScriptForm = New-Object System.Windows.Forms.Form
            $runScriptForm.Text = 'Run Script'
            $runScriptForm.Size = New-Object System.Drawing.Size(300, 150)
            $runScriptForm.StartPosition = 'CenterScreen'
        
            $runScriptLabel = New-Object System.Windows.Forms.Label
            $runScriptLabel.Location = New-Object System.Drawing.Point(10, 20)
            $runScriptLabel.Size = New-Object System.Drawing.Size(280, 60)
            $runScriptLabel.Text = "Press OK to run the script and create the user"
            $runScriptForm.Controls.Add($runScriptLabel)
        
            $runScriptOkButton = New-Object System.Windows.Forms.Button
            $runScriptOkButton.Location = New-Object System.Drawing.Point(100, 100)
            $runScriptOkButton.Size = New-Object System.Drawing.Size(75, 23)
            $runScriptOkButton.Text = 'OK'
            $runScriptOkButton.Add_Click({
                $runScriptForm.Close()
        
                # Trim any spaces from first and last names for email
                $firstName = $firstName.Trim()
                $lastName = $lastName.Trim()
        
                # User creation code
                $email = "$firstName.$lastName@skyzone.com"
                $displayName = "$firstName $lastName"
                
                # You should replace the following placeholder with your own user creation commands
                # This is a dummy line, you need to include a way to create a secure random password and update the password variable.
                $password = 'YourGeneratedPassword' 
        
                # Create the user
                New-MsolUser -UserPrincipalName $email -DisplayName $displayName -FirstName $firstName -LastName $lastName -Password $password
        
                Write-Host "User created with email: $email"
            })
            $runScriptForm.Controls.Add($runScriptOkButton)
        
            [void]$runScriptForm.ShowDialog()
        })
        
        $noButton = New-Object System.Windows.Forms.Button
        $noButton.Location = New-Object System.Drawing.Point(100, 140)
        $noButton.Size = New-Object System.Drawing.Size(75, 23)
        $noButton.Text = 'No'
        $noButton.Add_Click({
            $confirmationForm.Close()
        
            # Reset the form
            $firstNameBox.Text = ""
            $lastNameBox.Text = ""
            $categoryDropdown.SelectedIndex = 0
        })
        $confirmationForm.Controls.Add($noButton)
        
        [void]$confirmationForm.ShowDialog()
        
        })
        
        # Event handler for the Reset button click
        $resetButton.Add_Click({
            # Reset the form
            $firstNameBox.Text = ""
            $lastNameBox.Text = ""
            $categoryDropdown.SelectedIndex = 0
        })
        
        $userForm.ShowDialog()
        








