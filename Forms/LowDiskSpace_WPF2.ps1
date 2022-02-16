#Hide Powershell Window
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
hideConsole
#Build the GUI
    #Gather free space on local drive C
        $cdrive = Get-CimInstance Win32_logicaldisk | Where{$_.DeviceID -eq 'c:'}
        $GigsFreeNotRounded = $cdrive.freespace / 1024000000
        $GigsFree = [System.Math]::Round($GigsFreeNotRounded, 2)

[xml]$xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApp1"
        Title="Low Disk Space" Height="450" Width="700" >
    <Grid>
                <Image Source="\\spsccm\cmsource$\Packages\Forms\Low_Disk_Space\PimaITD.png" Height="400" Width="354" Stretch="Uniform" Margin="170,-60,168,59"/>

        <TextBlock 
            HorizontalAlignment="Center"
            Margin="10,-80,10,0"
            TextWrapping="Wrap"
            Text="The Windows 10 upgrade cannot continue."
            VerticalAlignment="Center"
            FontFamily="Segoe UI"
            FontSize="24"
            FontWeight="Bold"/>

        <TextBlock 
            HorizontalAlignment="Center"
            Margin="0,20,0,0"
            TextWrapping="Wrap"
            Text="Reason: Less than 15 GB of free space available on disk ($GigsFree GB free)."
            VerticalAlignment="Center"
            FontFamily="Segoe UI"
            FontSize="20"
            Foreground="#CC0000"
            FontWeight="Bold"/>

        <TextBlock 
            HorizontalAlignment="Center"
            Margin="0,80,0,0"
            TextWrapping="Wrap"
            Text="Please free up more than 15 GB of storage space before the next attempt."
            VerticalAlignment="Center"
            FontFamily="Segoe UI"
            FontSize="16"
            Foreground="#CC0000"/>

        <TextBlock
            HorizontalAlignment="Center"
            Margin="0,180,0,0"
            TextWrapping="Wrap"
            Text="If you need assistance, please contact the NOC at (520) 724-8471."
            VerticalAlignment="Center"
            FontFamily="Segoe UI"
            FontSize="20"
            FontWeight="Bold"/>

        <Button  x:Name="B1" HorizontalAlignment="Center" Margin="0,315,0,0" Height="40" Width="100" Content="OK" IsCancel="True"/>
    </Grid>
</Window>

"@
Add-Type -AssemblyName PresentationFramework
$reader=(New-Object System.Xml.XmlNodeReader  $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )
$window.Topmost = $true

#Connect to Controls 

$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach {
    New-Variable  -Name $_.Name -Value $Window.FindName($_.Name) -Force
} 

#$Services_btn.Add_Click({
    #$Results.Content.Text = (Get-Service -ComputerName $Computername.Content.Text) | Out-String
#})

#$Processes_btn.Add_Click({
    #$Results.Content.Text = (Get-process -ComputerName $Computername.Content.Text) | Out-String
#})


$Null = $Window.ShowDialog()
Exit(0x80070070)