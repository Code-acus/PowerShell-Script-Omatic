# Before proceeding, please note that re-enabling sethc.exe can be a security risk and should only be done if absolutely necessary. 
# PowerShell script that can be used to re-enable sethc.exe:
# To run this script, you will need to have administrative privileges on the computer. 
# Please exercise caution when modifying system files and always have a backup or restore plan in case something goes wrong.
# First, make a backup of the original sethc.exe file

# Run this script with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Backup the sethc.exe file
Copy-Item -Path "C:\Windows\System32\sethc.exe" -Destination "C:\Windows\System32\sethc.exe.bak"

# Rename the cmd.exe file to sethc.exe
Rename-Item -Path "C:\Windows\System32\cmd.exe" -NewName "C:\Windows\System32\sethc.exe"

# Update the security descriptor for the newly renamed sethc.exe file to match the original sethc.exe file
$sd = (Get-Acl -Path "C:\Windows\System32\sethc.exe.bak").Sddl
$acl = Get-Acl -Path "C:\Windows\System32\sethc.exe"
$acl.SetSecurityDescriptorSddlForm($sd)
Set-Acl -Path "C:\Windows\System32\sethc.exe" -AclObject $acl
