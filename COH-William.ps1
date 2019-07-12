[CmdletBinding()]                                                                                                               # Enabled advanced parameter features, such as decorator lines
Param(                                                                                                                          # Start Parameter Bindings
  [Parameter(Position=1,Mandatory=$FALSE,ValueFromPipeline=$TRUE,ValueFromPipelineByPropertyName=$TRUE)]
  [string]$UserName
);                                                                                                                              # End Parameter Bindings

# For maximum readability, enable syntax highlighting                                                                           # # # # # # # #
Set-StrictMode -Version Latest                                                                                                  # Require all variables to be initialized before use
$USMT = "\\Server\USMT"
$Domain = "DOMAIN"

# PowerShell Script                                                                                                             # # # # # # # #
If ($UserName -eq "") { $Username = Read-Host 'Enter the name of the user you want to BACKUP: '; }                              # set /p

#net use u: still works, but this is the PowerSehll way...
New-PSDrive -Name "u" -PSProvider FileSystem -Root $USMT                                                                        # net use u: \\Server\USMT
Set-Location U:                                                                                                                 # u:
scanstate.exe /c u:\store\$UserName\ /ue:*\* /ui:$Domain\$UserName /O /v:13 /i:MigUser.xml /i:MigApp.xml                        # run the scna!
Remove-PSDrive -Name "u"                                                                                                        # net use u: /d /y
