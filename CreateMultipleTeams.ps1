# #Create multiple teams 


# try {  
#     #CSV File Path.Change this location accordingly  
#     $filePath = "C:\temp\BulkTEams.csv"  
#     $filepath1 = "c:\temp\gs_list.csv"

#     #read the input file  
#     $loadFile = Import-Csv -Path $filePath  
#     $loadFile1 = Import-Csv -Path $filepath1
#     foreach($row in $loadFile) {  
#         $teamName = $row.  
#         'Team name'  
#         $teamDescription = $row.  
#         'Team description'
#         $teamMail = $row.
#         'Mail'  
#         $teamVisibility = $row.
#         'Visibility'        
#         $teamOwner = $row.
#         'Owner'
#         #create the team with specified parameters  
#         $groupID = New-Team -DisplayName $teamName -MailNickName $teamMail -Owner $teamOwner -Description $teamDescription  -Visibility $teamVisibility  
        
#         #$Group = new-team -DisplayName "Test Bulk Teams5" -MailNickName "TestBulkTeams5" -Description "Teting adding Teams in bulk with PS" -Visibility Private -Owner "Lee.Smith@skyzone.com" 

#         foreach($row1 in $loadFile1) {
#         $email = $row1.
#         'Email'
#         $Role = $row1.
#         'Role'
#         Add-TeamUser -GroupId $GroupID.GroupId -User $Email -Role $Role
#         }

#         Write -Host "Team "  
#         $teamName, " created successfully..."  
#     }  
#     Write -Host $loadFile.Count " teams were created" 
# } catch {  
#     Write -Host "An error occurred:"  
#     Write -Host $_  
# }  

# There are a few issues with the provided PowerShell script:

# The variable $teamName and $teamDescription are not properly assigned as the script ends with a dot . instead of continuing to the next line. This will cause an error when creating the teams.

# The variable $GroupID is not properly assigned because the New-Team cmdlet is not returning an object with a GroupId property. Instead, it returns a Microsoft.TeamFoundation.Core.WebApi.TeamProjectReference object. Therefore, $GroupID.GroupId will not work.

# The Add-TeamUser cmdlet is using $GroupID.GroupId as the group ID, which is incorrect as mentioned in the previous point. It should use $groupID.Id instead.

# Here's a revised version of the script:

try {  
    # CSV File Path. Change this location accordingly  
    $filePath = "C:\temp\BulkTEams.csv"  
    $filepath1 = "c:\temp\gs_list.csv"

    # Read the input files  
    $loadFile = Import-Csv -Path $filePath  
    $loadFile1 = Import-Csv -Path $filepath1
    
    foreach($row in $loadFile) {  
        $teamName = $row.'Team name'  
        $teamDescription = $row.'Team description'
        $teamMail = $row.'Mail'  
        $teamVisibility = $row.'Visibility'        
        $teamOwner = $row.'Owner'

        # Create the team with specified parameters  
        $team = New-Team -DisplayName $teamName -MailNickName $teamMail -Owner $teamOwner -Description $teamDescription -Visibility $teamVisibility  
        
        foreach($row1 in $loadFile1) {
            $email = $row1.'Email'
            $role = $row1.'Role'
            Add-TeamUser -GroupId $team.Id -User $email -Role $role
        }

        Write-Host "Team $teamName created successfully..."  
    }  
    
    Write-Host "$($loadFile.Count) teams were created." 
} 
catch {  
    Write-Host "An error occurred:"  
    Write-Host $_  
}

# The revised script fixes the issues mentioned above and adds better formatting to the output messages.