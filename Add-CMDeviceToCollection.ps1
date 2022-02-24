Import-Module 'C:\Program Files (x86)\ConfigMgrConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue

Set-Location 'PIM:'

$device = Get-CMDevice -Name "ComputerName" | Select-Object ResourceID

Get-CMCollection -Name "tdx-install" | Add-CMDeviceCollectionDirectMembershipRule -ResourceId $device.ResourceID