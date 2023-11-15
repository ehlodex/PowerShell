<#
  .SYNOPSIS
    Creates randomized files for a honeypot.

  .DESCRIPTION
    The New-Honeypot.ps1 script creates multiple dummy files for a honeypot.

  Files are randomly named from a dictionary list and given random file sizes to appear legitimate.

  .PARAMETER Path
    Absolute path to the honeypot.

  .PARAMETER FileCount
    The number of files to create. Default is between 5 and 30.

  .PARAMETER DictionaryPath
    Absolute path to a dictioary list to use for file names.

  .PARAMETER ExtList
    Array of possible file extensions.

  .PARAMETER MinFileSizeInBytes
    Minimum file size, in bytes, for honeypot files. Default is 5242880 (5MB)

  .PARAMETER MaxFileSizeInBytes
    Maximum file size, in bytes, for honeypot files. Default is 1073741824 (1GB)

  .EXAMPLE
    .\New-Honeypot.ps1 -Path C:\ftproot\ -FileCount 100
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False,Position=1,ValueFromPipeline=$True)]
    [string]$Path=".",
    [Parameter(Mandatory=$False,Position=2,ValueFromPipeline=$True)]
    [int]$FileCount=(Get-Random -Minimum 5 -Maximum 30),
    [Parameter(Mandatory=$False)]
    [int]$MinFileSizeInBytes=5242880,    # 5MB
    [Parameter(Mandatory=$False)]
    [int]$MaxFileSizeInBytes=1073741824  # 1GB
)

Set-StrictMode -Version Latest

$FileType = @("doc", "docx", "xls", "xlsx", "pdf", "jpg", "png")

try {
  [string[]]$WordList = (Invoke-RestMethod "https://www.mit.edu/~ecprice/wordlist.10000") -split "`n"
} catch {
  $WordList = @(100..999)
}

If (! (Test-Path $Path -PathType Container)) {
  New-Item -Path "$Path" -ItemType Directory 
}

For ($Files=1; $Files -le $FileCount; $Files++) {
  $FileName = "";
  For ($Words=1; $Words -le (Get-Random -Minimum 1 -Maximum 4); $Words++) {
    $FileName += Get-Random $WordList;
  }
  $FilePath = "$Path\$FileName.$(Get-Random $FileType)"
  $FileSize = Get-Random -Minimum $MinFileSizeInBytes -Maximum $MaxFileSizeInBytes
  Write-Verbose "Creating $FilePath ($([int]($FileSize/1MB))MB)"
  Start-Process -FilePath "C:\Windows\System32\fsutil.exe" -ArgumentList "file createnew $FilePath $FileSize" -NoNewWindow -Wait
}
