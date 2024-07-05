
# Get the list of installed applications and filter for TeamViewer
$installedApps = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*,
    HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.DisplayName -like "*TeamViewer*" }

# Loop through each found installation and uninstall it
foreach ($app in $installedApps) {
    if ($app.UninstallString) {
        if ($app.UninstallString -match "MsiExec.exe") {
            # If the uninstall string contains MsiExec.exe, it's an MSI uninstall
            Write-Host "Uninstalling MSI package: $($app.DisplayName)"
            Start-Process -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/x $($app.PSChildName) /qn /norestart" -Wait
        } else {
            # Otherwise, it's an EXE uninstall
            Write-Host "Uninstalling EXE package: $($app.DisplayName)"
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c $($app.UninstallString) /S" -Wait
        }
    } else {
        Write-Host "No uninstall string found for $($app.DisplayName)"
    }
}

# Wait a moment to ensure all uninstalls are complete
#Start-Sleep -Seconds 10

# Construct the argument list for the new TeamViewer MSI installation
$arguments = "/i TeamViewer_Host.msi /qn CUSTOMCONFIGID=68kxegd APITOKEN=24026441-8TksaR61evCahY1Xmfuz ASSIGNMENTOPTIONS=`"--grant-easy-access`""

# Install the new TeamViewer MSI
Write-Host "Installing new TeamViewer MSI package"
Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList $arguments -Wait

Write-Host "Installation complete" 