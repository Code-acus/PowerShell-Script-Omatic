#Parameters
$TeamsListPath = "C:\Temp\teamslist.csv"
$AddMemberListPath = "C:\Temp\AddMemberList.csv"

Try {
#Connect to Microsoft Teams
Connect-MicrosoftTeams

#Read the teams from the CSV
$TeamsList = Import-Csv -Path $TeamsListPath

#Read the users to be added from the CSV
$TeamUsers = Import-Csv -Path $AddMemberListPath

#Iterate through each team from the CSV and add each user to the team
$TeamsList | ForEach-Object {
    Try {
        $TeamID = $_.GroupID
        $TeamDisplayName = $_.DisplayName
        $TeamUsers | ForEach-Object {
            Add-TeamUser -GroupId $TeamID -User $_.Email -Role $_.Role
            Write-host "Added User:"$_.Email "to team:" $TeamDisplayName -f Green
        }
    }
    Catch {
        Write-host -f Red "Error Adding User to the Team:" $_.Exception.Message
    }
}
}
Catch {
write-host -f Red "Error:" $_.Exception.Message
}

# In this modified script, the $TeamsListPath variable points to the "teamslist.csv" 
# file and the $AddMemberListPath variable points to the "AddMemberList.csv" file. 
# The script reads in the teams from "teamslist.csv" and the users to be added from "AddMemberList.csv". 
# It then iterates through each team from the CSV and adds each user to the team. 
# The output now displays the email address of the user being added and the display name of the team they are being added to.

# This PowerShell script is designed to add users to Microsoft Teams groups by reading the team IDs and user details from two CSV files. Let's break down how this script works and what each line of code does.

# #Parameters
# $TeamsListPath = "C:\Temp\teamslist.csv"
# $AddMemberListPath = "C:\Temp\AddMemberList.csv"
# In the first few lines of the script, we define two variables: $TeamsListPath and $AddMemberListPath. 
# These variables represent the file paths of two CSV files that contain the Teams list and the list 
# of users to be added to those Teams respectively.

# Try {
# #Connect to Microsoft Teams
# Connect-MicrosoftTeams
# Next, we use a try block to attempt to connect to Microsoft Teams using the Connect-MicrosoftTeams cmdlet. 
# If the connection fails, the script will jump to the catch block and display an error message.

# #Read the teams from the CSV
# $TeamsList = Import-Csv -Path $TeamsListPath
# After connecting to Microsoft Teams successfully, the script reads the team IDs 
# and display names from the $TeamsListPath CSV file using the Import-Csv cmdlet. 
# This cmdlet takes a path to a CSV file as an argument and returns an array of PowerShell objects representing the data in the CSV.

# #Read the users to be added from the CSV
# $TeamUsers = Import-Csv -Path $AddMemberListPath
# Next, the script reads the details of the users to be added to the teams from the 
# $AddMemberListPath CSV file using the Import-Csv cmdlet.

# #Iterate through each team from the CSV and add each user to the team
# $TeamsList | ForEach-Object {
#     Try {
#         $TeamID = $_.GroupID
#         $TeamDisplayName = $_.DisplayName
#         $TeamUsers | ForEach-Object {
#             Add-TeamUser -GroupId $TeamID -User $_.Email -Role $_.Role
#             Write-host "Added User:"$_.Email "to team:" $TeamDisplayName -f Green
#         }
#     }
#     Catch {
#         Write-host -f Red "Error Adding User to the Team:" $_.Exception.Message
#     }
# }
# This is the most complex part of the script. Here, the script iterates through each team in the 
# $TeamsList array using the ForEach-Object cmdlet. For each team, the script extracts the group 
# ID and display name from the PowerShell object using $_.GroupID and $_.DisplayName. 
# Next, the script uses another ForEach-Object loop to iterate through each user in the $TeamUsers array. 
# For each user, the script calls the Add-TeamUser cmdlet to add the user to the team. 
# The -GroupId parameter specifies the team's ID, the -User parameter specifies the user's email address, 
# and the -Role parameter specifies the user's role in the team (e.g., Member, Owner, etc.).

# After adding a user to a team, the script displays a confirmation message using the Write-Host cmdlet. 
# This message shows the email address of the user added and the display name of the team they were added to. 
# If there's an error during the process, the script will catch it in the catch block and display 
# an error message using Write-Host.

# Catch {
# write-host -f Red "Error:" $_.Exception.Message
# }
# Finally, the script ends with another catch block that catches any exceptions that occur outside of the foreach loops. 
# This catch block displays an error message using Write-Host.