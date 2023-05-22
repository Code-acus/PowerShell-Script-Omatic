# Import the required module
Import-Module Microsoft.Online.SharePoint.PowerShell

# Set SharePoint Site
$SiteUrl = "https://YourDomain.sharepoint.com/sites/YourSite"

# User to be searched
$UserName = "User@YourDomain.com"

# Connect to SharePoint Online
Connect-SPOService -Url $SiteUrl -Credential (Get-Credential)

# Get All SharePoint Online Groups of the Site
$Groups= Get-SPOSiteGroup -Site $SiteUrl

# Check each group
foreach($Group in $Groups)
{
    # Get Users in Group
    $UsersInGroup = Get-SPOSiteGroup -Site $SiteUrl -Identity $Group.Title | Select -ExpandProperty Users
    # Check if user exists in the Group
    foreach($User in $UsersInGroup)
    {
        If($User.LoginName -eq $UserName)
        {
            Write-Host "$UserName is Member of Group:" $Group.Title
        }
    }
}

