# Import the needed modules
Import-Module AzureAD -ErrorAction Stop
Import-Module AzureADPreview -ErrorAction Stop

# Prompt for Office 365 Global Admin
$UserCredential = Get-Credential -Message "Enter your Office 365 Global Admin credentials" -UserName "admin@yourdomain.com"

# Connect to Azure AD using the Global Admin account
Connect-AzureAD -Credential $UserCredential

# Connect to MS Online
Connect-MsolService -Credential $UserCredential

# Create a new form
$userForm = New-Object System.Windows.Forms.Form
$userForm.Text = 'Create User'
$userForm.Size = New-Object System.Drawing.Size(300, 200)
$userForm.StartPosition = 'CenterScreen'

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
$categoryDropdown.Items.AddRange(@("AGM", "GM", "Franchise Users", "New Corporate Users", "Corporate SkyZone Users", "SkyZone GMs"))
$categoryDropdown.SelectedIndex = 0
$userForm.Controls.Add($categoryDropdown)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(10, 170)
$okButton.Size = New-Object System.Drawing.Size(75, 23)
$okButton.Text = 'OK'
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

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(10, 140)
    $okButton.Size = New-Object System.Drawing.Size(75, 23)
    $okButton.Text = 'OK'
    $okButton.Add_Click({
        $confirmationForm.Close()

        # User creation code here
        # Create the user
        $displayName = "$firstName $lastName"
        $userPrincipalName = "$firstName.$lastName@skyzone.com"
        $passwordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        $passwordProfile.Password = "Pass@word1"
        $passwordProfile.ForceChangePasswordNextLogin = $true
        $newUser = New-AzureADUser -DisplayName $displayName -PasswordProfile $passwordProfile -UserPrincipalName $userPrincipalName 
        -AccountEnabled $true -MailNickName $userPrincipalName -UsageLocation US -OtherMails $userPrincipalName -ImmutableId $userPrincipalName

        # Different procedures depending on the category selected
        if ($category -eq "AGM") {
            # Assign properties
            $userProperties = @{
                "title" = "AGM";
                "department" = "O&O Operations";
                "office" = "Remote";
                "usagelocation" = "US";
                "license" = "MS 365 Business Basic";
            }
        } elseif ($category -eq "GM") {
            # Assign properties
            $userProperties = @{
                "title" = "GM";
                "department" = "O&O Operations";
                "office" = "Remote";
                "usagelocation" = "US";
                "license" = "Business Premium License";
            }
        } elseif ($category -eq "Franchise Users") {
            # Assign properties
            $userProperties = @{
                "title" = "Franchise Team Member";
                "department" = "Sky Zone Franchise";
                "office" = "Park Location";
                "usagelocation" = "US";
                "license" = "Exchange Online Plan 1";
            }
        } else {
            # Assign properties
            $userProperties = @{
                "title" = "[Job Title]";
                "department" = "O&O Operations";
                "office" = "Remote";
                "usagelocation" = "US";
                "license" = "Business Premium License";
            }
        }

        # User creation code
        $email = "$firstName.$lastName@skyzone.com"
        $displayName = "$firstName $lastName"

        # Create the user
        New-MsolUser -UserPrincipalName $email -DisplayName $displayName -FirstName $firstName -LastName $lastName -Password  (ConvertTo-SecureString -AsPlainText "P@ssw0rd" -Force) 
        -ForceChangePassword $true

        # Set the user properties
        Set-MsolUser -UserPrincipalName $email -Title $userProperties.title -Department $userProperties.department -Office $userProperties.office 
        -UsageLocation $userProperties.usagelocation 

        # Assign the license
        Set-MsolUserLicense -UserPrincipalName $email -AddLicenses $userProperties.license

        Write-Host "User created with email: $email"
    })
    $confirmationForm.Controls.Add($okButton)

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

        # Show the user creation form again
        $userForm.ShowDialog()
    })
    $confirmationForm.Controls.Add($noButton)

    [void]$confirmationForm.ShowDialog()
})

# Function to generate a random password
function Generate-RandomPassword {
    param (
        [int]$Length = 10
    )

    $characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+'
    $password = ''
    $random = New-Object System.Random

    for ($i = 0; $i -lt $Length; $i++) {
        $index = $random.Next(0, $characters.Length)
        $password += $characters[$index]
    }

    return $password
}

$userForm.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(100, 170)
$cancelButton.Size = New-Object System.Drawing.Size(75, 23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$userForm.Controls.Add($cancelButton)

$userForm.AcceptButton = $okButton
$userForm.CancelButton = $cancelButton

$result = $userForm.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    # The user clicked the 'OK' button on the form.
    # The actual user creation has been handled in the 'OK' button click event handler above.
} else {
    # The user clicked the 'Cancel' button or closed the form.
    Write-Host 'User creation cancelled.'
}


