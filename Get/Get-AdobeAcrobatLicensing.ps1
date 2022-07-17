<#
.SYNOPSIS
    Gets Adobe Acrobat licensing information (Standard vs Pro) for Classic 
    installations
.DESCRIPTION
    Checks what version of Adobe Acrobat is installed (2015,2017, or 2020) and 
    then attempts to validate what version of licensing is present. It uses a
    file present that contains a unique Software ID dependent on licensing. 
    Outputs the version and license installed.
.NOTES
    Name: Get-AcrobatLicensing.ps1
    Author: Manuel Cuellar
    DateCreated: 2022-05-26
    Version 1.0
#>

$Acrobat2015 = Test-Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\`{AC76BA86-1033-FFFF-7760-0E0F06755100`} -ErrorAction Ignore
$Acrobat2017 = Test-Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\`{AC76BA86-1033-FFFF-7760-0e1108756300`} -ErrorAction Ignore
$Acrobat2020 = Test-Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\`{AC76BA86-1033-FFFF-7760-0E1401753200`} -ErrorAction Ignore

switch ($Acrobat2015, $Acrobat2017, $Acrobat2020) {
    { $Acrobat2015 -eq $true } { 
        $version = "2015"
        Break 
    }
    { $Acrobat2017 -eq $true } { 
        $version = "2017"
        Break 
    }
    { $Acrobat2020 -eq $true } { 
        $version = "2020"
        Break 
    }
    Default { Write-Host "No licensed Adobe Acrobat product found."; exit }
} 

$folderPath = "C:\ProgramData\regid.1986-12.com.adobe"

switch ($version) {
    "2015" { $swidtag = Get-Content "$($folderPath)\regid.1986-12.com.adobe_V7{}AcrobatESR-12-Win-GM-en_US.swidtag" -ErrorAction Ignore }
    "2017" { $swidtag = Get-Content "$($folderPath)\regid.1986-12.com.adobe_V7{}AcrobatESR-17-Win-GM-en_US.swidtag" -ErrorAction Ignore }
    "2020" { $swidtag = Get-Content "$($folderPath)\regid.1986-12.com.adobe_V7{}AcrobatESR-20-Win-GM-en_US.swidtag" -ErrorAction Ignore }
}

if ($swidtag) {
    $STDExists = $swidtag | ForEach-Object { $_ -match "9101" }
    $PROExists = $swidtag | ForEach-Object { $_ -match "9707" }
    
    if ($STDExists -eq $True) {
        Write-Host "Adobe Acrobat $version Standard is installed."
    }  
    elseif ($PROExists -eq $True) {
        Write-Host "Adobe Acrobat $version Pro is installed."
    }
    else { Write-Host "Adobe Acrobat $version is installed, but no license found." }
} else { Write-Host "Adobe Acrobat $version is installed, but no license found." }
