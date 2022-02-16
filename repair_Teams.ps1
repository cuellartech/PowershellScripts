#House keeping
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
$arr = Get-ChildItem "C:\Users" | Where-Object {$_.PSIsContainer} #Create array of folders
$i = 0 #Create counter

while ($i -le $arr.Length){
    
    #Set paths
    $TeamsPath = [System.IO.Path]::Combine('C:\Users', $arr[$i], 'AppData', 'Local', 'Microsoft', 'Teams')
    $TeamsUpdateExePath = [System.IO.Path]::Combine('C:\Users', $arr[$i], 'AppData', 'Local',  'Microsoft', 'Teams', 'Update.exe')

    #Check if the paths exist and remove apps, clean up
    if (Test-Path -Path $TeamsUpdateExePath) {

        # Uninstall app
        $proc = Start-Process -FilePath $TeamsUpdateExePath -ArgumentList "-uninstall -s" -PassThru
        $proc.WaitForExit()
    }
    if (Test-Path -Path $TeamsPath) {
        Remove-Item -Path $TeamsPath -Recurse
    }
    
    #increase counter
    $i += 1
}

#Run MSI to uninstall app
Start-Process -FilePath "msiexec.exe" -ArgumentList "/passive","/x","$dir\Teams.msi","/q" -Wait -Passthru

#Run MSI
(Start-Process -FilePath "msiexec.exe" -ArgumentList "/i","$dir\Teams.msi","/q" -Wait -Passthru).ExitCode