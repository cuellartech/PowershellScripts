$ScrName = ($MyInvocation.MyCommand.Name).Substring(0,($MyInvocation.MyCommand.Name).Length - 4)
$logfile = "$PSScriptRoot\$ScrName-LOG_$(get-date -format "yyyyMMdd_hhmmsstt").log"
$ErrorActionPreference="SilentlyContinue"
#Stop-Transcript | out-null
#$ErrorActionPreference = "Continue"
Start-Transcript -path $logfile -append

Add-Type -AssemblyName PresentationFramework
$PS_ScheduledTaskClass = Get-CimClass -Namespace root/Microsoft/Windows/TaskScheduler -ClassName PS_ScheduledTask
if(!($PS_ScheduledTaskClass.CimClassMethods.Name -contains "NewTriggerByOnce"))
{
   mofcomp C:\Windows\System32\wbem\SchedProv.mof
}

$aScript = {if((Get-WmiObject -Namespace root\ccm\policy\machine\actualconfig -ClassName CCM_SoftwareDistribution -Filter 'PKG_Name = "Win10 v20H2 Enterprise Upgrade"')){(Get-WmiObject -Namespace root\ccm\policy\machine\actualconfig -ClassName CCM_SoftwareDistribution -Filter 'PKG_Name = "Win10 v20H2 Enterprise Upgrade"').ADV_AdvertisementID | ForEach-Object{'Select * from CCM_Scheduler_ScheduledMessage where ScheduledMessageID like "' + $_ + '%"'} | ForEach-Object{Get-WmiObject -Query "$_" -Namespace root\ccm\policy\machine\actualconfig}|ForEach-Object{([wmiclass] "\\.\root\ccm:SMS_Client").TriggerSchedule($_.ScheduledMessageID)}}}

$aScript2=@"
if((Get-WmiObject -Namespace root\ccm\policy\machine\actualconfig -ClassName CCM_SoftwareDistribution -Filter \"PKG_Name = `'Win10 v20H2 Enterprise Upgrade`'\")){"(Get-WmiObject -Namespace root\ccm\policy\machine\actualconfig -ClassName CCM_SoftwareDistribution -Filter \"PKG_Name = `'Win10 v20H2 Enterprise Upgrade`'\").ADV_AdvertisementID | foreach{\"Select * from CCM_Scheduler_ScheduledMessage where ScheduledMessageID like `'`$_%`'\"}| foreach{Get-WmiObject -Query "`$_" -Namespace root\ccm\policy\machine\actualconfig} | foreach{([wmiclass] \"\\.\root\ccm:SMS_Client\").TriggerSchedule(`$_.ScheduledMessageID)}}
"@

#Check if task sequence is deployed to computer, show error and exit if not found
if(-not(Get-WmiObject -Namespace root\ccm\policy\machine\actualconfig -ClassName CCM_SoftwareDistribution -Filter 'PKG_Name = "Win10 v20H2 Enterprise Upgrade"')) {
    $ButtonType = [System.Windows.MessageBoxButton]::OK
    $MessageIcon = [System.Windows.MessageBoxImage]::Warning
    $MessageBody = "Windows 10 upgrade task sequence not found."
    $MessageTitle = "Deployment Not Found"
    $Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
    Write-Output $Result 
    exit 1
}

#Check what version is running, show error if 20H2 and exit
if([System.Environment]::OSVersion.Version.Build -ge 19042) {
    $ButtonType = [System.Windows.MessageBoxButton]::OK
    $MessageIcon = [System.Windows.MessageBoxImage]::Warning
    $MessageBody = "Windows 10 version is already 20H2 or greater."
    $MessageTitle = "Already Upgraded"
    $Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
    Write-Output $Result 
    exit 1
}

