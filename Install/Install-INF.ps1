$Drivers = Get-ChildItem "C:\HP Universal Print Driver\pcl5-x64-6.1.0.20062" -Recurse -Filter "*.inf"
ForEach ($Driver in $Drivers) { 

        #PNPUtil.exe /add-driver $Driver.FullName /install 

        PNPUtil.Exe /delete-driver $Driver.Fullname /uninstall /force
        #PNPUtil.exe /add-driver $Driver.FullName /install 
}

 Add-PrinterDriver -Name "HP Universal Printing PCL 5 (v6.1.0)" -InfPath "C:\Windows\System32\DriverStore\FileRepository\hpcu180t.inf_amd64_e97fa3929f7fcd4a\hpcu180t.inf"

 Add-Printer -Name "ITD-BOA-014-P01" -DriverName "HP Universal Printing PCL 5 (v6.1.0)" -PortName "\\spprintsrv01\ITD-BOA-014-P01"

 Get-Printer -Name *

 Remove-Printer -Name "ITD-BOA-014-P01"