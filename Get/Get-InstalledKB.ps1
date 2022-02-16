$result = systeminfo.exe | findstr KB5008876

if ($result)
 {
    Write-Output "Found KB5008876"
    exit 0
 }
 else
 {
    exit 1
 }