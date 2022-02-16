powercfg /H off

$val = Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name HibernateEnabled
    
if($val -eq 0) {
    return $true
}