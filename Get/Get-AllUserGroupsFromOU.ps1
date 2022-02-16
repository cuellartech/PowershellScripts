$gOut = @()
$nams = (Get-ADUser -Filter {(SamAccountName -like "u*")} | where{$_.DistinguishedName -like "*OU=Client Services,OU=Technical Infrastructure,OU=Enterprise Infrastructure,OU=Divisions,OU=ITD,OU=ENT Support Services,OU=Central Departments,DC=central,DC=pima,DC=gov"}).SamAccountName
foreach($nam in $nams){    
    $a = (Get-ADUser $nam -Properties memberof| Select-Object MemberOf).memberof
    $fnam = (Get-ADUser $nam -Properties memberof).name
    $groups = ($a| foreach{$_.split(",")[0]}).substring(3)
    foreach($group in $groups){
        $obj = New-Object PSObject
        $obj | Add-Member NoteProperty UserName $nam
        $obj | Add-Member NoteProperty FullName $fnam          
        $obj | Add-Member NoteProperty Group $group
        $gOut += $obj
    }
}
$gOut | Export-Csv -Path "$PSScriptRoot\Groups.csv" -Force