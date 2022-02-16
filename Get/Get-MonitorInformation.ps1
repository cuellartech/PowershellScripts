function Decode {
    If ($args[0] -is [System.Array]) {
        [System.Text.Encoding]::ASCII.GetString($args[0])
    }
    Else {
        "Not Found"
    }
}

Write-Output "Name, Serial"

ForEach ($Monitor in Get-WmiObject WmiMonitorID -Namespace root\wmi) {  
    $Name = Decode $Monitor.UserFriendlyName -notmatch 0
    $Serial = Decode $Monitor.SerialNumberID -notmatch 0
	
    Write-Output "$Name, $Serial"
}