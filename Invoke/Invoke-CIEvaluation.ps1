$Name='Hibernation Off'
([wmiclass]"root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation(((Get-WmiObject -Namespace root\ccm\dcm -class SMS_DesiredConfiguration | Where-Object {$_.DisplayName -eq $Name}).Name), ((Get-WmiObject -Namespace root\ccm\dcm -class SMS_DesiredConfiguration | Where-Object {$_.DisplayName -eq $Name}).Version))