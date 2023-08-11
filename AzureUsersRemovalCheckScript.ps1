<#
    - Install the AzureAD module if not already installed.
    - Import the AzureAD module.
    - Connect to Azure AD.
    - Process each user based on the following:
        * Remove all licenses.
        * Revoke all Azure sessions.
        * Remove the user from all groups.
        * Prefix the email with "Z_".
        * Reset the password to one Microsoft 365 creates.
        * Block the sign-in of each account.
        * If the user hasn't been terminated (i.e., if they are found), it will ensure all the actions are carried out.
#>

# 1. Check if the AzureAD module is installed and install it if necessary
if (-not (Get-Module -ListAvailable -Name AzureAD)) {
    Install-Module AzureAD -Force -Confirm:$false
}

# Import the AzureAD module
Import-Module AzureAD

# Connect to Azure AD
$cred = Get-Credential
Connect-AzureAD -Credential $cred

# Load users from a CSV file
$users = Import-Csv "path_to_your_csv.csv"

foreach ($userPrincipalName in $users.UserPrincipalName) {
    # Fetch the user based on UPN
    $user = Get-AzureADUser -Filter "UserPrincipalName eq '$userPrincipalName'"

    # If the user exists
    if ($user) {
        # Block user sign-in
        Set-AzureADUser -ObjectId $user.ObjectId -AccountEnabled $false

        # Remove all licenses
        if ($user.AssignedPlans) {
            Set-AzureADUserLicense -ObjectId $user.ObjectId -RemoveLicenses $user.AssignedLicenses
        }

        # Revoke all Azure sessions
        Get-AzureADUserSession -ObjectId $user.ObjectId | ForEach-Object {
            Remove-AzureADUserSession -ObjectId $user.ObjectId -SessionId $_.SessionId
        }

        # Remove the user from all groups
        Get-AzureADUserMembership -ObjectId $user.ObjectId | Where-Object {$_.ObjectType -eq 'Group'} | ForEach-Object {
            Remove-AzureADGroupMember -ObjectId $_.ObjectId -MemberId $user.ObjectId
        }

        # Prefix email with "Z_"
        $newUserPrincipalName = "Z_" + $user.UserPrincipalName
        Set-AzureADUser -ObjectId $user.ObjectId -UserPrincipalName $newUserPrincipalName

        # Reset the password to one Microsoft 365 creates
        $newPassword = Set-AzureADUserPassword -ObjectId $user.ObjectId
        Write-Host "New password for $userPrincipalName is: $newPassword.Password"

        # Remove MFA settings
        $st = New-Object -TypeName Microsoft.Open.AzureAD.Model.StrongAuthenticationRequirement
        $st.RelyingParty = "*"
        $st.State = "Disabled"
        Set-AzureADUser -ObjectId $user.ObjectId -StrongAuthenticationRequirements $st

        Write-Host "Tasks completed for user: $userPrincipalName"
    } else {
        Write-Host "User $userPrincipalName not found!"
    }
}
