<#
  .SYNOPSIS
  Provides a template for PowerShell scripts (PS1)
  
  .DESCRIPTION
    The Template.ps1 script contains the basic framework for PowerShell scripts.
  
  Additional description information can be included here.
  
  .PARAMETER param
    Parameter details. Repeat as needed.

  .EXAMPLE
    Example command. Repeat as needed.

  .LINK
    https://technet.microsoft.com/en-us/library/hh847834.aspx
  
  .LINK
    https://support.example.com
  
  .NOTES
    Written <yyyy.MM> for The Example Corporation by:
    <Contributer1>, <Job Title>
    <Contributer2>, <Job Title>
#>

[CmdletBinding()]                                                                                                               # Enabled advanced parameter features, such as decorator lines
Param(                                                                                                                          # Start Parameter Bindings
  [Parameter(Mandatory=$FALSE)]                                                                                                 # 
  [string]$Environment,                                                                                                         #  Environ  $DTAP2.Environ
  [Parameter(Mandatory=$FALSE)]                                                                                                 # 
  [string]$Service,                                                                                                             #  Service  $DTAP2.Environ.Service
  [Parameter(Mandatory=$FALSE)]                                                                                                 # 
  $Context                                                                                                                      #  Context  $DTAP2.Environ.Service[Context]
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
  If ($PsBoundParameters['Verbose']) { $PWSHVE = $TRUE; } Else {$PWSHVE = $FALSE; };                                            # PowerShell Verbose Execution
  If ($PsBoundParameters['Debug'])   { $PWSHDE = $TRUE; } Else {$PWSHDE = $FALSE; };                                            # PowerShell Debug Execution
  # Import Required PowerShell Modules                                                                                          # # # #
  # Declare Functions                                                                                                           # # # #
# PowerShell Script                                                                                                             # # # # # # # #
# Cleanup                                                                                                                       # # # # # # # #
Get-PSSession | Remove-PSSession
