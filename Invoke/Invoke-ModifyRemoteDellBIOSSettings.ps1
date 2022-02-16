IF (!(get-module DellBIOSProvider)){
Import-Module DellBIOSProvider
}

$computer = Read-Host "Enter Computer Name"

$session = New-PSSession -ComputerName $computer

$BIOSSettings = Invoke-Command -session $session -ScriptBlock {
        Import-Module DellBIOSProvider
        get-childitem -path DellSmbios:\ | Select-Object category | 
        ForEach-Object {
                    get-childitem -path @("DellSmbios:\" + $_.Category)  | Select-Object attribute, currentvalue, possiblevalues, PSPath 
                 }
    }
   $changesetting = $BIOSSettings|Select-Object attribute, currentvalue, possiblevalues, PSPath|Out-GridView -Title "Select setting to change" -OutputMode Single
   IF ($changesetting) {
           Write-Host "Setting:" $changesetting.attribute
           Write-Host "Current value:" $changesetting.CurrentValue
           Write-Host "Possible values:" $changesetting.PossibleValues
           $finalsetting = Read-Host "Enter desired setting"
           $option = [System.StringSplitOptions]::RemoveEmptyEntries
           $settingpath = join-path -path (($changesetting.PSPath).split("::",2,$option)[1]) -childpath $changesetting.attribute
           Invoke-Command -session $session -Argumentlist @($settingpath,$finalsetting) -ScriptBlock {
           Import-Module DellBIOSProvider
           set-item -path $args[0] -value $args[1] -password 'Enterprise1'}
   }
   Remove-PSSession -Session $session

   