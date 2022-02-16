# The purpose of this script is to rename domain joined devices

$interface = Get-NetIPAddress | ?{$_.InterfaceAlias -like '*Ethernet*' -and $_.IPAddress -like '159.*'}

if($interface -ne $null){

    # FNG 06/17/2019
    $oldcname = $env:COMPUTERNAME
    Start-Transcript -Path C:\Config_"$oldcname"_Transcript

    $wDir = $PSScriptRoot
    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    $usr = "central\$($tsenv.value("TSAD"))"
    $pass = ConvertTo-SecureString $tsenv.value("TSADP") -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ($usr, $pass)
    $usr2 = "central\$($tsenv.value("TSCMSIA"))"
    $pass2 = ConvertTo-SecureString $tsenv.value("TSCMSIAP") -AsPlainText -Force

    Function SQL_CONNECT ($Query){
        #$ConnectionString = "server=SDITDDB;database=RBDDB;Persist Security Info=True;User ID=$usr2;Password=$pass2;" 
        $ConnectionString = "server=SDITDDB;database=RBDDB;Persist Security Info=True;User ID=$($tsenv.Value('TSSQLAC'));Password=$($tsenv.Value('TSSQLAP'));"   
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

    $cname = $env:COMPUTERNAME
    $dep = $null
    $deps = @(@("BOS"	,"BOS"),
    @("CA"	,"CAO"),
    @("CD"	,"CDN"),
    @("CED"	,"CED,CND"),
    @("CL"	,"COB"),
    @("CM"	,"COM"),
    @("CO"	,"CON"),
    @("CS"	,"CST"),
    @("DE"	,"DEQ"),
    @("DSD"	,"DSD"),
    @("ED"	,"EDT"),
    @("EL"	,"ELC"),
    @("FC"	,"FCD"),
    @("FM"	,"FMT"),
    @("FN"	,"FIN"),
    @("FS"	,"FLT"),
    @("FSC"	,"FSC"),
    @("GGS"	,"GGS"),
    @("GMI"	,"GMI"),
    @("HD"	,"HLT"),
    @("HR"	,"HRS"),
   #@("ID"	,"PDS"),
    @("IT"	,"ITD"),
    @("JCT"	,"JCT"),
    @("KSC"	,"KSC"),
   #@("LD"	,"PDS"),
    @("LIB"	,"LIB"),
    @("OEM"	,"OEM"),
    @("OMS"	,"BHV"),
    @("PAC"	,"PAC"),
   #@("PDS"	,"PDS"),
    @("PDS"	,"PDS,CAC,OCC"),
    @("PO"	,"PRO"),
    @("PR"	,"NRP"),
    @("PW"	,"PWD,RPL,CIP,PMO,PWA"),
    @("RP"	,"RLP"),
    @("SD"	,"SHF"),
    @("SS"	,"SOS"),
    @("SUS"	,"OSC"),
    @("TR"	,"DOT"),
    @("WIN"	,"PCW"),
    @("WW"	,"RWR"))
    
    foreach($d in $deps){
        if($d[1] -match "$($cname.Split('-')[0])"){$dep = $d[0]}
    }
    if($dep -eq $null){$dep = $cname.Split('-')[0]}
    $type = $cname.Split('-')[2].substring(0,1)
    #if($cname.Split('-')[2].substring(1,1) -match '^[a-zA-Z]'){$use = $($cname.Split('-')[2].substring(1,1))}else{"N"}
    $use = if($cname.Split('-')[2].substring(1,1) -match '^[a-zA-Z]'){$cname.Split('-')[2].substring(1,1)}else{"N"}
    $manu = (Get-WmiObject Win32_ComputerSystem).Manufacturer
    $serial = (Get-WmiObject win32_BIOS).SerialNumber
    if($manu -like "Microsoft*" -or $manu -like "Dell*"){
        $namEnd = $SERIAL.trim().substring(0,6)
    }
    else{$namEnd = $SERIAL.trim().substring($SERIAL.length - 6,6)}
    
    $newname = "$dep-$type$use-$namEnd"
    $tsenv.value("cLocation") = $cname.split("-")[1]
    
    # FNG 6/17/2019
    New-Item C:\Config_"$oldcname"_"$newname" -Force
    
    try{
        Rename-Computer -NewName $newname -DomainCredential $cred -ErrorAction Stop
        $sqlID = SQL_CONNECT "Select * from RolloutDeviceID where oldcomputername = '$cname'"
        if($sqlID -eq $null){$sqlID = SQL_CONNECT "Select * from RolloutDeviceID where oldcomputername = '$newname'"}
        if($sqlID -eq $null){
            SQL_CONNECT "Insert into RolloutDeviceID (Department, OldComputerName, NewComputerName, DeploymentYear) values ('$dep','$cname','$newname','Rename')"
            $sqlID = SQL_CONNECT "Select * from RolloutDeviceID where newcomputername = '$newname'"
        }
        else{
            SQL_CONNECT "Update RolloutDeviceID set oldcomputername = '$cname', newcomputername ='$newname' where IDKey = '$($sqlID.IDKey)'"
        }
    }
    catch{
        
    }
    # FNG 6/17/2019
    Stop-Transcript
    Rename-Item -Path C:\Config_"$oldcname"_Transcript -NewName C:\Config_"$oldcname"_"$newname"_Transcript_(Get-Date).ToString() -Force
}
Else
{
    $Datetime = (Get-Date).ToString()
    New-Item -ItemType File -Name C:\Failed_To_Rename.txt
    Echo "$Datetime Device renaming skipped due to it being connected to Wi-Fi" > C:\Failed_To_Rename.txt
}