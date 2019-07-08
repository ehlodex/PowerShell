# For maximum readability, enable syntax highlighting                                                                           # # # # # # # #
Set-StrictMode -Version Latest                                                                                                  # Require all variables to be initialized before use
# Each function was deveopled independently, and at different times. The format changes as I was learning.

# Configure Script-Specific Settings                                                                                            # # # # # # # #
  # Initialize Script (Local) Variables                                                                                         # # # #
  $DECOLS = "{0,-16} {1, -1}"                                                                                                   # PWSH DE -F (output format)
  $Domain = "corp.example.com";                                                                                                 # local domain for new user accounts
  $OU = "ou=My_Users,dc=corp,dc=example,dc=com";                                                                                # OU for new user accounts
  $Company = "The Example Corporation";                                                                                         # Used in AD user properties
  $HomeDrive = "K:"                                                                                                             # Drive letter for home folders
  $HomePath = "\\corp.example.com\dfs2\home";                                                                                   # Root path for home folders
  $PrimaryGroup = "ExampleCorpUser";                                                                                            # Override 'Domain Users' as default group
  # Import Required PowerShell Modules                                                                                          # # # #
  TRY { Import-Module ActiveDirectory } CATCH { Write-Error "Missing required module: ActiveDirectory"; Exit; }                 # ActiveDirectory

# Declare Functions (cmdlets)                                                                                                   # # # # # # # #

