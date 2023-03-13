# Set variables for the script
$resourceGroupName = "your-resource-group-name"
$webAppName = "your-web-app-name"
$slotName = "your-slot-name"
$webAppUrl = "https://$webAppName.azurewebsites.net"
$apiUrl = "https://$webAppName.azurewebsites.net/api/test"

# Connect to Azure using the Azure PowerShell module
Connect-AzAccount

# Get the web app deployment credentials
$creds = Get-AzWebAppDeploymentCredentials -ResourceGroupName $resourceGroupName -Name $webAppName

# Publish the application to Azure using the Azure CLI
az webapp deployment source config-zip -g $resourceGroupName -n $webAppName -s "$(System.DefaultWorkingDirectory)/_your-publish-artifact-name.zip" -u $creds.PublishingUserName -p $creds.PublishingPassword

# Test the publishing of the application in Azure
$statusCode = Invoke-WebRequest -Uri $webAppUrl -Method Get -UseBasicParsing | Select-Object -Expand StatusCode
if ($statusCode -eq 200) {
    Write-Host "Application successfully published to Azure"
} else {
    Write-Error "Application publishing failed with status code: $statusCode"
}

# Test API connectivity to Azure
$apiResponse = Invoke-WebRequest -Uri $apiUrl -Method Get -UseBasicParsing
if ($apiResponse.StatusCode -eq 200) {
    Write-Host "API connectivity to Azure successful"
} else {
    Write-Error "API connectivity to Azure failed with status code: $($apiResponse.StatusCode)"
}
