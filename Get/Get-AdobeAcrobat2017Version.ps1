# Site configuration
$SiteCode = "" # Site code 
$ProviderMachineName = "" # SMS Provider machine name

# Import the ConfigurationManager.psd1 module 
if ($null -eq (Get-Module ConfigurationManager)) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" 
}

# Connect to the site's drive if it is not already present
if ($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName
}

$PSD = Get-PSDrive -PSProvider CMSite

Set-Location "$($PSD):"

$members = Get-CMCollectionMember -CollectionId PX102A10 | Select-Object -ExpandProperty name

$results = @()

$results += Invoke-Command -ComputerName $members -ErrorAction SilentlyContinue -ScriptBlock {
    $swidtag = Get-Content 'C:\ProgramData\regid.1986-12.com.adobe\regid.1986-12.com.adobe_V7{}AcrobatESR-17-Win-GM-en_US.swidtag' -ErrorAction Ignore
    
    $STDExists = $swidtag | ForEach-Object { $_ -match "9101" }
    
    $PROExists = $swidtag | ForEach-Object { $_ -match "9707" }
    
    $PathStatus = test-path 'C:\ProgramData\regid.1986-12.com.adobe\regid.1986-12.com.adobe_V7{}AcrobatESR-17-Win-GM-en_US.swidtag' -ErrorAction Ignore
    
    $RegPathStatus = test-path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\`{ac76ba86-1033-ffff-7760-0e1108756300`} -ErrorAction Ignore
    
    if ($PathStatus -eq $True -And $RegPathStatus -eq $True) {
    
        if ($PROExists -eq $True) {
            $result = [PSCustomObject]@{
                Host    = $env:COMPUTERNAME
                Version = "PRO"
            } 
        }
        elseif ($STDExists -eq $True) {
            $result = [PSCustomObject]@{
                Host    = $env:COMPUTERNAME
                Version = "STD"
            }
        }
    } 
    else {
        $result = [PSCustomObject]@{
            Host    = $env:COMPUTERNAME
            Version = "Acrobat 2017 is not installed."
        }
    }
    return $result
}

$results | Select-Object Host, Version | Out-GridView
