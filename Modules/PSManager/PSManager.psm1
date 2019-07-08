# For maximum readability, enable syntax highlighting                                                                           # # # # # # # #
Set-StrictMode -Version Latest                                                                                                  # Require all variables to be initialized before use

# Declare Functions (cmdlets)                                                                                                   # # # # # # # #
Function Exit-PowerShell {                                                                                                      # # # #
  [CmdletBinding()]                                                                                                             # Initialize Parameters
  Param(                                                                                                                        #
	[Parameter(Mandatory=$FALSE)] [switch]$NoForce                                                                                # $NoForce (T|F)
  )                                                                                                                             # End Parameter Declaration
  Write-Verbose "Invoking command Get-PSSession | Remove-PSSession to find and remove all remote sessions"                      # PWSHVE
  Get-PsSession | Remove-PsSession                                                                                              # Find and remove any unclosed (remote) sessions
  Write-Verbose "Invoking command Remove-Module * -Force to unload all PowerShell Modules"                                      # PWSHVE
  Remove-Module * -Force -ErrorAction SilentlyContinue                                                                          # Remove all imported modules
  If (!($NoForce)) { Stop-Process -Id $PID }                                                                                    # If -NoForce not specified, Stop PowerShell
}                                                                                                                               # # End Exit-PowerShell

Function Reset-Module {                                                                                                         # # # #
  [CmdletBinding()]                                                                                                             # Initialize Parameters
  Param(                                                                                                                        #
  [Parameter(Mandatory=$TRUE,Position=1)] [string]$Name                                                                         # Name of the Module
  )                                                                                                                             # End Parameter Declaration
  If ((Get-Module -Name $Name)) {                                                                                               # If Module Imported
	  Write-Verbose "The module ($Name) is already imported!"                                                                     # PWSHVE
	  $ModuleURI = (Get-Module -Name $Name).Path                                                                                  # Get the Module Path
	  Write-Verbose "Module Name   : $Name"; Write-Verbose "Module Path   : $ModuleURI"                                           # PWSHVE
  }                                                                                                                             # End If Module Imported
  Write-Verbose "Attempting to remove $Name (PowerShell Module)"                                                                # PWSHVE
  Remove-Module -Name $Name -ErrorAction SilentlyContinue                                                                       # Remove the Module
  If (Get-Module -ListAvailable -Name $Name) {                                                                                  # If Default Module
    Write-Verbose "The requested module ($Name) is built-in. Attempting import."                                                # PWSHVE
	  Import-Module -Name $Name -Global                                                                                           # Import-Module by Name
  } Else {                                                                                                                      # Else Non-Default Module
	  Write-Verbose "The requested module ($Name) is custom. Importing from: $ModuleURI"                                          # PWSHVE
    Import-Module -Name $ModuleURI -Global                                                                                      # Import-Module by Path
  }                                                                                                                             # End If Default Module
}                                                                                                                               # # End Reset-Module

Function Test-ElevatedMode {                                                                                                    # # # #
  $WindowsIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent();                                                   #
  $WindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($WindowsIdentity);                                    #
  $Administrator=[System.Security.Principal.WindowsBuiltInRole]::Administrator;                                                 #
  $Elevated=$WindowsPrincipal.IsInRole($Administrator);                                                                         #
  Write-Output "The current shell is $(If (! $Elevated) { "NOT " };)elevated";                                                  #
}                                                                                                                               # # End Test-ElevatedMode