Function Add-Employee {                                                                                                         # # # # Add-Employee
[CmdletBinding()]                                                                                                               # Parameters
Param(                                                                                                                          #
  [Parameter(ValueFromPipelineByPropertyName=$TRUE,Mandatory=$TRUE,Position=1)] [string]$FirstName,                             # FirstName (LDAP, givenName)
  [Parameter(ValueFromPipelineByPropertyName=$TRUE,Mandatory=$TRUE,Position=2)]	[string]$LastName,                              # LastName (LDAP, sn)
  [Parameter(ValueFromPipelineByPropertyName=$TRUE,Mandatory=$TRUE,Position=3)] [string]$Division,                              # Department
  [Parameter(ValueFromPipelineByPropertyName=$TRUE,Mandatory=$TRUE,Position=4)] [string]$EmployeeNumber,                        # Internal Employee Number
  [Parameter(ValueFromPipelineByPropertyName=$TRUE,Mandatory=$TRUE,Position=5)] [string]$Title,                                 # Job Title
  [Parameter(ValueFromPipelineByPropertyName=$TRUE,Mandatory=$TRUE,Position=6)] [string]$EmployeeType,                          # PT/FT, etc
  [Parameter(ValueFromPipelineByPropertyName=$TRUE,Mandatory=$TRUE,Position=7)] [string]$Manager,                               # sAMAccountName
  [Parameter(ValueFromPipelineByPropertyName=$TRUE,Mandatory=$FALSE,Position=8)] [string]$Initial                               # Middle Initial (optional)
);                                                                                                                              # End Parameter Bindings
  BEGIN {                                                                                                                       # BEGIN/process/end for Add-Employee
  If ($PsBoundParameters['Verbose']) { $PWSHVE = $TRUE; } Else {$PWSHVE = $FALSE; };                                            # Verbose Execution
  If ($PsBoundParameters['Debug'])   { $PWSHDE = $TRUE; } Else {$PWSHDE = $FALSE; };                                            # Debug Execution
  } PROCESS {                                                                                                                   # begin/PROCESS/end for Add-Employee
  ## TODO: Check for existing account by First/Last Name, Division, etc.
  Switch -Wildcard ($Division) {                                                                                                # # Convert Division to Department
    "hr"  { $_ = "001"; }; "human*" { $_ = "001"; }                                                                             # 001 Human Resources
    "001" { $Division = "001"; $Department = "Human Resources"; break; }                                                        #
    "it"  { $_ = "042"; }; "infor*" { $_ = "042"; }                                                                             # 042 Information Technology
    "042" { $Division = "042"; $Department = "Information Technology"; break; }                                                 #
    default {                                                                                                                   # default
      $ERMSG = "The selected `$Division is invalid ($Division)."; Write-Error -Message $ERMSG;                                  # Error! Div/Dept does not match
      $DEMSG = "MODULE : ADManager / Add-Employee`n";                                                                           #
      $DEMSG += "Please use one of the following values:`n";                                                                    #
      $DEMSG += "001  :  HR  : Human Resources`n";                                                                              #
      $DEMSG += "0??  : DIV  : Division Name`n";                                                                                #
      $DEMSG += "042  :  IT  : Information Technology`n";                                                                       #
      Write-Debug $DEMSG;                                                                                                       # PWSH VE
      Return; }                                                                                                                 # Terminate the script
  };                                                                                                                            # End Switch ($Division)
  Write-Verbose "Successfully assigned Division ($Division) and Department ($Department).";                                     # PWSH VE
  If ($EmployeeType -like "f*") { $EmployeeType = "Full Time"; } Else { $EmployeeType = "Part Time"; };                         # Part Time or Full Time?
  $EmployeeID = "$Division-$EmployeeNumber";                                                                                    # Generate EmployeeID
  Write-Verbose "Determined that employee $EmployeeID is $EmployeeType.";                                                       # PWSH VE
  $sanCheck = $TRUE; $sanCounter = 0; While ($sanCheck) {                                                                       # # Search for duplicate SamAccountName
    $sanCounter++; $SAN = ("$($FirstName.SubString(0,$sanCounter))$LastName").ToLower();                                        # Method is adding letters from first name
    $sanCheck = Get-ADUser -Filter {SamAccountName -eq $SAN};                                                                   # See if the SAN is unique
  };                                                                                                                            # End Search for duplicates
  Write-Verbose "Assigned unique SAN ($SAN).";                                                                                  # PWSH VE
  $UPN = "$SAN@$DOMAIN";                                                                                                        # User Principal Name
  $FIU = ($FirstName.SubString(0,1)).ToUpper(); $FIL = $FIU.ToLower();                                                          # First Initial, Uppercase and Lowercase
  $LIU = ($LastName.SubString(0,1)).ToUpper(); $LIL = $LIU.ToLower();                                                           # Last Initial, Uppercase and Lowercase
  If ($Initial) { $Initial = $($Initial.SubString(0,1)).ToUpper(); }                                                            # Ensure that Initial is a single upper-case letter
  $Password = "$FIU$LIU$(([char]$FIU-64).ToString("00"))$(([char]$LIU-64).ToString("00"))$FIL$LIL" }                            # Generic password generator
  $FirstName = "$FIU$($($FirstName.substring(1)).ToLower())"; $LastName = "$LIU$($($LastName.substring(1)).ToLower())";         # Name cleanup
  Write-Verbose "Creating Account for $FirstName $Lastname ($SAN)";                                                             # PWSH VE
  $DEMSG = "MODULE : ADManager / Add-Employee`n";                                                                               #
  $DEMSG += $DECOLS -F "FirstName","$FirstName`n"; $DEMSG += $DECOLS -F "LastName","$LastName`n";                               #
  $DEMSG += $DECOLS -F "SAN","$SAN`n"; $DEMSG += $DECOLS -F "UPN","$UPN`n";                                                     #
  $DEMSG += $DECOLS -F "EmployeeID","$EmployeeID`n"; $DEMSG += $DECOLS -F "EmployeeNumber","$EmployeeNumber`n";                 #
  $DEMSG += $DECOLS -F "Department","$Department`n"; $DEMSG += $DECOLS -F "Job Title","$Title`n";                               #
  $DEMSG += $DECOLS -F "Manager","$Manager`n"; $DEMSG += $DECOLS -F "EmployeeType","$EmployeeType`n";                           #
  Write-Debug $DEMSG;                                                                                                           # PWSH DE
  # Active Directory Account Creation (no inline comments)                                                                      # #
  New-AdUser -Verbose:$PSHVE -Debug:$PSHDE -Server $Domain -Path $OU `
    -AccountPassword (ConvertTo-SecureString -AsPlainText $Password -Force) `
    -Company $Company `
    -Department $Department `
    -Description $Title `
    -DisplayName $("$FirstName $LastName") `
    -EmployeeID $EmployeeID `
    -EmployeeNumber $EmployeeNumber `
    -Enabled $TRUE `
    -GivenName $FirstName `
    -Initials $Initial `
    -Manager $Manager `
    -Name $("$FirstName $LastName") `
    -SamAccountName $SAN `
    -Surname $LastName `
    -Title $Title `
    -UserPrincipalName $UPN
  # End Active Directory Account Creation (no inline comments)                                                                  # #
  Enable-AdAccount -Server $Domain -Identity $SAN                                                                               # Enable the account
  Set-AdUser -Verbose:$PSHVE -Debug:$PSHDE -Server $Domain -Identity $SAN -Replace @{EmployeeType=$EmployeeType}                # Set Employee Type
  Switch -Wildcard ($ivision) {                                                                                                 # # Per-Division Customizations
    "0*" {                                                                                                                      # Divisions 001-099 (ish)
    Write-Verbose "Determined that the employee is administrative. Performing additional configs."                              # PWSH VE
    $HomeFolder = $HomePath + "\" + $SAN;                                                                                       # Assign home folder
    If (!(Test-Path $HomeFolder)) { New-Item -Type Directory -Path $HomeFolder -ErrorAction SilentlyContinue }                  # Create Home Folder
    $ACL = Get-Acl $HomeFolder                                                                                                  # Access Control List for HomeFolder
	  $ACE = New-Object system.security.accesscontrol.filesystemaccessrule($SAN,"FullControl","ContainerInherit, ObjectInherit", "None","Allow")
	  $ACL.SetAccessRule($ACE)                                                                                                    # Add an Access Control Entry (Rule) to the ACL
	  Set-Acl $HomeFolder $ACL                                                                                                    # Apply the updated ACL to HomeFolder
    Set-ADUser -Identity $SAN -HomeDrive $HomeDrive -HomeDirectory $HomeFolder                                                  # Set Active Directory HomeDirectory
    Try { Add-ADGroupMember -Identity "Personal DFS" -Members $SAN } Catch {}                                                   # Group Membership
    };
    default { Write-Verbose "Determined that the employee is non-admin. No additional tasks to complete."; };
    };                                                                                                                          # End Swich ($Division)
  $GetAdGrp = Get-ADGroup $PrimaryGroup; $AdGroupSID = $GetAdGrp.sid;                                                           # Pre-processing for $GrpID
  [int]$GrpID = $AdGroupSID.Value.Substring($AdGroupSID.Value.LastIndexOf("-")+1)                                               # Integer value for primary AD Group
  Add-AdGroupMember -Identity $PrimaryGroup -Members $SAN                                                                       # Add user to the primary group
  Get-ADUser -Identity $SAN | Set-ADObject -Replace @{primaryGroupID = "$GrpID"}                                                # Set group as primary
  } END {                                                                                                                       # begin/process/END for Add-Employee
  };                                                                                                                            # End begin/process/end for Add-Employee
};                                                                                                                              # # End Add-Employee

