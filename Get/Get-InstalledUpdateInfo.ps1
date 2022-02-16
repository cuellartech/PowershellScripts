function GetUpdate($kbNum){
$Report = @()
   $objSession = [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$_))
   $objSearcher= $objSession.CreateUpdateSearcher()
   $HistoryCount = $objSearcher.GetTotalHistoryCount()
   $colSucessHistory = $objSearcher.QueryHistory(0, $HistoryCount)
   Foreach($objEntry in $colSucessHistory | where {$_.ResultCode -eq '2'}) {
       $pso = "" | select Computer,Title,Date
       $pso.Title = $objEntry.Title
       $pso.Date = $objEntry.Date
       $pso.computer = $_
       $Report += $pso
       }
   $objSession = $null

$Report | where { $_.Title -notlike 'Definition Update*'} | where{$_.title -like "*$kbNum*"}
}
$kbNum = Read-Host "Enter the KB Number"
GetUpdate $kbNum