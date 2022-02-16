#$computernames = 'LIB-LN-HWPW5Y'
$computernames = 'IT-VT-1019-9'
$events = @()
$output = $null
$output = @()

$SMBXPath = @'
<QueryList>
  <Query Id="0" Path="Application">
    <Select Path="Application">*[System[Provider[@Name='Avecto Defendpoint Service'] ]]</Select>
  </Query>
</QueryList>
'@

ForEach ($computername in $computernames) {
Write-Host "Getting Events from $computername"
$events += get-winevent -ComputerName $computername -Filterxml $SMBXPath
Write-Host "Processing $($Events.count) Events"
		$events.foreach({
							
				$xEvt = [xml]$_.ToXml()
				
				    $myobject = New-Object System.Object  #Create a new Object, and load data
                    $myObject | Add-Member -type NoteProperty -name CommandLine -Value $xEvt.Event.EventData.Data[0]
                    $myObject | Add-Member -type NoteProperty -name ProcessID -Value $xEvt.Event.EventData.Data[1]
                    $myObject | Add-Member -type NoteProperty -name ParentProcessID -Value $xEvt.Event.EventData.Data[2]
                    $myObject | Add-Member -type NoteProperty -name Workstyle -Value $xEvt.Event.EventData.Data[3]
                    $myObject | Add-Member -type NoteProperty -name ApplicationGroup -Value $xEvt.Event.EventData.Data[4]
                    $myObject | Add-Member -type NoteProperty -name Reason -Value $xEvt.Event.EventData.Data[5]
                    $myObject | Add-Member -type NoteProperty -name Unknown -Value $xEvt.Event.EventData.Data[6]
                    $myObject | Add-Member -type NoteProperty -name FileName -Value $xEvt.Event.EventData.Data[7]
                    $myObject | Add-Member -type NoteProperty -name Hash -Value $xEvt.Event.EventData.Data[8]
                    $myObject | Add-Member -type NoteProperty -name Certificate -Value $xEvt.Event.EventData.Data[9]
                    $myObject | Add-Member -type NoteProperty -name Description -Value $xEvt.Event.EventData.Data[10]
                    $myObject | Add-Member -type NoteProperty -name ApplicationType -Value $xEvt.Event.EventData.Data[11]
                    $myObject | Add-Member -type NoteProperty -name ProductName -Value $xEvt.Event.EventData.Data[12]
                    $myObject | Add-Member -type NoteProperty -name ProductCode -Value $xEvt.Event.EventData.Data[13]
                    $myObject | Add-Member -type NoteProperty -name UpgradeCode -Value $xEvt.Event.EventData.Data[14]
                    $myObject | Add-Member -type NoteProperty -name ProductVersion -Value $xEvt.Event.EventData.Data[15]
                    $myObject | Add-Member -type NoteProperty -name FileVersion -Value $xEvt.Event.EventData.Data[16]
                    $myObject | Add-Member -type NoteProperty -name ApplicationGroupDesc -Value $xEvt.Event.EventData.Data[17]
                    $myObject | Add-Member -type NoteProperty -name WorkstyleDesc -Value $xEvt.Event.EventData.Data[18]
                    $myObject | Add-Member -type NoteProperty -name TokenAssignmentID -Value $xEvt.Event.EventData.Data[19]
                    $myObject | Add-Member -type NoteProperty -name TokenAssingIsShell -Value $xEvt.Event.EventData.Data[20]
                    $myObject | Add-Member -type NoteProperty -name TokenID -Value $xEvt.Event.EventData.Data[21]
                    $myObject | Add-Member -type NoteProperty -name MessageID -Value $xEvt.Event.EventData.Data[22]
                    $myObject | Add-Member -type NoteProperty -name Token -Value $xEvt.Event.EventData.Data[23]
                    $myObject | Add-Member -type NoteProperty -name TokenDesc -Value $xEvt.Event.EventData.Data[24]
                    $myObject | Add-Member -type NoteProperty -name MessageName -Value $xEvt.Event.EventData.Data[25]
                    $myObject | Add-Member -type NoteProperty -name MessageDesc -Value $xEvt.Event.EventData.Data[26]
                    $myObject | Add-Member -type NoteProperty -name UniqueProcID -Value $xEvt.Event.EventData.Data[27]
                    $myObject | Add-Member -type NoteProperty -name WorkstyleID -Value $xEvt.Event.EventData.Data[28]
                    $myObject | Add-Member -type NoteProperty -name ApplicationGroupID -Value $xEvt.Event.EventData.Data[29]
                    $myObject | Add-Member -type NoteProperty -name UserSID -Value $xEvt.Event.EventData.Data[30]
                    $myObject | Add-Member -type NoteProperty -name UserName -Value $xEvt.Event.EventData.Data[31]
                    $myObject | Add-Member -type NoteProperty -name UserDomainSID -Value $xEvt.Event.EventData.Data[32]
                    $myObject | Add-Member -type NoteProperty -name UserDomainName -Value $xEvt.Event.EventData.Data[33]
                    $myObject | Add-Member -type NoteProperty -name UserDomainNameNETBIOS -Value $xEvt.Event.EventData.Data[34]
                    $myObject | Add-Member -type NoteProperty -name HostSID -Value $xEvt.Event.EventData.Data[35]
                    $myObject | Add-Member -type NoteProperty -name HostName -Value $xEvt.Event.EventData.Data[36]
                    $myObject | Add-Member -type NoteProperty -name HostNameNETBIOS -Value $xEvt.Event.EventData.Data[37]
                    $myObject | Add-Member -type NoteProperty -name HostDomainSID -Value $xEvt.Event.EventData.Data[38]
                    $myObject | Add-Member -type NoteProperty -name HostDomainName -Value $xEvt.Event.EventData.Data[39]
                    $myObject | Add-Member -type NoteProperty -name HostDomainNameNETBIOS -Value $xEvt.Event.EventData.Data[40]
                    $myObject | Add-Member -type NoteProperty -name EventID -Value $xEvt.Event.EventData.Data[41]
                    $myObject | Add-Member -type NoteProperty -name ProcessStartTime -Value $xEvt.Event.EventData.Data[42]
                    $myObject | Add-Member -type NoteProperty -name ProcessEndTime -Value $xEvt.Event.EventData.Data[43]
                    $myObject | Add-Member -type NoteProperty -name EventTime -Value $xEvt.Event.EventData.Data[44]
                    $myObject | Add-Member -type NoteProperty -name AuthorizingUserSID -Value $xEvt.Event.EventData.Data[45]
                    $myObject | Add-Member -type NoteProperty -name AuthorizingUserName -Value $xEvt.Event.EventData.Data[46]
                    $myObject | Add-Member -type NoteProperty -name UACTriggered -Value $xEvt.Event.EventData.Data[52]
                    $myObject | Add-Member -type NoteProperty -name FileOwnerName -Value $xEvt.Event.EventData.Data[54]
                    $myObject | Add-Member -type NoteProperty -name ParentProcessName -Value $xEvt.Event.EventData.Data[59]
                    $output += $myobject
                    $myObject = $null

                    
				
			}) 
}

#$eventdata = [xml]$events[0].ToXML()
$output|out-gridview