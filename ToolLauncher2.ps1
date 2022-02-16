$credcount = 0
#Authentication Function
function GetCred{
	if($null -eq $cred.Username){
		$global:cred = Get-Credential "CENTRAL\a149841"
	}
	if($cred.username -notmatch "\\"){
		Write-Host "Please verify that your username matches 'DOMAIN\UserName'."
		$global:cred = Get-Credential "CENTRAL\$($cred.username)"
	}
	$global:uname = $cred.Username
	$global:pw = $cred.GetNetworkCredential().password

	# Get current domain using logged-on user's credentials
	$CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
	$domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UName,$Pw)

	if (($null -eq $domain.Name)){
		write-host "Authentication failed - please verify your username and password."
		if($cred.username -notmatch "\\"){
			$global:cred = Get-Credential "CENTRAL\$($cred.username)"
		}
		Else{
			$global:cred = Get-Credential "$($cred.username)"
		}
	}
	else{
		$global:cred
	}
}
function hideConsole{
	#Hide Condole after stating form
	Add-Type -Name Window -Namespace Console -MemberDefinition '
	[DllImport("Kernel32.dll")]
	public static extern IntPtr GetConsoleWindow();
	
	[DllImport("user32.dll")]
	public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
	'
	$consolePtr = [Console.Window]::GetConsoleWindow()
	[Console.Window]::ShowWindow($consolePtr, 0)
}
do{
	if($credcount -eq 3){
		$credcount = 0
		Write-Host "You have not been able to authenticate. Please verify your credentials then run the script again."	
		pause
		exit
	}
	$null = GetCred
	$CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
	$domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UName,$Pw)
	$credcount++
}
until($null -ne $domain.name)

$ThemeFile = "\\spsccm\cmsource`$\Packages\Utilities\Themes\ExpressionDark.xaml"

