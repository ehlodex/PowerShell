# For maximum readability, enable syntax highlighting                                                                           # # # # # # # #
Set-StrictMode -Version Latest                                                                                                  # Require all variables to be initialized before use

# Configure Script-Specific Settings                                                                                            # # # # # # # #
  # Initialize Script (Local) Variables                                                                                         # # # #
  # Import Required PowerShell Modules                                                                                          # # # #

# Declare Functions (cmdlets)                                                                                                   # # # # # # # #

Function Get-Example {                                                                                                          # # # # Get-Example1
[CmdletBinding()]                                                                                                               # Enable Parameters
Param(                                                                                                                          # Start Parameter Bindings
);                                                                                                                              # End Parameter Bindings
  BEGIN {                                                                                                                       # BEGIN/process/end for Get-Example1
  If ($PsBoundParameters['Verbose']) { $PWSHVE = $TRUE; } Else {$PWSHVE = $FALSE; };                                            # PowerShell Verbose Execution
  If ($PsBoundParameters['Debug'])   { $PWSHDE = $TRUE; } Else {$PWSHDE = $FALSE; };                                            # PowerShell Debug Execution
  };                                                                                                                            #
  PROCESS {                                                                                                                     # begin/PROCESS/end for Get-Example1
    Get-Example2 -Verbose:$PWSHVE -Debug:$PWSHDE;                                                                               #  <-- Core processing goes here
  };                                                                                                                            #
  END {                                                                                                                         # begin/process/END for Get-Example1
  };                                                                                                                            # begin/process/end for Get-Example1 (end)
};                                                                                                                              # # End Get-Example1

Function Get-Example2 {                                                                                                         # # # # Get-Example2
[CmdletBinding()]                                                                                                               # Enabled advanced parameter features, such as decorator lines
Param(                                                                                                                          # Start Parameter Bindings
);                                                                                                                              # End Parameter Bindings
  BEGIN {                                                                                                                       # BEGIN/process/end for Get-Example2
  If ($PsBoundParameters['Verbose']) { $PWSHVE = $TRUE; } Else {$PWSHVE = $FALSE; };                                            # PowerShell Verbose Execution
  If ($PsBoundParameters['Debug'])   { $PWSHDE = $TRUE; } Else {$PWSHDE = $FALSE; };                                            # PowerShell Debug Execution
  };                                                                                                                            # 
  PROCESS {                                                                                                                     # begin/PROCESS/end for Get-Example2
    Write-Output "Verbostiy is $PWSHVE. Debug is $PWSHDE"                                                                       #  Return;
  };                                                                                                                            # 
  END {                                                                                                                         # begin/process/END for Get-Example2
  };                                                                                                                            # begin/PROCESS/end for Get-Example2 (end)
};                                                                                                                              # # End Get-Example2
