<#
  .SYNOPSIS
  Bootstraps a Windows 10 PC with common applications via chocolatey
  
  .DESCRIPTION
    The bootstrap.ps1 script contains the basic software components for a manual deployment.
    
    This script does not have any parameters, as it is meant to be a fully automatic process.
    
    Please customize this script to meet the needs of your environment!

  .EXAMPLE
    .\bootstrap.ps1

  .LINK
    https://technet.microsoft.com/en-us/library/hh847834.aspx
  
  .NOTES
    Written 2019.06 by:
    Joshua Burkholder [ehlodex]
#>

[CmdletBinding()]                                                                                                               # Enabled advanced parameter features, such as decorator lines
Param(                                                                                                                          # Start Parameter Bindings
  # Customize the script for your environment                                                                                   # No parameters
);                                                                                                                              # End Parameter Bindings

# For maximum readability, enable syntax highlighting                                                                           # # # # # # # #
Set-StrictMode -Version Latest                                                                                                  # Require all variables to be initialized before use

# Check for elevation (optional)                                                                                                # # # #
$WindowsIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent();                                                     # 
$WindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($WindowsIdentity);                                      # 
$Administrator=[System.Security.Principal.WindowsBuiltInRole]::Administrator;                                                   # 
$Elevated=$WindowsPrincipal.IsInRole($Administrator);                                                                           # 
# If (! $Elevated) { Write-Error "Administrative rights required! Please elevate PowerShell then try again."; exit; };          # Exit if not elevated

# Configure Script-Specific Settings                                                                                            # # # # # # # #
  # Initialize Script (Local) Variables                                                                                         # # # #
  $Python3Arguments    = "INCLUDE_DOC=0 INCLUDE_LAUNCHER=0 INCLUDE_TCLTK=0 INCLUDE_TEST=0 INSTALLALLUSERS=1 PREPENDPATH=1 SHORTCUTS=0" # TARGETDIR=C:\Apps\Python3
  $PowerShellArguments = "ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=0 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 INSTALLFOLDER=C:\Apps\PowerShell"
  # OpenSSH does not like spaces in the subsystem path! 
  # Microsoft recommends installing powershell to the default path C:\Program Files\PowerShell\, then creating a directory link from C:\PowerShell
  # You can "cmd /c mklink /D C:\Apps\PowerShell 'C:\Program Files\PowerShell'" then
  # set the sshd_config subsystem path to "C:\Apps\PowerShell\6\pwsh.exe --sshs -NoProfile -NoLogo"
  $SaltMasterName      = "salt.corp.example.com";                                                                               # Salt Master (default 'salt')
  $SaltMinionName      = "$env:ComputerName";                                                                                   # Salt Minion Name (default hostname)
  $SaltMinionArguments = "/master=$SaltMasterName /minion-name=$SaltMinionName" # not used; valid for --install-arguments=      # Alternative salt config method - not used
  $TightVncAdminRange  = "192.168.0.1-192.168.0.254";                                                                           # TightVNC Allowed IP Range
  $TightVncConnPass    = "c0nnect!" # limit: 8 characters                                                                       # TightVNC Password
  $TightVncCtrlPass    = "c0ntrol!" # limit: 8 characters                                                                       # TightVNC Control/Admin Password
  $TightVncViewPass    = "viewonly" # limit: 8 characters                                                                       # TightVNC View Only Password
  $TightVncOptions     = [ordered]@{ "ADDLOCAL" = "Server";
    "SET_ACCEPTHTTPCONNECTIONS" = "1";    "VALUE_OF_ACCEPTHTTPCONNECTIONS" = "0";
    "SET_IPACCESSCONTROL" = "1";          "VALUE_OF_IPACCESSCONTROL" = "$TightVncAdminRange:2,0.0.0.0-255.255.255.255:1";
    "SET_QUERYACCEPTONTIMEOUT" = "1";     "VALUE_OF_QUERYACCEPTONTIMEOUT" = "1";
    "SET_QUERYTIMEOUT" = "1";             "VALUE_OF_QUERYTIMEOUT" = "15";
    "SET_RUNCONTROLINTERFACE" = "1";      "VALUE_OF_RUNCONTROLINTERFACE" = "0";
    "SET_USECONTROLAUTHENTICATION" = "1"; "VALUE_OF_USECONTROLAUTHENTICATION" = "1";
    "SET_CONTROLPASSWORD" = "1";          "VALUE_OF_CONTROLPASSWORD" = "$TightVncCtrlPass";
    "SET_PASSWORD" = "1";                 "VALUE_OF_PASSWORD" = "$TightVncConnPass";
    "SET_VIEWONLYPASSWORD" = "1";         "VALUE_OF_VIEWONLYPASSWORD" = "$TightVncViewPass";
  };
  $TightVncArguments = ""; # Leave blank                                                                                        # Initialize TightVncArguments
  ForEach ($Key in $TightVncOptions.Keys) {
    If (! $TightVncArguments) { $TightVncArguments = "$Key=$($TightVncOptions[$Key])" } else { $TightVncArguments += " $Key=$($TightVncOptions[$Key])" };
  }
  # Import Required PowerShell Modules                                                                                          # # # #
  
  # Declare Functions                                                                                                           # # # #
  
# PowerShell Script                                                                                                             # # # # # # # #
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
refreshenv
  choco install -y powershell-core --install-arguments=$PowerShellArguments
  choco install -y python3 --install-arguments=$Python3Arguments
  choco install -y saltminion --params "/master=$SaltMasterName /minion=$SaltMinionName"
  choco install -y tightvnc --install-arguments=$TightVncArguments
  choco install -y 7zip
  choco install -y vlc
  choco install -y libreoffice-still
Remove-Item "C:\ProgramData\Micrsoft\Windows\Start Menu\Programs\TightVNC" -Recurse
