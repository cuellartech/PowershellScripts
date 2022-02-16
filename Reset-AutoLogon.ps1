<#
.SYNOPSIS
  Resets auto logon password 
.DESCRIPTION
  This script is used in the continuous update of the password for any
  auto logon accounts on the local computer. Runs from task sequence in
  order to pass credentials to run the necessary AD steps.
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:        1.0
  Author:         Manuel Cuellar
  Creation Date:  02/24/20
  Purpose/Change: Inital script creation
.EXAMPLE
  .\Reset-AutoLogon.ps1
#>

#Set parameters
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$False)]
  [String]$Username,
  [String]$Domain
)

#Get local path of script
$ScriptPath = $MyInvocation.MyCommand.Path
$WDir = Split-Path $ScriptPath

# Create an object to access the task sequence environment
$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment

$TSID = $tsenv.Value('SVCACCT')
$TSPass = $tsenv.Value('SVCACCTP')
$secPass = ConvertTo-SecureString -String $TSPass -AsPlainText -Force

$Creds = New-Object System.Management.Automation.PSCredential ($TSID, $secPass)

#Read username and domain from registry
$Key = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
$Domain = (Get-ItemProperty -Path $Key -Name DefaultDomainName).DefaultDomainName
$Username = (Get-ItemProperty -Path $Key -Name DefaultUserName).DefaultUserName

write-host "Grabbed $($Domain) and $($Username) from registry"

if(-not(Get-Module -ListAvailable -Name "activedirectory")) {
  Write-Host "Attempting to install RSAT tools for active directory..."
  Add-WindowsCapability -online -Source '\\spsccm\cmsource$\Operating Systems\Win10_FOD\W10_2004_FOD' -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"
  
  if(-not(Get-Module -ListAvailable -Name "activedirectory")) {
      Write-Host "RSAT tools not installed, exiting..."
      exit 1
  }
}

#Find Domain Controller for domain
$DC = Get-ADDomainController -DomainName $Domain -Discover -NextClosestSite

#Error check that the Username exists in Active Directory
function CheckUserInAD {
  try {
    Get-ADUser -Credential $Creds -Identity $Username -Server $DC
    return $True
  }
  catch [Microsoft.ActiveDirectory.Management.ADIdentityResolutionException] {
    return $False
  }
}

#Return a random 15 character password
function NewPassword {
  Add-Type -AssemblyName System.Web
  $LocalPass = [System.Web.Security.Membership]::GeneratePassword(15,5)
  return $LocalPass
}

#Exit with error if the user does not exist
if(-not(CheckUserInAD)) {
  Write-Host "User not in AD..."
  exit 1
}
else {
  Write-Host "Creating Password..."
  $Password = NewPassword
  $ADPass = ConvertTo-SecureString -String $Password -AsPlainText -Force
  
  Write-Host "Resetting password in AD..."
  Set-AdAccountPassword -Credential $Creds -Identity $Username -Server $DC -NewPassword $ADPass -Reset
  
  Write-Host "Resetting AutoLogin information..."
  Start-Process -FilePath "$WDir\Autologon.exe" -ArgumentList "/accepteula", $Username, $Domain, $Password -Wait

  Write-Host "Completed successfully"
}