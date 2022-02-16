#remove KB5000808
#sfc scannow
Start-Process wusa.exe -ArgumentList "/uninstall /KB:5000808 /quiet /norestart" -Wait