$newEmployees = Get-ADUser -Filter {SamAccountName -like "u*" -and Office -like '33 N Stone Floor: 1'} -Properties SamAccountName, SurName, GivenName, Office, streetAddress, OfficePhone, Title, Department | Select-Object -Property @{Name='EIN';Expression={$_.SamAccountName}}, @{Name='LastName';Expression={$_.SurName}}, @{Name='FirstName';Expression={$_.GivenName}}, @{Name='Location';Expression={$_.streetAddress}}, @{Name='Floor';Expression={$_.Office}}, @{Name='Telephone';Expression={$_.OfficePhone}}, @{Name='JobTitle';Expression={$_.Title}}, Department


foreach($employee in $newEmployees){
    Write-Host $employee
}

Write-Host $newEmployees.Count