#House keeping
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

$i = 0 #Create counter
$arr = Get-ChildItem "C:\Users" | Where-Object {$_.PSIsContainer} #Create array of folders

#Loops through user profiles to remove installations
while ($i -le $arr.Length){
    
    #Set paths
    $ChromePath = [System.IO.Path]::Combine('C:\Users', $arr[$i], 'AppData', 'Local', 'Google', 'Chrome', 'Application')

    #Check if the paths exist and remove apps, clean up
    if (Test-Path -Path $ChromePath) {

        Start-Process $dir\uninstall.bat $arr[$i] -WindowStyle Hidden -Wait

    }
    
    #increase counter
    $i += 1
}

#Install Chrome
Start-Process MsiExec.exe @("/i $dir\googlechromestandaloneenterprise64.msi","/qn") -Wait