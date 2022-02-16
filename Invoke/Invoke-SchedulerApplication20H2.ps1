$AppName = "Win10 v20H2 Enterprise Upgrade Helper"
$Application = (Get-CimInstance -ClassName CCM_Application -Namespace "root\ccm\clientSDK" -ComputerName $Computername | Where-Object {$_.Name -like $AppName})  
    
$Args = @{EnforcePreference = [UINT32] 0  
Id = "$($Application.id)"  
IsMachineTarget = $Application.IsMachineTarget  
IsRebootIfNeeded = $False  
Priority = 'High'  
Revision = "$($Application.Revision)"}    

Invoke-CimMethod -Namespace "root\ccm\clientSDK" -ClassName CCM_Application -MethodName "Install" -Arguments $Args  
