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

[CmdletBinding()]                                                                                                               # # # # # # # #
Param(                                                                                                                          # Parameters
  [Parameter(Mandatory=$FALSE)]
  [string]$ParameterName = "Default Value"
);                                                                                                                              # End Parameters

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
  # Import Required PowerShell Modules                                                                                          # # # #
  try {
    $Modules = @("");
    If ($Modules) { ForEach ($Module in $Modules) { Import-Module $Module -ErrorAction Stop }; }
  } catch {
    Write-Error "Unable to load $Module. Please ensure that this module is available on $env:ComputerName."
  }
  # Declare Functions                                                                                                           # # # #
  Function repeated_meme {                                                                                                      # # repeated_meme {}
    Write-Host "A gift of peace, in all good faith."; Exit;
  };                                                                                                                            # End repeated_meme {}
# PowerShell Script                                                                                                             # # # # # # # #
# Cleanup                                                                                                                       # # # # # # # #
Get-PSSession | Remove-PSSession
