# Get all services that have the 'StartMode' set to 'Auto', and the 'PathName' doesn't start with 'C:\Windows'
# Also, make sure the 'Name' and 'DisplayName' properties are not null
$services = Get-CimInstance Win32_Service | 
    Where-Object {$_.StartMode -eq 'Auto' -and $_.PathName -notlike 'C:\Windows*' -and $_.Name -ne $null -and $_.DisplayName -ne $null}

# Check each service to see if the 'PathName' property contains spaces and is not already enclosed in quotes
foreach ($service in $services) {
    if ($service.PathName -match '\s' -and $service.PathName -notmatch '^"(.*)"') {
        # Enclose the 'PathName' property in quotes and update the service
        $quotedPath = '"' + $service.PathName + '"'
        $service.PathName = $quotedPath
        $service.Put()

        Write-Host "The path $($service.PathName) is vulnerable and has been modified with quotes."
    }
}

# Display the list of services that meet the criteria, along with the new 'UnquotedPath' property that has the 'PathName' property without quotes
Get-CimInstance Win32_Service |
    Where-Object {$_.StartMode -eq 'Auto' -and $_.PathName -notlike 'C:\Windows*' -and $_.Name -ne $null -and $_.DisplayName -ne $null} |
    Select-Object Name, DisplayName, PathName, StartMode, @{Name='UnquotedPath';Expression={$_.PathName.Trim('"')}} |
    Format-Table -AutoSize

    <#
    
        This code should identify services with unquoted service paths that contain at least one whitespace and enclose 
        the path in quotes to prevent local attackers from gaining elevated privileges by inserting an executable 
        file in the affected service's path.

        This PowerShell code performs a few tasks related to Windows services. It first filters a list of services to find those that meet specific criteria, then modifies the "PathName" property of any service that has a vulnerable configuration, and finally displays a list of all services that meet the criteria along with an additional "UnquotedPath" property.

        Here is a detailed explanation of each step:

        Step 1:
        $services = Get-CimInstance Win32_Service | 
            Where-Object {$_.StartMode -eq 'Auto' -and $_.PathName -notlike 'C:\Windows*' -and $_.Name -ne $null -and $_.DisplayName -ne $null}
        This code uses the Get-CimInstance cmdlet to retrieve a list of all Windows services, and then pipes the results to the Where-Object cmdlet to filter the list. Specifically, it looks for services that have a "StartMode" property set to "Auto", a "PathName" property that does not start with "C:\Windows", and "Name" and "DisplayName" properties that are not null.

        The results of this filtering operation are stored in the $services variable.

        Step 2:
        foreach ($service in $services) {
            if ($service.PathName -match '\s' -and $service.PathName -notmatch '^"(.*)"') {
                # Enclose the 'PathName' property in quotes and update the service
                $quotedPath = '"' + $service.PathName + '"'
                $service.PathName = $quotedPath
                $service.Put()

                Write-Host "The path $($service.PathName) is vulnerable and has been modified with quotes."
            }
        }
        This code iterates over each service in the $services variable and checks if its "PathName" property contains spaces and is not already enclosed in quotes. If both conditions are true, the "PathName" property is enclosed in quotes by creating a new string with the " characters concatenated to the beginning and end of the original value. The modified "PathName" value is then saved back to the service object using the Put() method, and a message is displayed using the Write-Host cmdlet to indicate that the service has been modified.

        Step 3:
        Get-CimInstance Win32_Service |
            Where-Object {$_.StartMode -eq 'Auto' -and $_.PathName -notlike 'C:\Windows*' -and $_.Name -ne $null -and $_.DisplayName -ne $null} |
            Select-Object Name, DisplayName, PathName, StartMode, @{Name='UnquotedPath';Expression={$_.PathName.Trim('"')}} |
            Format-Table -AutoSize
        This code retrieves the same list of services as in step 1, but this time it adds an additional "UnquotedPath" property to the output. This property contains the value of the "PathName" property with any enclosing quotes removed, which makes it easier to read and compare values.

        The Select-Object cmdlet is used to choose which properties to include in the output and how to format them. The Format-Table cmdlet is then used to display the results in a table format that automatically adjusts the column widths based on the content.
    
    #>