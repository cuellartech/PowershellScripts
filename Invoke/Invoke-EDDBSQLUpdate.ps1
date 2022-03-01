#SQL Connection Query
Function SQL_CONNECT ($Query){

    $ConnectionString = "server=SPSCCMDWDB;database=EDDB;trusted_connection=True;Integrated Security = True;"    
    $SqlConnection = New-Object System.Data.SQLClient.SQLConnection($ConnectionString)
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.Connection = $SqlConnection
    $SqlCmd.CommandText = $Query
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd
    $DataSet = New-Object System.Data.DataSet
    try {
        $SqlAdapter.Fill($DataSet) | Out-Null
    }
    catch {
        Write-Host "-- This query produced an error:"
        $Query
        continue
    }
    $SqlConnection.Close()
    $DataSet.Tables[0]
}

function Get-SafeSQLString ($strInput) {
    # If the input string is not null
    if($null -eq $strInput -OR $strInput -eq "" -OR ([DBNull]::Value) -eq $strInput) {return}
    if($null -ne $strInput -and $strInput -ne "") {
        # Replace values as needed
        return $strInput.Replace("'","''")
    }
    Else {return}
}

#### Get all new employees ####  

Write-Host "Getting new employees within the last three weeks..." `n

$When = ((Get-Date).AddDays(-21)).Date
$newEmployees = Get-ADUser -Filter {whenCreated -ge $When -and SamAccountName -like "u*"} -Properties SamAccountName, SurName, GivenName, Office, streetAddress, OfficePhone, Title, Department | Select-Object -Property @{Name='EIN';Expression={$_.SamAccountName}}, @{Name='LastName';Expression={$_.SurName}}, @{Name='FirstName';Expression={$_.GivenName}}, @{Name='Location';Expression={$_.streetAddress}}, @{Name='Floor';Expression={$_.Office}}, @{Name='Telephone';Expression={$_.OfficePhone}}, @{Name='JobTitle';Expression={$_.Title}}, Department

foreach($newEmployee in $newEmployees){

    $currentEIN = $newEmployee.EIN
    $currentLocation = $newEmployee.Location
    $department = $newEmployee.Department
    $title = $newEmployee.JobTitle

    if($department -like "*Board*" -or $department -like "*Court*" -or $department -like "*Recorder*"){
        continue
    }

    if(($null -eq $department) -or ($department -eq "")){
        if(($null -eq $title) -or ($title -eq "")){
            continue
        }
    }

    $exist = SQL_CONNECT "
    SELECT [EIN]
    FROM [EDDB].[dbo].[Employees]
    WHERE EIN = '$currentEIN'"

    if(($null -eq $exist) -or ($exist -like 0)){

        $cLocation = SQL_CONNECT "
        SELECT [LOCATION]
        FROM [EDDB].[dbo].[LocationCodes]
        WHERE LOWER(ADDRESS) like LOWER('%$currentLocation%')
        "

        if(($null -eq $cLocation) -or ($cLocation -like 0)){
            $insertLoc = "No Location Found"
        } else {$insertLoc = $cLocation.Location}

        SQL_CONNECT "
        INSERT INTO Employees (EIN,LastName,FirstName,Location,Floor,Telephone,JobTitle,Department,Status) VALUES ('$($newEmployee.EIN)','$(Get-SafeSQLString($newEmployee.LastName))','$(Get-SafeSQLString($newEmployee.FirstName))','$($insertLoc)','1','$($newEmployee.Telephone)','$($newEmployee.JobTitle)','$($newEmployee.Department)','NewlyInserted')
        "
    } else {
    }
}

Write-Host "There are" $newEmployees.Count "new employees..." `n

#### Clean old employees ####

$employeesSQL = SQL_CONNECT "
SELECT [EIN]
        ,[JobTitle]
        ,[Department]
FROM [EDDB].[dbo].[Employees]
WHERE Department like '%'"

Write-Host "Updating employee status in the database..." `n

foreach($employee in $employeesSQL){
    if($null -eq $employee.EIN){
        continue
    }
    try{
        $employeeAD = Get-AdUser -Identity $($employee.EIN) -Properties SamAccountName, Enabled
    }
    catch{
        try{
            SQL_CONNECT "UPDATE [EDDB].[dbo].[Employees]
            SET Status = 'NotInAD'
            WHERE EIN = '$($employee.EIN)'"} catch{}
        continue
    }
    if($employeeAD.Enabled -like "False"){
        try {
            SQL_CONNECT "UPDATE [EDDB].[dbo].[Employees]
            SET Status = 'DisabledInAD'
            WHERE EIN = '$($employee.EIN)'" } catch{}
        continue
    }

    $currentEmployee = Get-ADUser -Identity $($employee.EIN) -Properties SamAccountName, SurName, GivenName, Office, streetAddress, OfficePhone, Title, Department | Select-Object -Property @{Name='EIN';Expression={$_.SamAccountName}}, @{Name='LastName';Expression={$_.SurName}}, @{Name='FirstName';Expression={$_.GivenName}}, @{Name='Location';Expression={$_.Office}}, @{Name='Floor';Expression={$_.streetAddress}}, @{Name='Telephone';Expression={$_.OfficePhone}}, @{Name='JobTitle';Expression={$_.Title}}, Department
    
    if($currentEmployee.JobTitle -notlike $employee.JobTitle) {
        try{
            Write-Host "Updating" $employee.EIN "'s job title."
            SQL_CONNECT "UPDATE [EDDB].[dbo].[Employees]
            SET JobTitle = '$($currentEmployee.JobTitle)'
            WHERE EIN = '$($employee.EIN)'"
        } catch{}
    } 
    
    if ($currentEmployee.Department -notlike $employee.Department) {
        try{
            Write-Host "Updating" $employee.EIN "'s department."
            SQL_CONNECT "UPDATE [EDDB].[dbo].[Employees]
            SET Department = '$($currentEmployee.Department)'
            WHERE EIN = '$($employee.EIN)'"
        } catch{}
    }
}

$oldEmployees = SQL_CONNECT "
SELECT [EIN]
FROM [EDDB].[dbo].[Employees]
WHERE Status = 'NotInAD'"

if($oldEmployees.Count -gt 0){
    Write-Host "There are" ($oldEmployees.Count-1) "employees marked for deletion from database. Would you like to continue?"
    $cont = Read-Host "Enter y/n" `r`n
}

#Delete old/disabled accounts

if($cont -like "y"){
    Write-Host "Deleting employees from database" `n
    foreach ($employee in $oldEmployees) {
        $oldEIN = $employee.EIN

        SQL_CONNECT "
        DELETE FROM Employees
        WHERE EIN = '$($oldEIN)'
        "
    }
} else {}