#Build the GUI
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
		xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
		xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
		xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
		xmlns:local="clr-namespace:WpfApp5"
		Title="Windows 10 Upgrade" Height="387" Width="525" ResizeMode="NoResize">
	<Grid>
		<DatePicker x:Name="dtSchedule" HorizontalAlignment="Left" Margin="30,189,0,0" VerticalAlignment="Top" RenderTransformOrigin="0,1" SelectedDateFormat="Short">
			<DatePicker.RenderTransform>
				<TransformGroup>
					<ScaleTransform/>
					<SkewTransform/>
					<RotateTransform/>
					<TranslateTransform/>
				</TransformGroup>
			</DatePicker.RenderTransform>
			<DatePicker.BlackoutDates>
    			<CalendarDateRange Start="2021-05-15" End="2021-05-16" />
    			<CalendarDateRange Start="2021-05-22" End="2021-05-23" />
    		</DatePicker.BlackoutDates>
		</DatePicker>
		<Label x:Name="label" Content="This Computer is scheduled for an Upgrade. If you would like to run &#xD;&#xA;the upgrade task now click on the Run Now button. If you would like &#xD;&#xA;to schedule a date select a date and click the schedule button." Margin="0,77,25,0" VerticalAlignment="Top" HorizontalAlignment="Right" Width="467" Height="67" FontSize="14"/>
		<Label x:Name="lblDate" Content="Schedule Date" HorizontalAlignment="Left" Margin="15,155,0,0" VerticalAlignment="Top" Foreground="Black" FontStretch="SemiCondensed" Height="33" FontSize="16"/>
		<Rectangle Fill="#FF1BA1E2" HorizontalAlignment="Left" Height="75" Stroke="#FF1BA1E2" VerticalAlignment="Top" Width="517"/>
		<Label x:Name="lblMain" Content="Windows 10 Upgrade" Margin="15,19,10,0" VerticalAlignment="Top" Foreground="White" Height="47" FontSize="22" FontWeight="Light"/>
		<ComboBox x:Name="cmbTime" HorizontalAlignment="Left" Margin="152,190,0,0" VerticalAlignment="Top" Width="87" >
		</ComboBox>
		<Button x:Name="btnRunNow" IsEnabled="False" Content="Run Now" Margin="398,289,24,22" FontWeight="Bold" FontSize="14" Background="#FF1BA1E2" Foreground="White" BorderBrush="#FF71C5ED" RenderTransformOrigin="1,1" IsDefault="True"/>
		<Button x:Name="btnSchedule" IsEnabled="False" Content="Schedule" Margin="283,289,139,22" FontWeight="Bold" FontSize="14" Foreground="White" BorderBrush="#FF71C5ED" RenderTransformOrigin="1,1" Background="#FF1BA1E2" />
		<CheckBox x:Name="Check_Agree" Content=" I acknowledge that there can be no USB drive attached to the computer during&#xD;&#xA; the time of the upgrade." HorizontalAlignment="Left" Margin="30,245,0,0" VerticalAlignment="Top" Height="36" Width="479"/>
		<CheckBox x:Name="Check_Remind" Content="Schedule a reminder in Outlook." HorizontalAlignment="Left" Margin="30,300,0,0" VerticalAlignment="Top"/>
		<Label x:Name="Label_Required" Content="*" HorizontalAlignment="Left" Margin="12,235,0,0" VerticalAlignment="Top" FontSize="24" Height="36" Foreground="#FFCF1717"/>

	</Grid>
</Window>

"@


$reader=(New-Object System.Xml.XmlNodeReader  $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )
$Window.Left = 500
$Window.Top = 200
$window.Topmost = $true
#Connect to Controls 

$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object {
	New-Variable  -Name $_.Name -Value $Window.FindName($_.Name) -Force
} 