Function Initialize-Password {                                                                                                  # # # # Initialize-Password
[CmdletBinding()]                                                                                                               # Parameters
Param(                                                                                                                          #
  [Parameter(ValueFromPipeline=$TRUE,Mandatory=$TRUE,Position=1)] [string]$Identity,                                            # Identity
  [Parameter(Mandatory=$FALSE)] [switch]$Confirm = $TRUE                                                                        # Confirm?
);                                                                                                                              # End Parameters

  BEGIN {                                                                                                                       # BEGIN/process/end for Initialize-Password
  If ($PsBoundParameters['Verbose']) { $PSVE = $TRUE; } Else {$PSVE = $FALSE; };                                                # Verbose Execution
  If ($PsBoundParameters['Debug'])   { $PSDE = $TRUE; } Else {$PSDE = $FALSE; };                                                # Debug Execution
} PROCESS {                                                                                                                     # begin/PROCESS/end for Initialize-Password
  $USR = Get-AdUser -Filter {samAccountName -eq $Identity} -Properties *;                                                       # Check account validity
  try { $SAM = $USR.samAccountName; } catch { Write-Warning "Unable to locate employee $Identity"; RETURN; };                   # Fail if user does not exist
  $NUM = $USR.EmployeeNumber; If (!($NUM)) { Write-Warning "EmployeeNumber not set for $($USR.Name) ($Identity)"; RETURN; };    # Fail if EmployeeNumber is blank
  Write-Verbose "Located account $SAM ($NUM)";                                                                                  # PWSH VE
  $Password = "Lcta$NUM";                                                                                                       # New password
  $LastLogon = $USR.LastLogonDate; $LogonAge = (Get-Date).AddDays(-90);                                                         # Require 90 days inactivity
  If (($LastLogon -gt $LogonAge) -and ($Confirm)) {                                                                             # if LastLogonDate
    Write-Warning "$($USR.Name) has logged in within the past 90 days!"                                                         # Warn: User is active
    $YON = Read-Host "Are you sure you want to initialize the password for $SAM`?";                                             # Prompt: Y or N
    If (($YON -ne "y") -or ($YON -ne "Y")) { RETURN; };                                                                         # Stop if not yes
  } Else {                                                                                                                      # else LastLogonDate
    Set-AdAccountPassword -Identity $Identity -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force) -Reset        # Set password
    Write-Verbose "Password initialization complete for $Identity";                                                             # PWSH VE
  };                                                                                                                            # fi LastLogonDate
} END {                                                                                                                         # begin/process/END for Initialize-Password
  Write-Verbose "End Initialize-Password";                                                                                      # PWSH VE
};                                                                                                                              # End begin/process/end for Initialize-Password
};                                                                                                                              # # End Initialize-Password

