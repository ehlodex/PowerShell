<#
  .SYNOPSIS
  Bootstraps a Windows 10/11 PC with common applications and settings
  
  .DESCRIPTION
    The bootstrap.ps1 script contains the basic software components for a manual deployment.
    
    This script does not have any parameters, as it is meant to be a fully automatic process.
    
    Please customize this script to meet the needs of your environment!

  .EXAMPLE
    .\bootstrap.ps1 -Restart

  .LINK
    https://technet.microsoft.com/en-us/library/hh847834.aspx
  
  .NOTES
    Updated 2023.10 by: Joshua Burkholder [ehlodex]
#>

[CmdletBinding()] Param( [switch]$Restart );

Write-Verbose "Housekeeping"                                                                                                    # # Housekeeping
Set-StrictMode -Version Latest
If ($PsBoundParameters['Verbose']) { $PSVE = $TRUE; } Else {$PSVE = $FALSE; }
If ($PsBoundParameters['Debug'])   { $PSDE = $TRUE; } Else {$PSDE = $FALSE; }

Write-Verbose "Checking if PowerShell is elevated"                                                                              # # Elevated Check
$WindowsIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$WindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($WindowsIdentity)
$Administrator=[System.Security.Principal.WindowsBuiltInRole]::Administrator
$Elevated=$WindowsPrincipal.IsInRole($Administrator)
If (! $Elevated) { Write-Error "Administrative rights required! Please elevate PowerShell then try again."; Exit 1; }

Write-Verbose "Setting script-specific variables"                                                                               # # Variables
$RestartDelayInSeconds = 30
$RemoveFeatures     = @("Printing-Foundation", "Printing-XPSServices", "WorkFolders-Client")
$RemoveCapabilities = @("Browser.InternetExplorer", "Hello.Face", "SNMP.Client", "WMI-SNMP-Provider.Client", "XPS.Viewer")
$RemoveAppxPackages = @("GetStarted", "Microsoft3DViewer", "MicrosoftOfficeHub", "MicrosoftTeams", "MixedReality", "OneConnect", "OneNote", "Print3D", "SkypeApp", "WindowsCommunicationsApps", "WindowsFeedbackHub", "Xbox", "ZuneMusic")
$RemovePrinters     = @("OneNote", "Fax")
$RemoveLocalUsers   = @("Setup User", "tempadmin", "localuser")

<# Chocolatey
Write-Verbose "Preparing to install Chocolatey and refresh the PowerShell environment"                                          # # Install Chocolatey + Apps
Set-ExecutionPolicy Bypass -Scope Process -Force -Verbose:$PSVE -Debug:$PSDE
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); refreshenv
  choco install -y 7zip
  choco install -y vlc

$SchTaskAction   = New-ScheduledTaskAction -Execute 'choco.exe' -Argument 'upgrade all -y' -WorkingDirectory "C:\ProgramData\chocolatey"
$SchTaskTrigger  = New-ScheduledTaskTrigger -Daily -At 2am
$SchTaskSettings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 2) -DontStopIfGoingOnBatteries -StartWhenAvailable

Write-Verbose "Creating Scheduled Task for Chocolaty Unattended Upgrades"                                                       # # Chocolatey Scheduled Task
Register-ScheduledTask -User SYSTEM -RunLevel Highest -Verbose:$PSVE -Debug:$PSDE `
  -Action $SchTaskAction `
  -Trigger $SchTaskTrigger `
  -Settings $SchTaskSettings `
  -TaskPath "CUSTOM" `
  -TaskName "Chocolatey Upgrade Daemon" `
  -Description "Unattended upgrade for chocolatey apps"
#>


Write-Verbose "Adding registry key for `'Console lock display off timeout`' in `'Power Options`'"                               # # Lock screen timeout (regedit)
New-ItemProperty -Name "Attributes" -Value 2 -PropertyType "Dword" -Force `
  -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\7516b95f-f776-4464-8c53-06167f40cc99\8EC4B3A5-6868-48c2-BE75-4F3044BE88A7"

Write-Verbose "Preparing to remove unwanted Windows Optional Features"                                                          # # windows Optional Features
ForEach ($Feature in $RemoveFeatures) {
  Get-WindowsOptionalFeature -Online | 
    Where-Object {$_.FeatureName -like "*$Feature*"} | 
      Disable-WindowsOptionalFeature -Online -Verbose:$PSVE -Debug:$PSDE -NoRestart
}

Write-Verbose "Preparing to remove unwanted Windows Capabilities"                                                               # # Windows Capabilities
ForEach ($Capability in $RemoveCapabilities) {
  Get-WindowsCapability -Online | 
    Where-Object {($_.Name -like "*$Capability*") -and ($_.State -eq 'Installed')} |
      Remove-WindowsCapability -Online -Verbose:$PSVE -Debug:$PSDE
}

Write-Verbose "Preparing to remove unwanted AppX Packages (Windows Store)"                                                      # # AppX Packages
ForEach ($Package in $RemoveAppxPackages) {
  Get-AppxProvisionedPackage -Online | 
    Where-Object {$_.DisplayName -like "*$Package*"} | 
      Remove-AppxProvisionedPackage -Online -Verbose:$PSVE -Debug:$PSDE -ErrorAction SilentlyContinue
  Get-AppxPackage -AllUsers | 
    Where-Object {$_.Name -like "*$Package*"} | 
      Remove-AppxPackage -AllUsers -Confirm:$FALSE -Verbose:$PSVE -Debug:$PSDE -ErrorAction SilentlyContinue
}

Write-Verbose "Preparing to remove unwanted built-in printers"                                                                  # # Remove Printers
ForEach ($Printer in $RemovePrinters) {
  Remove-Printer -Name "*$Printer*" -Confirm:$FALSE -Verbose:$PSVE -Debug:$PSDE
}

Write-Verbose "Cleaning up local accounts"                                                                                      # # Local Account Cleanup
ForEach ($Username in $RemoveLocalUsers) {
  $LocalUser = Get-LocalUser $Username -ErrorAction SilentlyContinue
  # If the user exists locally...
  If ($LocalUser) {
    $UserRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($LocalUser.SID)"
    # Delete the profile data from registry
    If ((Test-Path $UserRegistryPath) -and ($UserRegistryPath -ne "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\")) {
      $UserProfilePath = Get-ItemPropertyValue $UserRegistryPath ProfileImagePath
      Remove-Item $UserRegistryPath -Force -Confirm:$False
    }
    # Delete the user profile folder (usually at C:\Users\)
    If ((Test-Path variable:UserProfilePath) -and (Test-Path $UserProfilePath)) {
      Get-ChildItem -Path $UserProfilePath -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
      Remove-Item $UserProfilePath -Recurse -Force -ErrorAction SilentlyContinue
    }
    # Remove the local user account
    $LocalUser | Remove-LocalUser -Confirm:$False
  }
}

Set-Volume -DriveLetter C -NewFileSystemLabel "$($env:ComputerName)"
# Remove-Item -Path "C:\Apps\bootstrap.ps1" -ErrorAction SilentlyContinue -Verbose:$PSVE -Debug:$PSDE

If ($Restart) { 
  Write-Warning "Computer will restart in $RestartDelayInSeconds seconds!"
  Start-Sleep -Seconds $RestartDelayInSeconds
  Restart-Computer -Confirm:$FALSE -Force
} else {
  Write-Warning "Please reboot this computer to finalize changes made by this script."
}

Exit 0
