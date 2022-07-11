$computerName = $env:COMPUTERNAME

Start-Transcript -Path "C:\Windows\CCM\Logs\EUC\$computerName-SpectreMeltdownRemediation.log" -Append -IncludeInvocationHeader

Write-Host "Computer Name: $env:COMPUTERNAME"
Write-Host "Datestamp: $(Get-Date)"

$vLogicalCPUs = 0
$vPhysicalCPUs = 0
$vSocketDesignation = 0

$registryPath = "HKLM:\System\CurrentControlSet\Control\Session Manager\Memory Management"
$override = "FeatureSettingsOverride"
$mask = "FeatureSettingsOverrideMask"
$maskValue = "3"

# Get the Processor information from the WMI object
$vProcessors = [object[]]$(Get-CimInstance Win32_Processor)
    
# To account for older machines
if ($null -eq $vProcessors[0].NumberOfCores) {
 
    $vSocketDesignation = new-object hashtable
    $vProcessors | ForEach-Object { $vSocketDesignation[$_.SocketDesignation] = 1 }
    $vPhysicalCPUs = $vSocketDesignation.count
    $vLogicalCPUs = $vProcessors.count
} 
else {
    $vCores = $vProcessors.count
    $vLogicalCPUs = $($vProcessors | measure-object NumberOfLogicalProcessors -sum).Sum
    $vPhysicalCPUs = $($vProcessors | measure-object NumberOfCores -sum).Sum
}

Write-Host "Logical CPUs: $($vLogicalCPUs); Physical CPUs: $($vPhysicalCPUs); Number of Cores: $($vCores)"
 
if ($vLogicalCPUs -gt $vPhysicalCPUs) {
    Write-Host "Hyperthreading: Active"
    $overrideValue = "72"
}
else {
    Write-Host "Hyperthreading: Inactive"
    $overrideValue = "8264"
}

if (!(Test-Path $registryPath)) {
    Write-Host "$($registryPath) does not exist. Creating path."
    New-Item -Path $registryPath -Force | Out-Null
}

Write-Host "Adding $($override) as $($overrideValue)"
New-ItemProperty -Path $registryPath -Name $override -Value $overrideValue -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $registryPath -Name $mask -Value $maskValue -PropertyType DWORD -Force | Out-Null

$service = Get-Service -Name vmms -ErrorAction SilentlyContinue

if ($service.Length -gt 0) 
{
    Write-Host "Hyper-V Service is running, adding registry key."

    $registryPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Virtualization"
    $hyperV = "MinVmVersionForCpuBasedMitigations"
    $hyperVValue = "1.0"

    New-ItemProperty -Path $registryPath -Name $hyperV -Value $hyperVValue -PropertyType STRING -Force | Out-Null
}

Stop-Transcript
