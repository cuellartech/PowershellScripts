[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Windows.Forms.Application]::EnableVisualStyles()#Hide Console Function
function hideConsole{
	#Hide Console after stating form
	Add-Type -Name Window -Namespace Console -MemberDefinition '
	[DllImport("Kernel32.dll")]
	public static extern IntPtr GetConsoleWindow();
	
	[DllImport("user32.dll")]
	public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
	'
	$consolePtr = [Console.Window]::GetConsoleWindow()
	[Console.Window]::ShowWindow($consolePtr, 0)
}
hideConsole
#Build the GUI
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
	xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
	xmlns:local="clr-namespace:CompName"
	Title="Computer Name" Height="250" Width="360" ResizeMode="NoResize" WindowStyle="SingleBorderWindow"
    FocusManager.FocusedElement= "{Binding ElementName= tb_ComputerID}">
    <Grid Margin="0,0,2,0">


        <GroupBox  x:Name="ComputerID_Grp" Header="Build Sheet ID"  HorizontalAlignment="Left" Margin="10,10,0,0"  VerticalAlignment="Top" Height="77" Width="322">
            <TextBox  x:Name="tb_ComputerID" TextWrapping="Wrap" Margin="5,0" FontSize="28" TextAlignment="Justify" VerticalContentAlignment="Center"/>
        </GroupBox>
        <GroupBox  x:Name="AssetNumber_Grp" Header="Asset Number"  HorizontalAlignment="Left" Margin="10,92,0,0"  VerticalAlignment="Top" Height="77" Width="322">
            <TextBox  x:Name="tb_AssetNumber" TextWrapping="Wrap" Margin="5,0" FontSize="28" TextAlignment="Justify" VerticalContentAlignment="Center"/>
        </GroupBox>
        <Button  x:Name="OK_btn" Content="Next" Margin="272,174,0,0" HorizontalContentAlignment="Center" VerticalContentAlignment="Center" VerticalAlignment="Top" Height="25" Width="60"  IsDefault="False" HorizontalAlignment="Left"/>
    </Grid>
</Window>

"@

$global:tsenv
$global:cname
$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
$cname = $tsenv.Value("_SMSTSMachineName")
#$cname = $env:computername

Add-Type -AssemblyName PresentationFramework
$reader=(New-Object System.Xml.XmlNodeReader  $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )
$window.Topmost = $true

#Connect to Controls 
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object {
	New-Variable  -Name $_.Name -Value $Window.FindName($_.Name) -Force
} 

$OK_btn.Add_Click({
    $tsenv.Value("OSDRollOutComputerID") = ([int]$tb_ComputerID.Text).ToString().Trim()
    $tsenv.Value("OSDRollOutComputerAsset") = $tb_AssetNumber.Text
        $tsenv.Value("SMSTSPreferredAdvertID") = "PIM2087B"
        $Window.Close()
})

$tb_ComputerID.Add_KeyDown({
	if($_.Key -eq "Return"){
        $tb_AssetNumber.Focus()
        #[void][System.Windows.Forms.MessageBox]::Show('Enter key enterd '+$_.Key)
    }
})
$tb_AssetNumber.Add_KeyDown({
	if($_.Key -eq "Return"){
        $tsenv.Value("OSDRollOutComputerID") = ([int]$tb_ComputerID.Text).ToString().Trim()
        $tsenv.Value("OSDRollOutComputerAsset") = $tb_AssetNumber.Text
        $tsenv.Value("SMSTSPreferredAdvertID") = "PIM2087B"
		$Window.Close()
    }
})



hideConsole
$Null = $Window.ShowDialog()