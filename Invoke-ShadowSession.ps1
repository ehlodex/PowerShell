[CmdletBinding()]                                                                                                               # Enabled advanced parameter features, such as decorator lines
Param(                                                                                                                          # Start Parameter Bindings
  [Parameter(Mandatory=$TRUE,Position=1)] [string]$ComputerName,                                                                # ComputerName
  [Parameter(Mandatory=$FALSE)]           [switch]$Control,                                                                     # Control
  [Parameter(Mandatory=$FALSE)]           [switch]$NoConsentPrompt                                                              # NoConsentPrompt
);                                                                                                                              # End Parameter Bindings

# For maximum readability, enable syntax highlighting                                                                           # # # # # # # #
Set-StrictMode -Version Latest                                                                                                  # Require all variables to be initialized before use

# Configure Script-Specific Settings                                                                                            # # # # # # # #
  $Session = qwinsta /server:$ComputerName | % { $_.Trim() -replace "\s+","," } | ConvertFrom-CSV | ? { $_.State -eq 'Active' } # Wrapper for the qwinsta ('query session') command
  $Command = "mstsc /v:$ComputerName /shadow:"                                                                                  # Remote Desktop base command. or %WinDir%\SysWOW64\mstsc.exe...

# PowerShell Script                                                                                                             # # # # # # # #
If ($Session) {
  $Command += $Session.ID
  If ($Control) { $Command += " /control" }
  If ($NoConsentPrompt) { $Command += " /NoConsentPrompt" }
  Write-Verbose "Connecting to $($Session.USERNAME) on $ComputerName with `"$Command`""
  cmd /c $Command
} Else {
  Write-Error "There is no active session to shadow."
}
