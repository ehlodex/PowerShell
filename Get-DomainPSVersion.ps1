[CmdletBinding()]
Param(
[Parameter(Mandatory=$FALSE)][string]$SearchBase = "ou=Workstations,dc=corp,dc=example,dc=com",                                 # OU to search for computers
[Parameter(Mandatory=$FALSE)][string]$SortBy = "Name"                                                                           # Sort-Object Value
);

# Configure Script-Specific Settings                                                                                            # # # # # # # #
Set-StrictMode -Version Latest                                                                                                  # Require all variables to be initialized before use
  # Import Required PowerShell Modules                                                                                          # # # #
  try {
    $Modules = @("ActiveDirectory");
    If ($Modules) { ForEach ($Module in $Modules) { Import-Module $Module -ErrorAction Stop }; }
  } catch {
    Write-Error "Unable to load $Module. Please ensure that this module is available on $env:ComputerName."
  }

# PowerShell Script                                                                                                             # # # # # # # #
$Computers = (Get-AdComputer -Filter {(Enabled -eq $TRUE)} -SearchBase $SearchBase -Properties Description | Sort-Object $SortBy)
Write-Host "";                                                                                                                  # Visual spacer
$Columns = "{0,-6} {1,-6} {2,-6} {3,-9} {4,-16} {5,-32}";                                                                       # Custom format output
$Columns -F "Major", "Minor", "Build", "Revision", "ComputerName", "Description";                                               # Column headings
$Columns -F "-----", "-----", "-----", "--------", "------------", "-----------";                                               # Visual headings delimiter

ForEach ($Computer in $Computers) {
  try {
  $PSVersion = Invoke-Command -ComputerName $($Computer.Name) -ScriptBlock { $PSVersionTable.PSVersion } -ErrorAction SilentlyContinue
  $Major = $PSVersion.Major
  $Minor = $PSVersion.Minor
  $Build = $PSVersion.Build
  $Revision = $PSVersion.Revision
} catch {
  $Major = "-"
  $Minor = "-"
  $Build = "-"
  $Revision = "-"
} finally {
  $Columns -F $Major, $Minor, $Build, $Revision, $($Computer.Name), $($Computer.Description)
}; #end t/c/f
}; #end foreach

# One-Liner, Modified. Best for immediate display (not piped to Out-File)
# Get-ADComputer -Filter {Enabled -eq $TRUE} | Sort-Object Name | %{ Invoke-Command -ComputerName $_.Name -ScriptBlock { $psVersionTable.PsVersion } -ErrorAction SilentlyContinue }
