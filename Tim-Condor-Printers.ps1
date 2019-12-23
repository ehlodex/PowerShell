[CmdletBinding()] Param();

# List of old printers by NAME                                          # # # # # # # #
$OldPrinters = @(
  "OldPrinter1",
  "\\10.10.10.10\OldPrinter2",
  "\\ServerName\OldPrinter3"
);                                                                      # end $OldPrinters

# Lookup old printers from the 10.* network                             # # # # # # # #
$ArrPrint = Get-Printer | Where-Object {($_.Name -like '10.*') -or ($_.PortName -like '10.*')}

# Loop through the $OldPrinters Array                                   # # # # # # # #
ForEach ($Printer in $OldPrinters) {                                    # ForEach in $OldPrinters
  $PrinterObject += try { Get-Printer -Name "*$Name*" } catch { }       # See if the printer is installed
  If ($PrinterObject) {                                                 # TRUE
    $ArrPrint += $PrinterObject                                         #  Add it to $ArrPrint
  } Else {                                                              # FALSE
    Write-Verbose "Could not find a printer named $Printer"             #  verbose
  }                                                                     # end "if"
}                                                                       # end "ForEach"

# Single printer, multiple printers, or no matches. -Verbose only       # # # # # # # #
try {                                                                   # T/c/f
    If ($ArrPrint.getType().BaseType.Name -eq "Object") {               #  if Object,
      $PrinterCount = 1                                                 #   then only one printer
    } Else {                                                            #  else, it's probably an array
      $PrinterCount = $ArrPrint.Count                                   #   so count the number of objects (printers)
    }                                                                   #  end "if"
} catch {                                                               # t/C/f
    $PrinterCount = 0;                                                  #  there are no printers
} finally {                                                             # t/c/F
    Write-Verbose "Preparing to remove $PrinterCount printer(s)."       #  write the total number of printers to remove
}                                                                       # end "t/c/f"

# Remove each printer in $ArrPrint                                      # # # # # # # #
ForEach ($Printer in $ArrPrint){                                        # ForEach in $ArrPrint
  Write-Verbose "Preparing to remove $($Printer.Name)..."               #  verbose
  Remove-Printer -Name $Printer.Name                                    #  remove
  If (Get-Printer -Name $Printer.Name) {                                #  if it's still there,
    Write-Verbose "Removal of $($Printer.Name) failed!";                #   verbose
    cmd /c RUNDLL32 PRINTUI.DLL,PrintUIEntry /gd /n$($Printer.name)     #   try again using rundll32
  } Else {                                                              #  else removal worked
    Write-Verbose "Successfully removed $($Printer.Name)"               #   verbose
  }                                                                     #  end "if"
}                                                                       # end "ForEach"
# https://community.spiceworks.com/topic/2248961-powershell-printer-scripts
