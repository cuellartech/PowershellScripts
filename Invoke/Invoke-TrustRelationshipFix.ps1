$PWord = $null
$CompInfo = @()
#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles\
Add-Type -AssemblyName System.DirectoryServices.AccountManagement

if(Get-Command –Module AdmPwd.PS){
    $Comp = Read-Host "Enter the Computername"
    if(Get-ADComputer -filter {name -eq $Comp}){
        Write-Host "`n`n$comp was found in AD."
        $adComp = Get-ADComputer $comp -Properties * | select Name, PasswordLastSet, DistinguishedName, ms-Mcs-AdmPwd
        $BitLockerObjects = Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $adComp.DistinguishedName -Properties 'msFVE-RecoveryPassword'
        $CompInfo = $adComp | select PasswordLastSet, Name, @{Name="LapsPassword"; Expression = {$adComp.'ms-Mcs-AdmPwd'} } , @{Name="BitLockerKey"; Expression = {$BitLockerObjects.'msFVE-RecoveryPassword'} } 
        $lapsInfo = Get-AdmPwdPassword $Comp
        $LPWord = $($lapsInfo.password)
        $DPWord = "W1tnl@p?"
        Try{
            $PWord = ConvertTo-SecureString -String $lapsInfo.password -AsPlainText -Force
            $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList "$Comp\Administrator", $PWord
            Invoke-Command -ComputerName $comp -ErrorAction Stop -ScriptBlock{} -Credential $Credential
            Write-Host "$comp has the LAPS password of: `'$LPWord`'"
            $CompInfo = $adComp | select PasswordLastSet, Name, @{Name="LapsPassword"; Expression = {$adComp.'ms-Mcs-AdmPwd'} } , @{Name="BitLockerKey"; Expression = {$BitLockerObjects.'msFVE-RecoveryPassword'} } 
            } 
        Catch{
            $PWord = ConvertTo-SecureString -String "$DPWord" -AsPlainText -Force
            $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList "$Comp\Administrator", $PWord
            Try{
                Invoke-Command -ComputerName $comp -ErrorAction Stop -ScriptBlock{} -Credential $Credential
                Write-Host "$comp has no LAPS working password attempting ITD Default password."
            }
            Catch{
                Write-Warning "$comp does not have known password or is not accesible on the network if recently restarted. Try again later or verify that firewall rules are correct then try again."
                $CompInfo | Format-List
                exit
            }
        }
        Write-Host "$comp Starting Invoke-Command."
        Invoke-Command -ComputerName $comp -ErrorAction Stop -ScriptBlock{
            $comp = $env:COMPUTERNAME
            $cred = Get-Credential "CENTRAL\"
            if(Test-ComputerSecureChannel -Credential $cred -Server central.pima.gov){
                Write-Warning "$comp trust seems functional. You may need to restart the computer."
            }
            else{
                try{
                    Test-ComputerSecureChannel -Repair -Credential $cred -Server central.pima.gov -ErrorAction Stop | Out-Null
                    Write-host "$comp trust is repaired. Computer will be restarted."
                    Restart-Computer -Force
                }
                Catch{
                    Write-warning "$comp trust could not be repaired, verify your credentials then run the script again."
                }
        
            }
        } -Credential $Credential

    }
    else{Write-Warning "$comp is not present in AD. Verify the name if correct, Please contact the Data Center Apps team and have them restore the object."}

}
else{Write-Host "You do not have the LAPS Powershell module installed. Please install the LAPS Powershell Module from the Add and Remove promams and by selecting 'Local Administrator Password Solution' then clicking on the change button. Run the scrip again once these changes are completed."}
$CompInfo | Format-List
pause