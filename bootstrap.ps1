<#
  .SYNOPSIS
  Bootstrapps a Windows 10 PC with common applications and settings
  
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
  # Customize the script for your environment. Add-WindowsCapability for OpenSSH.Server cannot be used remotely (afaik)         # No parameters
);                                                                                                                              # End Parameter Bindings

# For maximum readability, enable syntax highlighting                                                                           # # # # # # # #
Set-StrictMode -Version Latest                                                                                                  # Require all variables to be initialized before use

# Check for elevation (optional)                                                                                                # # # #
$WindowsIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent();                                                     # 
$WindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($WindowsIdentity);                                      # 
$Administrator=[System.Security.Principal.WindowsBuiltInRole]::Administrator;                                                   # 
$Elevated=$WindowsPrincipal.IsInRole($Administrator);                                                                           # 
If (! $Elevated) { Write-Error "Administrative rights required! Please elevate PowerShell then try again."; exit; };            # Exit if not elevated

# Configure Script-Specific Settings                                                                                            # # # # # # # #
  If ($PsBoundParameters['Verbose']) { $PSVE = $TRUE; } Else {$PSVE = $FALSE; };                                                # PowerShell Verbose Execution
  If ($PsBoundParameters['Debug'])   { $PSDE = $TRUE; } Else {$PSDE = $FALSE; };                                                # PowerShell Debug Execution
# Python3 Arguments                                                                                                             # #
  $Python3Path          = "C:\Apps\Python3"; #No trailing slash. Default C:\Program Files\Python3                               # unused; TARGETDIR=$Python3Path
  $Python3Arguments     = "INCLUDE_DOC=0 INCLUDE_LAUNCHER=0 INCLUDE_TCLTK=0 INCLUDE_TEST=0 INSTALLALLUSERS=1 PREPENDPATH=1 ";   # 
  $Python3Arguments    += "SHORTCUTS=0"; # TARGETDIR=$Python3Path                                                               # 
# PowerShell Core Arguments                                                                                                     # #
  $PowerShellPath       = "C:\Apps\PowerShell"; #No trailing slash. Default C:\Program Files\PowerShell                         # Path - used in sshd_config!
  $PowerShellArguments  = "ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=0 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 ";                # Standard Options
  $PowerShellArguments += "INSTALLFOLDER=$PowerShellPath";                                                                      # Install Folder
  #  OpenSSH does not like spaces in the subsystem path! Microsoft recommends installing PowerShell to the default path         # 
  #  at "C:\Program Files\PowerShell", creating a directory link from C:\PowerShell to "C:\Program Files\PowerShell\6",         # 
  #  then setting the sshd_config subsystem path to "C:\PowerShell\pwsh.exe --sshs -NoProfile -NoLogo"                          # 
  #  By default, this script simply installs PowerShell Core to C:\Apps\PowerShell ... no symlink needed!                       # 
  #  Create the recommended directory link with: cmd /c mklink /D C:\PowerShell 'C:\Program Files\PowerShell\6'                 # 
# Salt Minion Arguments                                                                                                         # #
  $SaltMasterName      = "salt.corp.example.com";                                                                               # Master
  $SaltMinionName      = "$env:ComputerName";                                                                                   # Minion
  $SaltMinionArguments = "/master=$SaltMasterName /minion-name=$SaltMinionName"                                                 # unused; choco --install-arguments
# TightVNC Arguments                                                                                                            # #
  $TightVncAdminRange  = "192.168.144.200-192.168.144.250";                                                                     # Allowed IP Range
  $TightVncConnPass    = "!c0nnect" # limit: 8 characters                                                                       # Connect Password
  $TightVncCtrlPass    = "c0ntrol&" # limit: 8 characters                                                                       # Control/Admin Password
  $TightVncViewPass    = "notouchy" # limit: 8 characters                                                                       # View Only Password
  $TightVncOptions     = [ordered]@{ "ADDLOCAL" = "Server";                                                                     # Only install tVNC Server (no viewer)
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
$TightVncArguments = ""; ForEach ($Key in $TightVncOptions.Keys) {                                                              # Convert Options (hastable) to Arguments (string)
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

# Install OpenSSH.Server                                                                                                        # # # # # # # #
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
