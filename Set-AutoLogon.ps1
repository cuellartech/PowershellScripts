<#
.SYNOPSIS
  Initial auto logon registry edit and password change
.DESCRIPTION
  This script is used in the initial setup of auto logon accounts of their password in AD and the registry entry, 
  works in tandem with Sysinternals autologon.exe which should be in the root of the folder 
  with this script.
.INPUTS
  The Username and domain of the account
.OUTPUTS
  None
.NOTES
  Version:        2.0
  Author:         Manuel Cuellar
  Creation Date:  02/11/20
  Purpose/Change: Initial working version, must be admin
.EXAMPLE
  .\Init-AutoLogon.ps1
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

$TSPass = $tsenv.Value('TSCMSIAP')
$TSID = $tsenv.Value('TSCMSIA')

$Creds = New-Object System.Management.Automation.PSCredential ($TSID, $TSPass)

#Prompt for username and domain
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$Username = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the username", "Username prompt")
$Domain = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the domain", "Domain prompt")

#Find Domain Controller for domain
$DC = Get-ADDomainController -DomainName $Domain -Discover -NextClosestSite

#Checks for regular and A accounts for extra error checking, and to not set them for autologin
if($Username -like "A1*" -or $Username -like "U*") {
  Write-Error -Message "User was detected as $($Username) which is not valid." `
  -Category InvalidArgument -CategoryReason "Username not valid" -TargetObject $Username
  exit 1
}

if(-not(Get-Module -ListAvailable -Name "activedirectory")) {
  Add-WindowsCapability -online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"
  
  if(-not(Get-Module -ListAvailable -Name "activedirectory")) {
      Write-Host "Please install AD powershell module"
      exit 1
  }
}

#Error check that the Username exists in Active Directory
function CheckUserInAD {
  try {
    Get-ADUser -Identity $Username -Server $DC
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
  "User `"$($Username)`" does not exist in Active Directory on domain `"$($Domain)`". Please enter a valid Username."
  exit 1
}
else {
  "User `"$($Username)`" does exist!"
  
  $Password = NewPassword
  $ADPass = ConvertTo-SecureString -String $Password -AsPlainText -Force
  
  Set-AdAccountPassword -Identity $Username -Server $DC -NewPassword $ADPass -Reset

  $tsenv.Value("Domain") = $Domain
  $tsenv.Value("Username") = $Username

  Start-Process -Credential $Creds -FilePath "$WDir\Autologon.exe" -ArgumentList "/accepteula", $Username, $Domain, $Password -Wait
}