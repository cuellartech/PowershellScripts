<#
This script performs inital client checks on a collection of remote hosts where the SCCM client failed to upgrade/install.
#>

#Running Function

# Input the process you want to monitor, returns when the process is finished

Function Running($proc)

{

    $Now = "Exists"

    While ($Now -eq "Exists")

    {

        If(Get-Process $proc -ErrorAction silentlycontinue)

        {

            $Now = "Exists"

            Write-host "INFO   : $proc is running, waiting 15 seconds" -ForegroundColor Green

            Sleep -Seconds 15

        }

        Else

        {

            $Now = "Nope"

            Write-host "INFO   : $proc has finished running" -ForegroundColor Green


        }

    }

}

$Collection = "All Computers with NO SCCM Client Installed"
$SiteServer = "SPSCCM"
$SiteCode = "PIM"
$LogLoc = "f:\cmsource\scripts\SCCM\Client\sccmlogs"
$exe = "C:\Windows\ccmsetup\ccmsetup.exe"
$Uarg = "/uninstall"
$Iarg = "smssitecode=PIM"
 
#####################################
# Get the members of the collection #
#####################################
 
cls
write-host "###########################################"
write-host "# ConfigMgr Client Upgrade Failure Script #"
Write-Host "###########################################"
Write-Host ""
write-host "Getting members of '$collection' collection"
 
#$s = New-PSSession -ComputerName $SiteServer
#Invoke-Command -Session $s -Argu $Collection -ScriptBlock `
#{
#param ($Collection)
Import-Module 'E:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
$Drive = $SiteCode + ':'
cd $Drive
 
$Computernames = @(Get-CMDevice -CollectionName $Collection | Select Name | Sort Name)
foreach ($ComputerName in $Computernames)
    {$ComputerName = $ComputerName.Name
    $ComputerName | out-file -filepath $LogLoc\Staging\ClientCSVs\computernames.csv -Append
    }
$Countremote = (Get-CMDevice -CollectionName $Collection | Select Name).Count
#}
#$countlocal = Invoke-Command -Session $s -ScriptBlock { $countremote }
#Remove-PSSession $s
#write-host "Collection contains $countlocal members"
 
################################################################
# Create local directories to store files, and create CSV file #
################################################################
 
# Create Directory for files if doesn't exist
if (Test-Path $LogLoc\ClientLogFiles)
{}
else
{
New-Item -Path "$LogLoc\ClientLogFiles" -ItemType Directory | Out-Null
}
New-Item -Path "$LogLoc\ClientLogFiles\$(Get-Date -Format yyyy-MM-dd-HH-mm)" -ItemType Directory | Out-Null
$location = "$LogLoc\ClientLogFiles\$(Get-Date -Format yyyy-MM-dd-HH-mm)"
 
# Create CSV file with headers
$headers = "Computer Name,Machine is online?,Can connect to admin$ share?,C:\Windows\CCM folder exists?,C:\Windows\ccmsetup exists?,C:\Windows\ccmsetup\scepinstall.exe,C:\Windows\ccmsetup\Logs exists?"
$headers | Out-File -FilePath $location\report.csv -Encoding UTF8
 
########################################
# Check each machine in the collection #
########################################
cd c:\ 
Write-Host 'Getting data for:'
 
$csv = Get-Content $LogLoc\Staging\ClientCSVs\computernames.csv
 
# Get data for each computer
Foreach ($ComputerName in $csv)
{
$online = $null,$admin = $null,$ccm = $null,$ccmsetup = $null,$scep = $null,$logs = $null
$ComputerName
 
# Test connectivity to the computer
if (Test-Connection -Quiet -Count 2 -ComputerName $ComputerName -ErrorAction SilentlyContinue)
    {
    $Online = "Yes"
    }
else
    {
    $Online = "No"
    Write-host " Offline" -ForegroundColor Gray
    }
 
# Test admin$ path
if ($Online -ne "No")
    {
    if (Test-Path \\$ComputerName\admin$)
     {
     $admin = "Yes"
     }
     else
     {
     $admin = "No"
     Write-host " Cannot connect to admin$ share" -ForegroundColor Red
     }
    }
 
# Test CCM folder
if ($admin -ne "No")
{
if (Test-Path \\$ComputerName\C$\Windows\CCM)
{
$ccm = "Yes"
}
else
{
$ccm = "No"
}
 
# Test ccmsetup folder
if (Test-Path \\$ComputerName\C$\Windows\ccmsetup)
{
$ccmsetup = "Yes"
}
else
{
$ccmsetup = "No"
}
 
# Test if scepinstall.exe is present
if ($ccmsetup -ne "No")
{
if (Test-Path \\$ComputerName\C$\Windows\ccmsetup\scepinstall.exe)
{
$scep = "Yes"
}
else
{
$scep = "No"
}

#copy ccmsetup
if ($ccmsetup -eq "Yes") {
    if (Test-Path \\$ComputerName\C$\Windows\ccmsetup\ccmsetup.exe){
        invoke-command $computername -scriptblock {
         &"C:\Windows\ccmsetup\ccmsetup.exe" /uninstall
         $proc = get-process ccmsetup
         $proc.WaitForExit()
         }
    }
    
    Remove-Item -Path C:\Windows\ccmsetup\* -Recurse -Exclude "logs" -ErrorAction SilentlyContinue 
    Copy-Item '\\SPSCCM\CMSource$\Applications\Microsoft\SCCM\Client\ccmsetup.exe' '\\ITD-ADW006-M008\C$\Windows\ccmsetup'
        if (Test-Path \\$ComputerName\C$\Windows\ccmsetup\ccmsetup.exe)
        {
        #If BITS service is not started, start it
        If((Get-Service -Name 'BITS').status -ne "Running"){
         Set-Service 'BITS' -StartupType Automatic
         Start-Service -Name 'BITS'}

         #install ccmsetup
         invoke-command $computername -scriptblock {
         &"C:\Windows\ccmsetup\ccmsetup.exe" smssitecode=PIM
         $proc = get-process ccmsetup
         $proc.WaitForExit()
         #Running CCMSetup
         }

         } 
        }
        else
        {
        Write-host " Ccmsetup copy failed" -ForegroundColor Red
        }
        
        
 
# Copy ccmsetup logs
if (Test-path \\$ComputerName\C$\Windows\ccmsetup\Logs)
{
$logs = "Yes"
}
else
{
$logs = "No"
}
if ($logs -eq "Yes")
{
Copy-Item \\$ComputerName\C$\Windows\ccmsetup\Logs $location\$ComputerName\Logs -Recurse
}
}
}
 
###########################
# Output data to CSV file #
###########################
 
$list = "$ComputerName,$online,$admin,$ccm,$ccmsetup,$scep,$logs"
$list | Out-File -FilePath $location\report.csv -Encoding UTF8 -Append
$online = $null,$admin = $null,$ccm = $null,$ccmsetup = $null,$scep = $null,$logs = $null
}
# Delete temp csv
Remove-Item $LogLoc\Staging\ClientCSVs\computernames.csv
 
# Open the directory
Invoke-Item $location
