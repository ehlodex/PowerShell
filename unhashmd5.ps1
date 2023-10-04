<# Stolen from
https://gist.github.com/FrankSpierings/99e216011ba9dff6b6c6
https://gist.github.com/dalton-cole/4b9b77db108c554999eb
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$True)]
    [string]$HashValue,
    [Parameter(Mandatory=$False,Position=2,ValueFromPipeline=$True)]
    [string]$StartString=$Null
)

Set-StrictMode -Version Latest

$Symbols = @('!','@','#','$','%','^','&','*','(',')','-','_','+','=','{','}','[',']',':',';','<','>',',','.','?')
$charset = @()
$charset += ([char]'0'..[char]'9') | ForEach-Object { [char]$_ }
$charset += ([char]'a'..[char]'z') | ForEach-Object { [char]$_ }
$charset += ([char]'A'..[char]'Z') | ForEach-Object { [char]$_ }
$charset +=  $Symbols | ForEach-Object { [char]$_ }

Function Get-NextString() {
  param($String)

  If (($Null -eq $String) -or ($String -eq '')) {
    # No string given; return the first character in charset
    Return [string]$charset[0]

  } else {
    For ($string_pos= ($String.Length-1); $string_pos -ge 0; $string_pos--) {
      $charset_pos = [array]::IndexOf($charset, $String[$string_pos])
      If ($charset_pos -eq ($charset.Length -1)) {
        $TempArray = $String.ToCharArray()
        $TempArray[$string_pos] = $charset[0]
        $String = $TempArray -join ""
        If ($string_pos -eq 0) { $String = $charset[0] + $String }
      } else {
        $TempArray = $String.ToCharArray()
        $TempArray[$string_pos] = $charset[$charset_pos+1]
        $String = $TempArray -join ""
        Break
      }
    }
    Return $String
  }
}

Function Get-MD5Hash {
  param($String)

  $md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
  $utf8 = new-object -TypeName System.Text.UTF8Encoding
  $hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($String)))
  $hash = $hash.ToLower() -replace '-', ''
  Return $hash

}

$String = $StartString
$HashValue = $HashValue.ToLower() -replace '-', ''
$MD5Hash = Get-MD5Hash $String

While ($MD5Hash -ne $HashValue) {
  $String = Get-NextString $String
  $MD5Hash = Get-MD5Hash $String
  Write-Host "$String  :  $MD5Hash"
}

Write-Host ":: $HashValue"
Write-Host ":: $MD5Hash"
Write-Host "`n$String`n"
