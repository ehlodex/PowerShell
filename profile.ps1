# For maximum readability, enable syntax highlighting                                                                           # # # # # # # #
Set-StrictMode -Version Latest                                                                                                  # Require all variables to be initialized before use

# Copy this PS1 file to 'Documents\PowerShell\profile.ps1' before making changes.

# Available Named Colours:
#	Black, Blue, Cyan, DarkBlue, DarkCyan, DarkGray, DarkGreen, DarkMagenta, DarkRed, DarkYellow, Gray, Green, Magenta, Red, White, Yellow

# Colours                                                                                                                       # # # # # # # #
  $Global:MyColor = "Green"                                                                                                     # Global: Custom color display
  $ExitCommand = "quit"                                                                                                         # Alias for Exit-PowerShell

  $console = $host.UI.RawUI                                                                                                     # # # #
    $console.ForegroundColor = "Gray"                                                                                           # Set 'Foreground' Colour
    $console.BackgroundColor = "Black"                                                                                          # Set 'Background' Colour
    $console.WindowTitle = "CommandShell"                                                                                       # Change the PowerShell Title
  $builtin = $host.PrivateData                                                                                                  # # # # #
    $builtin.VerboseForegroundColor = "White"                                                                                   # Set 'Verbose' Colour
    $builtin.VerboseBackgroundColor = $console.BackgroundColor                                                                  # Same as the $Console BackgroundColor
    $builtin.WarningForegroundColor = "Yellow"                                                                                  # Set 'Warning' Colour
    $builtin.WarningBackgroundColor = $console.BackgroundColor                                                                  # Same as the $Console BackgroundColor
    $builtin.ErrorForegroundColor = "Red"                                                                                       # Set 'Error' Colour
    $builtin.ErrorBackgroundColor = $console.BackgroundColor                                                                    # Same as the $Console BackgroundColor
  Clear-Host                                                                                                                    # Clear the screen to apply colours
  
# Paths                                                                                                                         # # # # # # # #
  $Global:Me = Split-Path $MyInvocation.MyCommand.Path -Parent                                                                  # Global: My PowerShell Path
  $Global:PS = "\\corp.example.com\dfs1\PowerShell"                                                                             # Global: Shared PowerShell Scripts Path
  If (Test-Path $Global:PS\Modules) { $Env:PSModulePath = $Env:PSModulePath + ";$Global:PS\Modules" }                           # Environment Variable: Shared PowerShell Modules

# Variables for Import-Module                                                                                                   # # # # # # # #
  $FormatMod = "  {0,-24}  {1,-1}"                                                                                              # Format (-F) for Module display
  $Modules = @{};                                                                                                               # Auto-load the following modules:
  $Modules.Add("ActiveDirectory","Active Directory (Local)");                                                                   # Active Directory (Built-In)
  $Modules.Add("AdManager","Active Directory Tools");                                                                           # Active Directory Manager (custom)
  $Modules.Add("PsManager","PowerShell... Simplified");                                                                         # PowerShell Manager (Custom)
  
# Import-Module                                                                                                                 # # # # # # # #
  $FormatMod -F "ModuleName","Category"; $FormatMod -F "----------------","----------------"                                    # Headings
  $Modules.GetEnumerator() | Sort-Object Name,Value | ForEach { $FormatMod -F $_.Name,$_.Value; Import-Module $_.Name; };       # Import Modules

# Change prompt                                                                                                                 # # # # # # # #
  Function prompt {                                                                                                             # Change the Powershell Prompt
    If ((Split-Path -Path (Get-Location) -Qualifier) -like "?:") { $p = Get-Location; }                                         # Local paths and mapped drives use the full path
    else { $p = Split-Path -Path (Get-Location) -NoQualifier; }                                                                 # Remote (UNC) paths are shorted to begin with \\
    "$p> "                                                                                                                      # Set the prompt
  };                                                                                                                            # End Function prompt

# PSCredential Object                                                                                                           # # # # # # # #
  $KEY = Get-Content $ME\Private\aeskey                                                                                         # Load my private decryption key
  $USR = ("$Env:USERNAME@$Env:USERDNSDOMAIN").ToLower()                                                                         # Use my current username, then decrypt my password (below)
  $Global:MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $USR, (Get-Content "$ME\Private\passwd" | ConvertTo-SecureString -Key $KEY)

# Write-Host some useful information                                                                                            # # # # # # # #
  Write-Host "`nUse " -NoNewLine; Write-Host "`$Global:PS" -ForegroundColor $MyColor -NoNewLine                                 # 
  Write-Host " for " -NoNewLine; Write-Host "$Global:PS" -ForegroundColor $MyColor                                              # Global:PS (Path)
  Write-Host "`nUse " -NoNewLine; Write-Host "`$Global:Me" -ForegroundColor $MyColor -NoNewLine                                 #
  Write-Host " for " -NoNewLine; Write-Host "$Global:Me" -ForegroundColor $MyColor                                              # Global:My (Path)

  New-Alias $ExitCommand Exit-PowerShell                                                                                        # ExitCommand = Exit-PowerShell
  Write-Host "`nPowerShell profile loading complete; Welcome to $($host.Ui.RawUI.WindowTitle)."                                 # Message: profile load complete
  Write-Host "Type " -NoNewLine; Write-Host "$ExitCommand" -ForegroundColor $MyColor -NoNewLine                                 # 
  Write-Host " or " -NoNewLine; Write-Host "Exit-PowerShell" -ForegroundColor $MyColor -NoNewLine; Write-Host " to exit.`n"     # 

# Cleanup                                                                                                                       # # # # # # # #
  Remove-Variable -Name ExitCommand,console,builtin,FormatMod,Modules,KEY,USR                                                   # Remove temporary variables
Set-Location $Global:PS                                                                                                         # 'cd' to the shared repository
