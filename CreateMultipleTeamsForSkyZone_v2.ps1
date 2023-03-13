try {
    # Set CSV file paths. Change these locations accordingly.
    $teamFilePath = "C:\temp\BulkTeams.csv"
    $memberFilePath = "C:\temp\gs_list.csv"

# Import CSV files as arrays of objects.
$teamData = Import-Csv -Path $teamFilePath
$memberData = Import-Csv -Path $memberFilePath

# Loop through each row in the team data and create a team.
foreach ($teamRow in $teamData) {
    # Get the properties for the new team from the CSV data.
    $teamName = $teamRow.'Team Name'
    $teamDescription = $teamRow.'Team Description'
    $teamMail = $teamRow.'Mail'
    $teamVisibility = $teamRow.'Visibility'
    $teamOwner = $teamRow.'Owner'

    # Create the team with specified parameters.
    $team = New-Team -DisplayName $teamName -MailNickName $teamMail -Owner $teamOwner -Description $teamDescription -Visibility $teamVisibility

    # Loop through each row in the member data and add members to the team.
    foreach ($memberRow in $memberData) {
        # Get the properties for the new team member from the CSV data.
        $memberEmail = $memberRow.'Email'
        $memberRole = $memberRow.'Role'

        # Add the user to the team with specified parameters.
        Add-TeamUser -GroupId $team.GroupId -User $memberEmail -Role $memberRole
    }

    # Write success message for team creation.
    Write-Host "Team $teamName created successfully."
}

# Write a summary message of how many teams were created.
Write-Host "$($teamData.Count) teams were created."

}
catch {
# Write an error message if there was an issue with the script.
Write-Host "An error occurred:`n$($_.Exception.Message)"
}
