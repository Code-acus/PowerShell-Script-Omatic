Get-WmiObject Win32_Service | Where-Object {$_.StartMode -eq "Auto" -and $_.PathName -notlike "C:\Windows\*"} | ForEach-Object {
    $_.DisplayName = $_.DisplayName -replace '"','' # remove quotes around display name
    $_.PathName = $_.PathName -replace '"','' # remove quotes around path name
    $_ # output the modified object
} | Format-Table Name, DisplayName, PathName, StartMode -AutoSize

# Language: powershell

# The script uses the Get-WmiObject cmdlet to retrieve information about Windows services. 
# The Where-Object cmdlet is used to filter the results to only include services that have a start mode of "Auto" and whose path name does not start with "C:\Windows".

# The ForEach-Object cmdlet is used to modify each service object by removing any quotes around the display name and path name using the -replace operator.

# Finally, the modified service objects are outputted using the Format-Table cmdlet to display the name, display name, path name, and start mode of each service in a table format.

# Original Source: Justin Belcher 

# wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "C:\\Windows\\" | findstr /i /v """