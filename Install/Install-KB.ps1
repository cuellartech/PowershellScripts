#House keeping
$scriptpath = $MyInvocation.MyCommand.Path
$wDir = Split-Path $scriptpath

Set-Location -Path $wDir

#Name of MSU needed to install
$KB = "windows10.0-kb5003791-x64.msu"

#Install KB
Start-Process -FilePath "wusa.exe" -ArgumentList "$wDir\$KB /quiet /norestart" -Wait