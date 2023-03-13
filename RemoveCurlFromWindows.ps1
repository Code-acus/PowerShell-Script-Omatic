$computers = Get-ADComputer -Filter {OperatingSystem -like "Windows 10*" -or OperatingSystem -like "Windows 11*"} | Select-Object -ExpandProperty Name

ForEach ($computer in $computers) {
    $session = New-PSSession -ComputerName $computer
    Invoke-Command -Session $session -ScriptBlock {
        $curlVersion = (Get-Command curl).FileVersionInfo.ProductVersion
        if ([version]$curlVersion -ge [version]"7.87.0") {
            $uninstallArgs = "/uninstall", "/quiet"
            $uninstallProcess = Start-Process -FilePath "msiexec.exe" -ArgumentList $uninstallArgs -PassThru
            $uninstallProcess.WaitForExit()
        }
    }
    Remove-PSSession -Session $session
}
