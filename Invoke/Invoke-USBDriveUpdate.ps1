#Self-elevate the script if required
$wPath = $MyInvocation.MyCommand.Path
$wArgs = $MyInvocation.UnboundArguments
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList @("-executionpolicy bypass","$wPath")
  Exit
 }
}
else{
Add-Type -AssemblyName PresentationCore,PresentationFramework
Add-Type –AssemblyName System.Windows.Forms
$ButtonType = [System.Windows.MessageBoxButton]::YesNo
$MessageboxTitle = “CMBOOT Update”
$usbcmboot = $null
#Get info for disks plugged into systems
$usbds = gwmi win32_diskdrive | ?{$_.interfacetype -eq "USB"} | %{gwmi -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($_.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"} |  %{gwmi -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($_.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"}
foreach ($usb in $usbds){
#Only for drives named CMBOOT.
if (($usb).VolumeName -eq 'CMBOOT'){$usbcmboot += "`n"+$usb.DeviceID+" "}
}
if ($usbcmboot){
    $Messageboxbody = “Are you sure you want to update the following drives?: $usbcmboot”
    $MessageIcon = [System.Windows.MessageBoxImage]::Warning 
    $OUTPUT= [System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$messageicon)
    if ($OUTPUT -eq "Yes" ){
        foreach ($cmboot in $usbds){
            if (($cmboot).VolumeName -eq 'CMBOOT'){
                $cmbo = ($cmboot).DeviceID
#If drive not FAT32 ask if OK to reformat
                if((Get-Partition -DriveLetter $cmbo.Substring(0,1)).type -notlike "*FAT32*"){
                    $Messageboxbody = “Your drive [$cmbo] is not formated correctly would you like to WIPE and FORMAT this drive?:”
                    $OUTPUT= [System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$messageicon)
                    if ($OUTPUT -eq "Yes" ){
                        $dNumber = (Get-Partition -DriveLetter $cmbo.Substring(0,1)).DiskNumber
                        clear-disk -Number $dNumber -RemoveOEM -RemoveData -Confirm:$false
                        Set-Disk -Number $dNumber -PartitionStyle MBR
                        New-Partition -DiskNumber $dNumber -UseMaximumSize -IsActive -AssignDriveLetter -MbrType FAT32 | Format-Volume -NewFileSystemLabel "CMBOOT" -FileSystem FAT32 -Confirm:$false
                    }
                    if ($OUTPUT -eq "No" ){
                        Exit
                    }
                    Write-Host "You have Not Exited"
                }
#Robocopy command to update older or missing files
                #Remove-Item $cmbo\* -Recurse -Force
                $rbsource = "$PSScriptRoot\Content"
                $rbswitch = "/IT /E /FFT /R:0 /W:0"
                $rbcmd = '"'+$rbsource+'"', '"'+$cmbo+'"', $rbswitch 
                cmd /c "c:\windows\system32\Robocopy.exe  $rbcmd"
            }
        }
        [System.Windows.Forms.MessageBox]::Show("Operation Complete.") 
    }
    else{
        [System.Windows.Forms.MessageBox]::Show("Operation Cancelled.") 
        }
}
else{
    [System.Windows.Forms.MessageBox]::Show("No CMBOOT detected. Operation Cancelled.") 
}
}