$btnSchedule.Add_Click({
	$window.Topmost = $false
	$TimeScheduled = $dtSchedule.SelectedDate -replace "12:00:00 AM","$($cmbTime.selecteditem)"
	Unregister-ScheduledTask -TaskName "Win10 v20H2 Upgrade Task" -Confirm:$false -ErrorAction SilentlyContinue
	Unregister-ScheduledTask -TaskName "Outlook Reminder - Windows Upgrade SCCM" -Confirm:$false -ErrorAction SilentlyContinue
	if(($TimeScheduled -ne "") -and ($TimeScheduled -ne $Null)){
#Schedule the Upgrade Task		
			$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument $aScript2
			$trigger =  New-ScheduledTaskTrigger -At $TimeScheduled -Once 
			$stSetting = New-ScheduledTaskSettingsSet -WakeToRun
			Register-ScheduledTask -Action $action -Trigger $trigger -Settings $stSetting -TaskName "Win10 v20H2 Upgrade Task" -Description "Windows 10 Upgrade Task" -User "System" -RunLevel Highest
			Get-ScheduledTask -TaskName "Win10 v20H2 Upgrade Task"  | Where-Object {$_.settings.waketorun}
#Schedule the reminder if checked
			if($Check_Remind.IsChecked -eq "True"){
				$user = Get-WmiObject -Class win32_computersystem | ForEach-Object Username
$comm = @"
`$a = ('`$ol = New-Object -ComObject Outlook.Application ;`$mapi = `$ol.GetNamespace(\"MAPI\") ;`$olInbox = `$mapi.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderInbox) ;`$calendar = `$olInbox ;`$appt = `$calendar.Items.Add(1) # == olAppointmentItem ;`$appt.Start = [datetime]\"$($dtSchedule.SelectedDate)\" ;`$appt.AllDayEvent = \"True\" ;`$appt.Subject = \"Windows Upgrade Reminder\" ;`$appt.Location = \"PC\" ;`$appt.Body = \"This is a reminder that your device will be Upgraded today $TimeScheduled.\" ;`$appt.Save()').Split(\";\") ; foreach (`$e in `$a){Invoke-Expression \"`$e\"}
"@
				$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument $comm
				$time2 = (Get-Date).AddMinutes(1).ToShortTimeString()
				$trigger =  New-ScheduledTaskTrigger -At $time2 -Once 
				Register-ScheduledTask -Action $action -Trigger $trigger -Settings $stSetting -TaskName "Outlook Reminder - Windows Upgrade SCCM" -Description "Reminder " -User "$user"
			}
		
		
		[xml]$xaml2 = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
		xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
		xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
		xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
		xmlns:local="clr-namespace:WpfApp5"
		Title="Windows 10 Upgrade Scheduled" Height="149.333" Width="450.333" ResizeMode="NoResize">
	<StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
		<TextBlock x:Name="MainTbox" Text="The upgrade has been scheduled for $TimeScheduled" Height="17" Margin="20,10,20,20" FontSize="14" />
		<Button x:Name="btnOK" Content="OK" FontWeight="Bold" FontSize="14" Background="#FF1BA1E2" Foreground="White" BorderBrush="#FF71C5ED" RenderTransformOrigin="1,1" Width="75" IsDefault="True"/>
	</StackPanel>
</Window>
"@
		$reader2=(New-Object System.Xml.XmlNodeReader  $xaml2)
		$Window2=[Windows.Markup.XamlReader]::Load( $reader2 )
		$window2.Topmost = $True
		$Window2.Left = $Window.Left
		$Window2.Top = $Window.top
		$xaml2.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object {
			New-Variable  -Name $_.Name -Value $Window2.FindName($_.Name) -Force
		} 
		
		$btnOK.Add_Click({
            Stop-Transcript
			[Environment]::Exit(0)
		})
		if(Test-Path "C:\Users\Public\Desktop\Win10 Upgrade Helper.lnk"){
			Remove-Item "C:\Users\Public\Desktop\Win10 Upgrade Helper.lnk"
		}
		$WshShell = New-Object -comObject WScript.Shell
		$Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\Win10 Upgrade Helper.lnk")

		$Shortcut.TargetPath = "softwarecenter:SoftwareID=ScopeId_D438095C-58CC-44C9-88FC-49C1A39E02FF/Application_b91c1595-2244-41a6-a619-c1b21428dd2c"
		$Shortcut.IconLocation = "C:\Windows\CCM\SCClient.exe"
		$Shortcut.Save()
        
        if(!(Get-ScheduledTask -TaskName "Win10 v20H2 Upgrade Task" -ErrorAction SilentlyContinue)){
            $btnOK.Add_Click({
                Stop-Transcript
		    	[Environment]::Exit(1)
		    })
            $MainTbox.Text = "Upgrade Failed to Schedule. Please contact the NOC at 724-8471."
        }
    
		###Clean up the task here
		
		$Null = $Window2.ShowDialog()	
	}
	

})

$Check_Agree.Add_Click({
	$TimeScheduled = $dtSchedule.SelectedDate -replace "12:00:00 AM","$($cmbTime.selecteditem)"
	if ((get-date $TimeScheduled) -gt (Get-Date)){
		$datecheck = $true
	}
	$btnRunNow.IsEnabled = $Check_Agree.IsChecked
	if($datecheck -eq $true){
		$btnSchedule.IsEnabled = $Check_Agree.IsChecked
	}
	else{
		$btnSchedule.IsEnabled = $false
	}
})

$dtSchedule.Add_SelectedDateChanged({
	$TimeScheduled = $dtSchedule.SelectedDate -replace "12:00:00 AM","$($cmbTime.selecteditem)"
	if ((get-date $TimeScheduled) -gt (Get-Date)){
		$datecheck = $true
		if($Check_Agree.IsChecked -eq $true){
			$btnSchedule.IsEnabled = $Check_Agree.IsChecked
		}
	}
	else{
		$datecheck = $false
		$btnSchedule.IsEnabled = $false
	}
})
$cmbTime.Add_SelectionChanged({
	$TimeScheduled = $dtSchedule.SelectedDate -replace "12:00:00 AM","$($cmbTime.selecteditem)"
	if ((get-date $TimeScheduled) -gt (Get-Date)){
		$datecheck = $true
		if($Check_Agree.IsChecked -eq $true){
			$btnSchedule.IsEnabled = $Check_Agree.IsChecked
		}
	}
	else{
		$datecheck = $false
		$btnSchedule.IsEnabled = $false
	}
})


$btnRunNow.Add_Click({
	$window.Topmost = $false
	Unregister-ScheduledTask -TaskName "Win10 v20H2 Upgrade Task" -Confirm:$false -ErrorAction SilentlyContinue
[xml]$xaml2 = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
		xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
		xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
		xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
		xmlns:local="clr-namespace:WpfApp5"
		Title="Windows 10 Upgrade Scheduled" Height="149.333" Width="450.333" ResizeMode="NoResize">
	<StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
		<TextBlock Text="The upgrade will begin now." Height="17" Margin="20,10,20,20" FontSize="14" />
		<Button x:Name="btnOK" Content="OK" FontWeight="Bold" FontSize="14" Background="#FF1BA1E2" Foreground="White" BorderBrush="#FF71C5ED" RenderTransformOrigin="1,1" Width="75" IsDefault="True"/>
	</StackPanel>
</Window>
"@
		$reader2=(New-Object System.Xml.XmlNodeReader  $xaml2)
		$Window2=[Windows.Markup.XamlReader]::Load( $reader2 )
		$window2.Topmost = $True
		$Window2.Left = $Window.Left+40
		$Window2.Top = $Window.top+80
		$xaml2.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object {
			New-Variable  -Name $_.Name -Value $Window2.FindName($_.Name) -Force
		} 
			$btnOK.Add_Click({
			invoke-Command $aScript
            Stop-Transcript
			[Environment]::Exit(0)
		})
	$Null = $Window2.ShowDialog()	

})

$timeChoices = @(7..11) | ForEach-Object{"$($_):00","$($_):15","$($_):30","$($_):45"} | ForEach-Object{"$($_) AM"}
$timeChoices += @(12) | ForEach-Object{"$($_):00","$($_):15","$($_):30","$($_):45"} | ForEach-Object{"$($_) PM"}
$timeChoices += @(1..8) | ForEach-Object{"$($_):00","$($_):15","$($_):30","$($_):45"} | ForEach-Object{"$($_) PM"}
$timeChoices += @(9) | ForEach-Object{"$($_):00"} | ForEach-Object{"$($_) PM"}

$timechoices|ForEach-Object{$cmbTime.AddChild($_)}

$dtSchedule.DisplayDateStart = Get-Date
$dtSchedule.DisplayDateEnd = "5/28/2021 21:00:00"

$Null = $Window.ShowDialog()
Stop-Transcript