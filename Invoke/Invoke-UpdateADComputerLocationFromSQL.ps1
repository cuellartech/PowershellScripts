Function SQL_CONNECT ($Query){

    $ConnectionString = "server=SDITDDB;database=RBDDB;trusted_connection=True;Integrated Security = True;"    
    $SqlConnection = New-Object  System.Data.SQLClient.SQLConnection($ConnectionString)
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.Connection = $SqlConnection
    $SqlCmd.CommandText = $Query
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd
    $DataSet = New-Object System.Data.DataSet
    $a = $SqlAdapter.Fill($DataSet)
    $SqlConnection.Close()
    $DataSet.Tables[0]
}


$sqlHWInfo = SQL_CONNECT "SELECT  AssetData.NewComputerName, AssetData.Location FROM AssetData INNER JOIN RolloutHardware ON AssetData.DeviceID = RolloutHardware.DeviceID WHERE DeploymentYear = '2020' AND AssetData.Location is not null and AssetData.Location != '' AND NewComputerName LIKE '%-__-______"
$sqlHWInfod = $sqlHWInfo | where{$_.location -ne 'empty' -or $_.location -ne $null -or $_.location.GetType().name -ne "DBNull"}
$sqlHWInfod = $sqlHWInfod | where {$_.location.length -gt 1}
#$sqlHWInfod = $sqlHWInfod | where {($_.newcomputername -notlike "*-*K-*") -and ($_.newcomputername -notlike "*-*P-*")}
$i = 1

foreach($item in $sqlHWInfod){
    Import-Module ActiveDirectory
    $cname = $item.newcomputername
    if(!((Get-ADComputer "$cname" -Properties location).location)){
        Set-ADComputer "$cname" -Location "$($item.location)"
    }
    if((Get-ADComputer "$cname" -Properties location).location -eq "$($item.location)"){
        Write-Host "$($item.newcomputername)`t$($item.location)" -ForegroundColor Green
    }
    else{
        Write-Host "$($item.newcomputername)`t$($item.location)" -ForegroundColor Yellow
    }

    Write-Progress -Activity "Adding Computer Locations" -Status "Progress:" -PercentComplete ($i/$sqlHWInfod.Count*100)
    $i++
}
