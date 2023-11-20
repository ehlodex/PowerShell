[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$True)]
    [string]$VM,
    [Parameter(Mandatory=$False,Position=2,ValueFromPipeline=$True)]
    [string]$GuestResolution="1440x900",
    [Parameter(Mandatory=$False,Position=3,ValueFromPipeline=$True)]
    [string]$VboxManage="C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
)

Set-StrictMode -Version Latest

& $VBoxManage modifyvm "$VM" --cpuidset 00000001 000106e5 00100800 0098e3fd bfebfbff
& $VBoxManage setextradata "$VM" "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "iMac19,1"
& $VBoxManage setextradata "$VM" "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"
& $VBoxManage setextradata "$VM" "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "Mac-AA95B1DDAB278B95"
& $VBoxManage setextradata "$VM" "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
& $VBoxManage setextradata "$VM" "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 1
& $VBoxManage setextradata "$VM" "VBoxInternal/TM/TSCMode" "RealTSCOffset"
& $VBoxManage setextradata "$VM" "VBoxInternal2/EfiGraphicsResolution" "$RES"

<#
@ECHO OFF
REM #### BATCH VERSION ####
REM # The VM display name in VirtualBox:
set VM="macOS"
REM # Full path to VBoxManage.exe:
set VBoxManage="C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
%VBoxManage% modifyvm %VM% --cpuidset 00000001 000106e5 00100800 0098e3fd bfebfbff
%VBoxManage% setextradata %VM% "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "iMac19,1"
%VBoxManage% setextradata %VM% "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"
%VBoxManage% setextradata %VM% "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "Mac-AA95B1DDAB278B95"
%VBoxManage% setextradata %VM% "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
%VBoxManage% setextradata %VM% "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 1
%VBoxManage% setextradata %VM% "VBoxInternal/TM/TSCMode" "RealTSCOffset"
%VBoxManage% setextradata %VM% "VBoxInternal2/EfiGraphicsResolution" "$RES"
#>
