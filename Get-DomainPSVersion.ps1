[CmdletBinding()]
Param(
# Add parameter for SearchBase
);

$SearchBase = "ou=Workstations,dc=example,dc=com"
$Computers = (Get-AdComputer -Filter {(Enabled -eq $TRUE)} -SearchBase $SearchBase -Properties Description | Sort-Object Name )
Write-Host "" #spacer
$Columns = "{0,-6} {1,-6} {2,-6} {3,-9} {4,-16} {5,-32}"
$Columns -F "Major", "Minor", "Build", "Revision", "ComputerName", "Description"
$Columns -F "-----", "-----", "-----", "--------", "------------", "-----------"

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

# One-Liner, Modified
# Get-ADComputer -Filter {Enabled -eq $TRUE} | Sort-Object Name | %{ Invoke-Command -ComputerName $_.Name -ScriptBlock { $psVersionTable.PsVersion } -ErrorAction SilentlyContinue }
