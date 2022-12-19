<#
  .SYNOPSIS
  Automate the installation of the NexView client software from TSI
  
  .DESCRIPTION
    The Install-NexView.ps1 script allows the unattended installation of the NexView software,
    including selection of a specific version and centralized configurations.
  
  .PARAMETER Version
    Select a specific NexView version. Default is 3.2.12.

  .PARAMETER UpdateCfg
    Replace the existing NexViewCfg.XML file with a copy from a network share.

  .PARAMETER x86
    Force the installation of the 32-bit (x86) software on a 64-bit (x64) machine.

  .EXAMPLE
    Install-NexView.ps1 -Version 2.6.16 -UpdateCfg

  .LINK
    https://technet.microsoft.com/en-us/library/hh847834.aspx
  
  .NOTES
    Written 2022.12 for Transit Solutions, LLC.
#>


[CmdletBinding()]
Param(
    [string]$Version = "3.2.12",
    [switch]$UpdateCfg,
    [switch]$x86
);

Set-StrictMode -Version Latest

# THIS SCRIPT WILL NOT WORK UNTIL YOU SET THE TWO VARIABLES BELOW:

# Download path to the folder that has the Nexview Setup executable.
# Do not include the trailing slash '\'
$DownloadPath = "\\server\share\NexView"
# Temporary path on local computer to cache the NexView Setup executable.
# Do not include the trailing slash '\'
$TempPath = "C:\Temp"

# DO NOT EDIT BELOW THIS LINE

# Alternative download method, using a web server instead of a local share. Not recommended.
# $DownloadUri = 'https://files.mycompany.com/NexView/'
# Replace "Copy-Item ..." with the following snippets:
# Invoke-WebRequest -Uri "$DownloadUri/$NexViewExe" -OutFile "$TempPath\$NexViewExe"
# Invoke-WebRequest -Uri "$DownloadUri/$NexViewXml" -OutFile "$NexViewXmlPath"

# Check for elevation
$WindowsIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent();
$WindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($WindowsIdentity);
$Administrator=[System.Security.Principal.WindowsBuiltInRole]::Administrator;
$Elevated=$WindowsPrincipal.IsInRole($Administrator);
If (! $Elevated) { Write-Error "Administrative rights required! Please elevate PowerShell then try again."; exit; };

$WindowsBits = If ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
$NexViewBits = If (($x86) -or ($WindowsBits -eq "x86")) { "x86" } else { "x64" }  # Check for a 32-bit install (x86)

$InstallPath = "C:\Program Files\TSI"  # Do not include '\NexView\' !
# Check if we're installing the x86 version on an x64 operating system.
If (($NexViewBits -eq "x86") -and ($WindowsBits -eq "x64")) {
    $InstallPath = "C:\Program Files (x86)\TSI"
}

$NexViewExe = "NexView $Version Setup $NexViewBits.exe"  # e.g. "NexView 1.2.3 Setup x64.exe"
$NexViewXml = "NexViewCfg.XML"
$NexViewXmlPath = "$InstallPath\NexView\Data\$NexViewXml"

# DEBUG
$DebugMisc = "# # # # # MISC # # # # #`n"
$DebugMisc += "WindowsBits    : $WindowsBits`n"
$DebugMisc += "NexViewBits    : $NexViewBits`n"
$DebugMisc += "Version        : $Version`n"
$DebugMisc += "-UpdateCfg     : $UpdateCfg`n"
$DebugMisc += "-x86           : $x86`n"
$DebugPath = "# # # # # PATHS # # # # #`n"
$DebugPath += "DownloadPath   : $DownloadPath`n"
$DebugPath += "TempPath       : $TempPath`n"
$DebugPath += "InstallPath    : $InstallPath`n"
$DebugPath += "NexViewXmlPath : $NexViewXmlPath`n"
$DebugFile = "# # # # # FILE NAMES # # # # #`n"
$DebugFile += "NexViewExe     : $NexViewExe`n"
$DebugFile += "NexViewXml     : $NexViewXml`n"
Write-Debug $DebugMisc
Write-Debug $DebugPath
Write-Debug $DebugFile

# Copy NexView Setup to a local path
Write-Verbose "Downloading NexView $Version from $DownloadPath"
If (! (Test-Path $TempPath)) { New-Item -Path $TempPath -Type Directory }
Copy-Item -Path "$DownloadPath\$NexViewExe" -Destination "$TempPath\"

# Install NexView
Write-Verbose "Issuing command Start-Process `"$TempPath\$NexViewExe`" -ArgumentList `"/S /D=$InstallPath`""
Start-Process "$TempPath\$NexViewExe" -ArgumentList "/S /D=$InstallPath"

# Check for the -UpdateCfg flag
If (($UpdateCfg) -and (Test-Path $NexViewXmlPath)) {
    If (Test-Path "$NexViewXmlPath.bak") { Remove-Item -Path "$NexViewXmlPath.bak" -Force}
    Rename-Item -Path $NexViewXmlPath -NewName "$NexViewXML.bak"
}

# Check if there is an existing configration file; download one if there's not.
If (! (Test-Path "$NexViewXmlPath")) {
    Copy-Item -Path "$DownloadPath\$NexViewXml" -Destination "$NexViewXmlPath"
}

Write-Output "Process complete!"
