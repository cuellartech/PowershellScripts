$cUser = (Get-WMIObject -class Win32_ComputerSystem | select username)

$toTrim = $cUser.Username.Substring(0,$cUser.username.IndexOf("\")) + "\"

$uN = $cUser.username.TrimStart($toTrim)

$testPath = 'C:\Users\' + $uN + '\AppData\Local\NBS\DFAST3'

if($testPath)
    { Write-Host "Installed" }
else {}