$days = '60' #Show Profiles logged into within the last $day
$computer = 'IT-LL-HYPFP1'

#Get profiles that meet the criteria
$ProfileResults = Get-CimInstance -ComputerName $computer -Class Win32_UserProfile | Where-Object { (($_.LastUseTime -gt $(Get-Date).Date.AddDays(-$days)) -and ($_.Special -ne $true) -and ($_.LocalPath -ne "C:\Users\Administrator")) } 

#Select from those profiles using limited columns
$Results = $ProfileResults|Select LocalPath, LastUseTime| out-gridview -Title 'Select Profiles to Remove' -PassThru

#Remove the selected profiles using the original object
FOREACH ($profile in $Results) { $ProfileResults|Where-Object {($_.LocalPath -eq $Profile.LocalPath)}|Remove-CimInstance -Verbose }

#Prompt for Yes/No to Rollback
IF ((Read-Host "Rollback OS on $($computer)? (yes/no)") -eq 'yes'){
invoke-command -ComputerName $computer -ScriptBlock {DISM /Online /Initiate-OSUninstall}
}
#Wait 5 minutes, then run the following (or restart the computer)
#Restart-Computer -ComputerName $Computer -Force