#Build the GUI
if($null -ne $domain.name){
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
	xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
	xmlns:local="clr-namespace:ToolLaunch"
	Title="Admin Tool" 
	SizeToContent="Height,Width"
	ResizeMode="NoResize" 
    HorizontalAlignment="Left" 
    VerticalAlignment="Top"
    Background = "Gray"
	>

    <Window.Resources>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
            <ResourceDictionary Source="$ThemeFile" /> 
        </ResourceDictionary.MergedDictionaries>
        <Style TargetType="{x:Type CheckBox}">
            <Setter Property="Foreground" Value="White"/>
        </Style>
        <Style TargetType="{x:Type RadioButton}">
            <Setter Property="Foreground" Value="White"/>
        </Style>
        </ResourceDictionary>
    </Window.Resources>

    <Grid x:Name="Grid">
        <TextBlock x:Name="TBlock" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="15,0,0,0" Text="$($cred.UserName)" TextWrapping="Wrap" FontFamily="Segoe UI" FontSize="10" Foreground="White"/>
        <CheckBox x:Name="LCheck" Content="Labels" HorizontalAlignment="Left" Margin="15,15,5,5" VerticalAlignment="Top" FontSize="10" IsChecked="True"/>
        <GroupBox  x:Name="Actions" Header="Actions"  HorizontalAlignment="Left" VerticalAlignment="Bottom" Width="150" Margin="10,30,10,10" Visibility="Visible">
            <StackPanel>
                <Button  x:Name="B1" Margin="0,5,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\microsoft-system-center-2012-configuration-manager-console.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L01" Margin="5,0,0,0">SCCM Console</Label>
                    </DockPanel>
                </Button>
                <Button  x:Name="B2" Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\SupportCenter.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L02" Margin="5,0,0,0">Support Center</Label>
                    </DockPanel>
                </Button>
                <Button  x:Name="B3" Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\Regedit.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L03" Margin="5,0,0,0">Regedit</Label>
                    </DockPanel>
                </Button>
                <Button  x:Name="B4"  Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\Computer-management.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L04" Margin="5,0,0,0">Computer Mgmt</Label>
                    </DockPanel>
                </Button>
                <Button  x:Name="B5" Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\ADUC.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L05" Margin="5,0,0,0">ADUC</Label>
                    </DockPanel>
                </Button>
                <Button  x:Name="B6" Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\gpmc.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L06" Margin="5,0,0,0">GP Management</Label>
                    </DockPanel>
                </Button>
                <Button  x:Name="B7" Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\cmd.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L07" Margin="5,0,0,0">Command Prompt</Label>
                    </DockPanel>
                </Button>
                <Button  x:Name="B8" Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\Windows-Management-Framework-5.1.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L08" Margin="5,0,0,0">Powershell ISE</Label>
                    </DockPanel>
                </Button>
                <Button  x:Name="B9" Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\Notepad.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L09" Margin="5,0,0,0">Notepad</Label>
                    </DockPanel>
                </Button>
                <Button  x:Name="B10" Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\visual-studio.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L10" Margin="5,0,0,0">Visual Studio</Label>
                    </DockPanel>
                </Button>
                <Button  x:Name="B11" Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\SSMS.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L11" Margin="5,0,0,0">SQL Server MS</Label>
                    </DockPanel>
                </Button>
				<Button  x:Name="B12" Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\Azure_Data_Studio.ico" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L12" Margin="5,0,0,0">Azure Data Studio</Label>
                    </DockPanel>
                </Button>
                <Button  x:Name="B13" Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\SQLReportBuilder.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L13" Margin="5,0,0,0">SQL Report Builder</Label>
                    </DockPanel>
                </Button>
                <Button  x:Name="B14"  Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\vs_code.ico" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L14" Margin="5,0,0,0">VS Code</Label>
                    </DockPanel>
                </Button>
                <Button  x:Name="B15"  Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\256-ExchangeServer-a.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L15" Margin="5,0,0,0">Exchange</Label>
                    </DockPanel>
                </Button>
                <Button  x:Name="B16"  Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\Q-DIR_logo.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L16" Margin="5,0,0,0">Q-Dir</Label>
                    </DockPanel>
                </Button>
                <Button  x:Name="B17"  Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\LAPSUI.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L17" Margin="5,0,0,0">LAPS UI</Label>
                    </DockPanel>
                </Button>
                <Button  x:Name="B18"  Margin="0,0,0,10">
                    <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\mmc.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L18" Margin="5,0,0,0">MMC.EXE</Label>
                    </DockPanel>
                    </Button>
                    <Button  x:Name="B19"  Margin="0,0,0,10">
                       <DockPanel Width="130">
                        <Image Source="\\spsccm\cmsource$\Packages\Utilities\Icons\cmr.png" Height="25" VerticalAlignment="Center"/>
                        <Label x:Name="L19" Margin="5,0,0,0">CMRemoteControl</Label>
                    </DockPanel>
                </Button>
            </StackPanel>
        </GroupBox>
    </Grid>
</Window>
"@
Add-Type -AssemblyName PresentationFramework
$reader=(New-Object System.Xml.XmlNodeReader  $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )
$window.Topmost = $true

#window location
if(($null -eq (Get-ItemPropertyValue HKCU:\SOFTWARE\utilities\Launcher -Name Locationx -ErrorAction SilentlyContinue)) -or ($null -eq (Get-ItemPropertyValue HKCU:\SOFTWARE\utilities\Launcher -Name Locationy -ErrorAction SilentlyContinue))){
	if(!(test-path HKCU:\SOFTWARE\utilities\Launcher)){
		New-Item HKCU:\SOFTWARE\utilities\Launcher -Force
	}
	New-ItemProperty HKCU:\SOFTWARE\utilities\Launcher -Name Locationx -Value 30 -PropertyType String -Force
	New-ItemProperty HKCU:\SOFTWARE\utilities\Launcher -Name Locationx -Value 30 -PropertyType String -Force
}
$Formx = (Get-ItemPropertyValue HKCU:\SOFTWARE\utilities\Launcher -Name Locationx)
$Formy = (Get-ItemPropertyValue HKCU:\SOFTWARE\utilities\Launcher -Name Locationy)

$Window.Left = "$Formx"
$Window.Top = "$Formy"

#Connect to Controls 

$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object {
	New-Variable  -Name $_.Name -Value $Window.FindName($_.Name) -Force
} 
if(!(Test-Path 'C:\Program Files (x86)\ConfigMgrConsole\bin\Microsoft.ConfigurationManagement.exe')){
	$B1.visibility = "Collapsed"
}
$B1.Add_Click({
	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process 'C:\Program Files (x86)\ConfigMgrConsole\bin\Microsoft.ConfigurationManagement.exe' -Verb runAs") -NoNewWindow -PassThru  
})
if(!(Test-Path 'C:\Program Files (x86)\Configuration Manager Support Center\ConfigMgrSupportCenter.exe')){
	$B2.visibility = "Collapsed"
}
$B2.Add_Click({
	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process 'C:\Program Files (x86)\Configuration Manager Support Center\ConfigMgrSupportCenter.exe' -Verb runAs") -NoNewWindow -PassThru
})

$B3.Add_Click({
	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process Regedit.exe -Verb runAs") -NoNewWindow -PassThru 
})

$B4.Add_Click({
	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process compmgmt.msc -Verb runAs") -NoNewWindow -PassThru  
})
if(!(Test-Path 'C:\WINDOWS\system32\dsa.msc')){
    if(!(Test-Path 'C:\WINDOWS\sysnative\dsa.msc')){
	    $B5.visibility = "Collapsed"
    }
}
$B5.Add_Click({
	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process dsa.msc -Verb runAs") -NoNewWindow -PassThru 
})
if(!(Test-Path 'C:\WINDOWS\system32\gpmc.msc')){
	$B6.visibility = "Collapsed"
}
$B6.Add_Click({
	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process gpmc.msc -Verb runAs") -NoNewWindow -PassThru 
})

$B7.Add_Click({
	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process Cmd.exe -Verb runAs") -NoNewWindow -PassThru 
})

$B8.Add_Click({
	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process Powershell.exe -ArgumentList 'ISE' -Verb runAs") -NoNewWindow -PassThru  
})

$B9.Add_Click({
	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process Notepad.exe -Verb runAs") -NoNewWindow -PassThru  
})
if(!(Test-Path 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\devenv.exe')){
	$B10.visibility = "Collapsed"
}
$B10.Add_Click({
	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\devenv.exe' -Verb runAs") -NoNewWindow -PassThru  
})
if(!(Test-Path 'C:\Program Files (x86)\Microsoft SQL Server\140\Tools\Binn\ManagementStudio\Ssms.exe')){
	$B11.visibility = "Collapsed"
    if(!(Test-Path 'C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Ssms.exe')){
    }
    else{
        $B11.visibility = "Visible"
        $B11.Add_Click({                                                                        
        	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process 'C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Ssms.exe' -Verb runAs") -NoNewWindow -PassThru  
        })
    }
}
else{
    $B11.Add_Click({                                                                        
    	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process 'C:\Program Files (x86)\Microsoft SQL Server\140\Tools\Binn\ManagementStudio\Ssms.exe' -Verb runAs") -NoNewWindow -PassThru  
    })
}

if(!(Test-Path 'C:\Program Files\Azure Data Studio\azuredatastudio.exe')){
	$B12.visibility = "Collapsed"
}
$B12.Add_Click({
	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process 'C:\Program Files\Azure Data Studio\azuredatastudio.exe' -Verb runAs") -NoNewWindow -PassThru  
})

$rbuilderpath = Invoke-Command -ComputerName $env:COMPUTERNAME -ScriptBlock {(get-childitem "$env:USERPROFILE\AppData\Local\Apps\2.0\" -Recurse| Where-Object{$_.Name -eq "MSReportBuilder.exe"} | -Where-Object{(Get-childitem $_.Directory.FullName).count -eq (((get-childitem "$env:USERPROFILE\AppData\Local\Apps\2.0\" -Recurse| -Where-Object{$_.Name -eq "MSReportBuilder.exe"}).Directory.FullName | ForEach-Object {(Get-ChildItem $_).count} | Measure-Object -Maximum).Maximum)}).FullName} -Credential $cred -ErrorAction SilentlyContinue
if(!($rbuilderpath)){
	$B13.visibility = "Collapsed"
}
$B13.Add_Click({
	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process '$rbuilderpath' -Verb runAs") -NoNewWindow -PassThru  
})
if(!(Test-Path '\\spsccm\cmsource$\Packages\Utilities\TSStatus\CMDeploymentStatus.exe')){
	$B14.visibility = "Collapsed"
}
$B14.Add_Click({
	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process 'C:\Program Files\Microsoft VS Code\Code.exe' -Verb runAs") -NoNewWindow -PassThru 
})
if(!(Test-Path 'C:\Program Files\Microsoft\Exchange Server\V14\Bin\Exchange Management Console.msc')){
	$B15.visibility = "Collapsed"
}
$B15.Add_Click({
	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process Powershell.exe -ArgumentList 'C:\Program Files\Microsoft\Exchange Server\V14\Bin\Exchange Management Console.msc' -Verb runAs") -NoNewWindow -PassThru 
})
if(!((Test-Path 'C:\Program Files\Q-Dir\Q-Dir.exe') -or (Test-Path 'C:\Program Files (x86)\Q-Dir\Q-Dir.exe'))){
	$B16.visibility = "Collapsed"
}
if(Test-Path 'C:\Program Files\Q-Dir\Q-Dir.exe'){
    $B16.Add_Click({
    	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process 'C:\Program Files\Q-Dir\Q-Dir.exe' -Verb runAs") -NoNewWindow -PassThru 
    })
}
if(Test-Path 'C:\Program Files (x86)\Q-Dir\Q-Dir.exe'){
    $B16.Add_Click({
    	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process 'C:\Program Files (x86)\Q-Dir\Q-Dir.exe' -Verb runAs") -NoNewWindow -PassThru 
    })
}
if(!(Test-Path 'C:\Program Files\LAPS\AdmPwd.UI.exe')){
	$B17.visibility = "Collapsed"
}
$B17.Add_Click({
	Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process 'C:\Program Files\LAPS\AdmPwd.UI.exe' -Verb runAs") -NoNewWindow -PassThru 
})
if(!(Test-Path 'C:\Windows\System32\mmc.exe')){
    $B18.visibility = "Collapsed"
}
$B18.Add_Click({
    Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process 'C:\Windows\System32\mmc.exe' -Verb runAs") -NoNewWindow -PassThru
})
if(!(Test-Path 'C:\Program Files (x86)\ConfigMgrConsole\bin\i386\CmRcViewer.exe')){
    $B19.visibility = "Collapsed"
}
$B19.Add_Click({
    Start-Process powershell.exe -Credential $cred -ArgumentList @("Start-Process 'C:\Program Files (x86)\ConfigMgrConsole\bin\i386\CmRcViewer.exe' -Verb runAs") -NoNewWindow -PassThru
})
$LCheck.Add_Click({
    If($LCheck.IsChecked -eq $true){
       $Window.SizeToContent = "WidthAndHeight"
       $Window.WindowStyle = "SingleBorderWindow"
       $Grid.Width = "NaN"
       $Actions.Width = "150"
       $TBlock.Visibility = "Visible"
       $L01.Visibility = "Visible"
       $B1.Width = "130"
       $L02.Visibility = "Visible"
       $B2.Width = "130"
       $L03.Visibility = "Visible"
       $B3.Width = "130"
       $L04.Visibility = "Visible"
       $B4.Width = "130"       
       $L05.Visibility = "Visible"
       $B5.Width = "130"       
       $L06.Visibility = "Visible"
       $B6.Width = "130"       
       $L07.Visibility = "Visible"
       $B7.Width = "130"       
       $L08.Visibility = "Visible"
       $B8.Width = "130"      
       $L09.Visibility = "Visible"
       $B9.Width = "130"
       $L10.Visibility = "Visible"
       $B10.Width = "130"       
       $L11.Visibility = "Visible"
       $B11.Width = "130"       
       $L12.Visibility = "Visible"
       $B12.Width = "130"       
       $L13.Visibility = "Visible"
       $B13.Width = "130"
       $L14.Visibility = "Visible"
       $B14.Width = "130"
       $L15.Visibility = "Visible"
       $B15.Width = "130"
       $L16.Visibility = "Visible"
       $B16.Width = "130"
       $L17.Visibility = "Visible"
       $B17.Width = "130"
       $L18.Visibility = "Visible"
       $B18.Width = "130"
	   $L19.Visibility = "Visible"
       $B19.Width = "130"
    }
    Else{
       $Actions.Width = "60"
       $Grid.Width = "NaN"       
       $Window.SizeToContent = "Height"
       $Window.WindowStyle = "ToolWindow"
       $Window.width = "95"
       $TBlock.Visibility = "Collapse"
       $L01.Visibility = "Collapse"
       $B1.Width = "23"
       $L02.Visibility = "Collapse"
       $B2.Width = "23"
       $L03.Visibility = "Collapse"
       $B3.Width = "23"
       $L04.Visibility = "Collapse"
       $B4.Width = "23"
       $L05.Visibility = "Collapse"
       $B5.Width = "23"
       $L06.Visibility = "Collapse"
       $B6.Width = "23"
       $L07.Visibility = "Collapse"
       $B7.Width = "23"
       $L08.Visibility = "Collapse"
       $B8.Width = "23"
       $L09.Visibility = "Collapse"
       $B9.Width = "23"
       $L10.Visibility = "Collapse"
       $B10.Width = "23"
       $L11.Visibility = "Collapse"
       $B11.Width = "23"
       $L12.Visibility = "Collapse"
       $B12.Width = "23"
       $L13.Visibility = "Collapse"
       $B13.Width = "23"
       $L14.Visibility = "Collapse"
       $B14.Width = "23"
       $L15.Visibility = "Collapse"
       $B15.Width = "23"
       $L16.Visibility = "Collapse"
       $B16.Width = "23"
       $L17.Visibility = "Collapse"
       $B17.Width = "23"
       $L18.Visibility = "Collapse"
       $B18.Width = "23"
	   $L19.Visibility = "Collapse"
       $B19.Width = "23"
    }

})

	hideConsole
	$Null = $Window.ShowDialog()
	$null = New-ItemProperty HKCU:\SOFTWARE\utilities\Launcher -Name Locationx -Value $($Window.Left) -PropertyType String -Force
	$null = New-ItemProperty HKCU:\SOFTWARE\utilities\Launcher -Name Locationy -Value $($Window.Top) -PropertyType String -Force
}



else{
	Write-Host "You have not been able to authenticate. Please verify your credentials then run the script again."	
	pause
}

