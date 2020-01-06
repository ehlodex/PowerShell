<#
  .SYNOPSIS
  Bootstraps a Windows 10 PC with common applications and settings

  .DESCRIPTION
    The bootstrap.ps1 script installs the basic software components in a manual deployment.

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
  # Customize the script for your environment. Add-WindowsCapability for OpenSSH.Server cannot be used remotely (afaik)         # No parameters
);                                                                                                                              # End Parameter Bindings

# Configure Script-Specific Settings                                                                                            # # # # # # # #
Set-StrictMode -Version Latest                                                                                                  # Require all variables to be initialized before use
  # Check for elevation (optional)                                                                                              # # # #
  $WindowsIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent();                                                   #
  $WindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($WindowsIdentity);                                    #
  $Administrator=[System.Security.Principal.WindowsBuiltInRole]::Administrator;                                                 #
  $Elevated=$WindowsPrincipal.IsInRole($Administrator);                                                                         #
  If (! $Elevated) { Write-Error "Administrative rights required! Please elevate PowerShell then try again."; exit; };          # Exit if not elevated
  # Initialize Script (Local) Variables                                                                                         # # # #
  If ($PsBoundParameters['Verbose']) { $PWSHVE = $TRUE; } Else {$PWSHVE = $FALSE; };                                            # PowerShell Verbose Execution
  If ($PsBoundParameters['Debug'])   { $PWSHDE = $TRUE; } Else {$PWSHDE = $FALSE; };                                            # PowerShell Debug Execution
  # Python3 Arguments                                                                                                           # #
  $Python3Path          = "C:\Apps\Python3"; # No trailing slash. Unused. Add 'TARGETDIR=$Python3Path' to Python3Arguments.     # Default: C:\Program Files\Python3
  $Python3Arguments     = "Include_doc=0 Include_launcher=0 Include_tcltk=0 Include_test=0 InstallAllUsers=1 PrependPath=1 ";   #
  $Python3Arguments    += "Shortcuts=0"; # TargetDir=$Python3Path";                                                             #
  # PowerShell Core Arguments                                                                                                   # #
  $PowerShellPath       = "C:\Apps\PowerShell"; # No trailing slash. Also used in sshd_config !                                 # Default: C:\Program Files\Powershell
  $PowerShellArguments  = "ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=0 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 ";                #
  $PowerShellArguments += "INSTALLFOLDER=$PowerShellPath";                                                                      #
    #  OpenSSH does not like spaces in the subsystem path! Microsoft recommends installing PowerShell to the default path       #
    #  at "C:\Program Files\PowerShell", creating a directory link from C:\PowerShell to "C:\Program Files\PowerShell\6",       #
    #  then setting the sshd_config subsystem path to "C:\PowerShell\pwsh.exe --sshs -NoProfile -NoLogo"                        #
    #  By default, this script simply installs PowerShell Core to C:\Apps\PowerShell ... no symlink needed!                     #
    #  Create the recommended directory link with: cmd /c mklink /D C:\PowerShell 'C:\Program Files\PowerShell\6'               #
  # Salt Minion Arguments                                                                                                       # #
  $SaltMasterName       = "salt.corp.example.com";                                                                              # Default: salt
  $SaltMinionName       = "$env:ComputerName";                                                                                  # Default is the FQDN
  $SaltMinionArguments  = "/master=$SaltMasterName /minion-name=$SaltMinionName" # Unused.                                      # Convert --params to --install-arguments
  # TightVNC Arguments                                                                                                          # #
  $TightVncAdminRange   = "192.168.144.200-192.168.144.250";                                                                    # Allowed IP Range
  $TightVncConnPass     = "!c0nnect" # limit: 8 characters                                                                      # Connect Password
  $TightVncCtrlPass     = "c0ntrol&" # limit: 8 characters                                                                      # Control/Admin Password
  $TightVncViewPass     = "notouchy" # limit: 8 characters                                                                      # View Only Password
  $TightVncOptions      = [ordered]@{ "ADDLOCAL" = "Server";                                                                    # Only install tVNC Server (no viewer)
    "SET_ACCEPTHTTPCONNECTIONS" = "1";    "VALUE_OF_ACCEPTHTTPCONNECTIONS" = "0";                                               # Disable HTTP connections (require viewer software)
    "SET_IPACCESSCONTROL" = "1";          "VALUE_OF_IPACCESSCONTROL" = "$TightVncAdminRange:2,0.0.0.0-255.255.255.255:1";       # Allow 'Admin Range' then deny all
    "SET_QUERYACCEPTONTIMEOUT" = "1";     "VALUE_OF_QUERYACCEPTONTIMEOUT" = "1";                                                # Auto-select 'yes' if no response from user
    "SET_QUERYTIMEOUT" = "1";             "VALUE_OF_QUERYTIMEOUT" = "15";                                                       # Time, in seconds, for user to respond
    "SET_RUNCONTROLINTERFACE" = "1";      "VALUE_OF_RUNCONTROLINTERFACE" = "0";                                                 # Do not load Control/Admin Interface to notification area
    "SET_USECONTROLAUTHENTICATION" = "1"; "VALUE_OF_USECONTROLAUTHENTICATION" = "1";                                            # Enable use of the Control/Admin Password
    "SET_CONTROLPASSWORD" = "1";          "VALUE_OF_CONTROLPASSWORD" = "$TightVncCtrlPass";                                     # Set Control/Admin Password
    "SET_PASSWORD" = "1";                 "VALUE_OF_PASSWORD" = "$TightVncConnPass";                                            # Set Connect Password
    "SET_VIEWONLYPASSWORD" = "1";         "VALUE_OF_VIEWONLYPASSWORD" = "$TightVncViewPass";                                    # Set View Only Password
  }; # TightVNC's msi parameters are complicated. You have to set_ then assign a value_of_ ... A hashtable was easier to read   #
  $TightVncArguments = ""; ForEach ($Key in $TightVncOptions.Keys) {                                                            # Convert Options (hastable) to Arguments (string)
  If (! $TightVncArguments) { $TightVncArguments = "$Key=$($TightVncOptions[$Key])" }                                           # If first argument, start a new string,
  Else { $TightVncArguments += " $Key=$($TightVncOptions[$Key])" }; };                                                          # else use a space between arguments