Function Get-HomeDirectory {                                                                                                    # # # # Get-HomeDirectory
[CmdletBinding()]                                                                                                               # Parameters
Param(                                                                                                                          #
  [Parameter(ValueFromPipeline=$TRUE,Mandatory=$TRUE,Position=1)]                                                               # Identity
    [string]$Identity                                                                                                           #
);                                                                                                                              # End Parameters
  BEGIN {                                                                                                                       # BEGIN/process/end for Get-HomeDirectory
  If ($PsBoundParameters['Verbose']) { $PSVE = $TRUE; } Else {$PSVE = $FALSE; };                                                #  PowerShell Verbose Execution
  If ($PsBoundParameters['Debug'])   { $PSDE = $TRUE; } Else {$PSDE = $FALSE; };                                                #  PowerShell Debug Execution
} PROCESS {                                                                                                                     # begin/PROCESS/end for Get-HomeDirectory
  $USR = Get-AdUser -Filter {samAccountName -eq $Identity} -Properties *;                                                       #  Check account validity
  try { $SAM = $USR.samAccountName; } catch { Write-Warning "Unable to locate employee $Identity"; RETURN; };                   #  Fail if user does not exist
  Write-Verbose "Located account $SAM";                                                                                         #  PSVE
  Get-AdUser $Identity -Properties HomeDirectory -Verbose:$PSVE -Debug:$PSDE | Format-Table Name,HomeDirectory                  # Get the HomeDirectory value from AD
} END {                                                                                                                         # begin/process/END for Get-HomeDirectory
  Write-Verbose "End Initialize-Password";                                                                                      #  PSVE
};                                                                                                                              # begin/process/end for Get-HomeDirectory

};                                                                                                                              # # End Initialize-Password

# Aliases, &c.                                                                                                                  # # # # # # # #
New-Alias initpass Initialize-Password;                                                                                         # initpass

# Export                                                                                                                        # # # # # # # #
Export-ModuleMember -alias * -function *
