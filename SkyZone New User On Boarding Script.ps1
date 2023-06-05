# Loading .NET Windows Forms Assembly
try {
    Add-Type -AssemblyName System.Windows.Forms
} catch {
    Write-Host "Error loading .NET Windows Forms Assembly" -ForegroundColor Red
    Exit 1
}

# Function to create user
function Create-MS365User($userPrincipalName, $displayName) {
    try {
        New-MsolUser -UserPrincipalName $userPrincipalName -DisplayName $displayName -Password "<Password>" -ForceChangePassword $false
        Write-Host "Successfully created user $userPrincipalName"
    } catch {
        Write-Host "Error creating user $userPrincipalName" -ForegroundColor Red
    }
}

# Windows Form for Authentication
$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Select a category"
$objForm.Size = New-Object System.Drawing.Size(300,150) 
$objForm.StartPosition = "CenterScreen"

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$objForm.AcceptButton = $OKButton
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$objForm.CancelButton = $CancelButton
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "Please select a category:"
$objForm.Controls.Add($objLabel) 

$objListBox = New-Object System.Windows.Forms.ListBox 
$objListBox.Location = New-Object System.Drawing.Size(10,40) 
$objListBox.Size = New-Object System.Drawing.Size(260,20) 
$objListBox.Height = 80

[void] $objListBox.Items.Add("Corporate User")
[void] $objListBox.Items.Add("General Manager")
[void] $objListBox.Items.Add("Assistant General Manager")
[void] $objListBox.Items.Add("Franchisee")

$objForm.Controls.Add($objListBox) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
$result = $objForm.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $objListBox.SelectedItem
    Write-Host "You selected $x"
    
    # Authenticate to MS365
    try {
        Connect-MsolService
    } catch {
        Write-Host "Error connecting to MS365" -ForegroundColor Red
        Exit 1
    }

    switch ($x) 
    {
        "Corporate User" {
            Create-MS365User "corporate.user@<TenantId>.onmicrosoft.com" "Corporate User"
        }
        "General Manager" {
            Create-MS365User "general.manager@<TenantId>.onmicrosoft.com" "General Manager"
        }
        "Assistant General Manager" {
            Create-MS365User "assistant.general.manager@<TenantId>.onmicrosoft.com" "Assistant General Manager"
        }
        "Franchisee" {
            Create-MS365User "franchisee@<TenantId>.onmicrosoft.com" "Franchisee"
        }
    }
}
