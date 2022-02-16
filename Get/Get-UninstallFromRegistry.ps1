$finalapps = @()
$apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, UninstallString, DisplayVersion, Publisher, InstallDate

$apps += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, UninstallString, DisplayVersion, Publisher, InstallDate

$apps.ForEach({if ($_.DisplayName -ne $Null -and $_ -ne ''){$finalapps += $_}})

$finalapps|Out-GridView