# PowerShell Script                                                                                                             # # # # # # # #
Set-ExecutionPolicy Bypass -Scope Process -Force;                                                                               #
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); refreshenv;                       # Install Chocolatey
  choco install -y powershell-core --install-arguments=$PowerShellArguments                                                     #
  choco install -y python3 --install-arguments=$Python3Arguments                                                                #
  choco install -y saltminion --params "/master=$SaltMasterName /minion=$SaltMinionName"                                        #
  choco install -y tightvnc --install-arguments=$TightVncArguments                                                              #
  choco install -y 7zip                                                                                                         #
  choco install -y vlc                                                                                                          #
  choco install -y libreoffice-still                                                                                            #
Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TightVNC" -Recurse                                            # Remove the TightVNC shortcuts

# Install OpenSSH.Server and OpenSSH.Client                                                                                     # # # # # # # #
$OpenSSH = (Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*');                                                #
ForEach ($SSH in $OpenSSH) { If ($($SSH.State) -ne 'Installed') { Add-WindowsCapability -Online -Name $($SSH.Name); }; };       #
Start-Service -Name sshd; Stop-Service -Name sshd;                                                                              # auto-create ssh files
$sshd_config = @"
# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#HostKey __PROGRAMDATA__/ssh/ssh_host_rsa_key
#HostKey __PROGRAMDATA__/ssh/ssh_host_dsa_key
#HostKey __PROGRAMDATA__/ssh/ssh_host_ecdsa_key
#HostKey __PROGRAMDATA__/ssh/ssh_host_ed25519_key

# Ciphers and keying
#RekeyLimit default none

# Logging
#SyslogFacility AUTH
#LogLevel INFO

# Authentication:

#LoginGraceTime 2m
#PermitRootLogin prohibit-password
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

#PubkeyAuthentication yes

# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/authorized_keys
AuthorizedKeysFile	.ssh/authorized_keys

#AuthorizedPrincipalsFile none

# For this to work you will also need host keys in %programData%/ssh/ssh_known_hosts
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunneled clear text passwords, change to no here!
#PasswordAuthentication yes
#PermitEmptyPasswords no

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
#PermitTTY yes
#PrintMotd yes
#PrintLastLog yes
#TCPKeepAlive yes
#UseLogin no
#PermitUserEnvironment no
#ClientAliveInterval 0
#ClientAliveCountMax 3
#UseDNS no
#PidFile /var/run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
#Banner none

# override default of no subsystems
Subsystem	powershell	$PowerShellPath\6\pwsh.exe -sshs -NoLogo -NoProfile

# Example of overriding settings on a per-user basis
#Match User anoncvs
#	AllowTcpForwarding no
#	PermitTTY no
#	ForceCommand cvs server

Match Group administrators
       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
"@
$sshd_config | Set-Content -Path C:\ProgramData\ssh\sshd_config;                                                                # Replace the original sshd_config
Start-Service -Name sshd; Set-Service -Name sshd -StartupType Automatic                                                         # Enable and start the sshd service (server)

## TODO: Cleanup and clarify the following code.
## TODO: Add functions to add/remove each section, just just remove.
## TODO: Add documentation / comments

$WindowsOptionalFeatures = @("WorkFolders-Client")
ForEach ($OptionalFeature in $WindowsOptionalFeatures) {
  Get-WindowsOptionalFeature -Online | 
    Where-Object {$_.Name -like "*$OptionalFeature*"} | 
      Disable-WindowsOptionalFeature -Online
}

$WindowsCapabilities = @("Browser.InternetExplorer", "Hello.Face", "SNMP.Client", "WMI-SNMP-Provider.Client", "XPS.Viewer")
ForEach ($Capability in $WindowsCapabilities) {
  Get-WindowsCapability -Online | 
    Where-Object {($_.Name -like "*$Capability*") -and ($_.State -eq 'Installed')} |
      Remove-WindowsCapability -Online
}

$AppxPackages = @("GetStarted", "Microsoft3DViewer", "MixedReality", "OneConnect", "OneNote", "Print3D", "SkypeApp", "WindowsCommunicationsApps", "WindowsFeedbackHub", "ZuneMusic")
ForEach ($Package in $AppxPackages) {
  Get-AppxPackage -AllUsers | 
    Where-Object {$_.Name -like "*$Package*"} |
      Remove-AppxPackage -AllUsers
}
