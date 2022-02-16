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
function SQL_CONNECT ($Query){
    $ConnectionString = "server=SDITDDB;database=RBDDB;Persist Security Info=True;User ID=$($tsenv.Value('TSSQLAC'));Password=$($tsenv.Value('TSSQLAP'));"    
    $SqlConnection = New-Object  System.Data.SQLClient.SQLConnection($ConnectionString)
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.Connection = $SqlConnection
    $SqlCmd.CommandText = $Query
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd
    $DataSet = New-Object System.Data.DataSet
    $SqlAdapter.Fill($DataSet)
    $SqlConnection.Close()
    $DataSet.Tables[0]
}
hideConsole
#Build the GUI
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
	xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
	xmlns:local="clr-namespace:CM_Deployment_Status"
        Title="" Height="420" Width="571.423" MinWidth="400" MinHeight="100" ResizeMode="NoResize">
    <Grid>
        <Rectangle Fill="#FF1BA1E2" Stroke="#FF1BA1E2" RenderTransformOrigin="0.506,0.917"/>
        <Border BorderBrush="#FFCDCDCD" BorderThickness="1" HorizontalAlignment="Left" Height="39" Margin="25,338,0,0" VerticalAlignment="Top" Width="513"/>
        <Button x:Name="btnOK" Content="OK" Margin="420,69,0,0" FontWeight="Bold" FontSize="14" Background="White" Foreground="#FF1BA1E2" BorderBrush="#FF006CA0" RenderTransformOrigin="1,1" IsDefault="True" Width="102" Height="40" HorizontalAlignment="Left" VerticalAlignment="Top"/>
        <Label x:Name="lblMain" Content="Device Name" Margin="15,8,0,0" Foreground="White" Height="46" FontSize="30" RenderTransformOrigin="0.5,0.5" FontWeight="SemiBold" TextOptions.TextHintingMode="Animated" HorizontalAlignment="Left" VerticalAlignment="Top" Width="323">
            <Label.RenderTransform>
                <TransformGroup>
                    <ScaleTransform/>
                    <SkewTransform AngleX="1.652"/>
                    <RotateTransform/>
                    <TranslateTransform X="0.721"/>
                </TransformGroup>
            </Label.RenderTransform>
        </Label>
        <Label x:Name="lblDomain" Content="Domain:" Margin="16,80,0,0" Foreground="White" Height="55" FontSize="16" RenderTransformOrigin="0.5,0.5" TextOptions.TextHintingMode="Animated" HorizontalAlignment="Left" VerticalAlignment="Top" Width="101">
            <Label.RenderTransform>
                <TransformGroup>
                    <ScaleTransform/>
                    <SkewTransform AngleX="1.652"/>
                    <RotateTransform/>
                    <TranslateTransform X="0.721"/>
                </TransformGroup>
            </Label.RenderTransform>
        </Label>
        <Label x:Name="lblDepartment" Content="Department:" Margin="16,120,0,0" Foreground="White" Height="55" FontSize="16" RenderTransformOrigin="0.5,0.5" TextOptions.TextHintingMode="Animated" HorizontalAlignment="Left" VerticalAlignment="Top" Width="101">
            <Label.RenderTransform>
                <TransformGroup>
                    <ScaleTransform/>
                    <SkewTransform AngleX="1.652"/>
                    <RotateTransform/>
                    <TranslateTransform X="0.721"/>
                </TransformGroup>
            </Label.RenderTransform>
        </Label>
        <Label x:Name="lblUsage" Content="Usage:" Margin="57,160,0,0" Foreground="White" Height="55" FontSize="16" RenderTransformOrigin="0.5,0.5" TextOptions.TextHintingMode="Animated" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75">
            <Label.RenderTransform>
                <TransformGroup>
                    <ScaleTransform/>
                    <SkewTransform AngleX="1.652"/>
                    <RotateTransform/>
                    <TranslateTransform X="0.721"/>
                </TransformGroup>
            </Label.RenderTransform>
        </Label>
        <ComboBox x:Name="cmbDomain" HorizontalAlignment="Left" Height="30" Margin="122,81,0,0" VerticalAlignment="Top" Width="270" TabIndex="1" Padding="4"/>
        <ComboBox x:Name="cmbDepartment" HorizontalAlignment="Left" Height="30" Margin="122,121,0,0" VerticalAlignment="Top" Width="270" TabIndex="1" Padding="4"/>
        <ComboBox x:Name="cmbUsage" HorizontalAlignment="Left" Height="30" Margin="122,161,0,0" VerticalAlignment="Top" Width="270" TabIndex="2" Padding="4"/>
        <RadioButton x:Name="rbDesktop" Content="Desktop" HorizontalAlignment="Left" Margin="436,125,0,0" VerticalAlignment="Top"/>
        <RadioButton x:Name="rbLaptop" Content="Laptop" HorizontalAlignment="Left" Margin="436,158,0,0" VerticalAlignment="Top"/>
        <RadioButton x:Name="rbMobile" Content="Mobile" HorizontalAlignment="Left" Margin="436,192,0,0" VerticalAlignment="Top"/>
        <RadioButton x:Name="rbTablet" Content="Tablet" HorizontalAlignment="Left" Margin="436,226,0,0" VerticalAlignment="Top"/> 
        <CheckBox x:Name="cbAddToGroup" Content="Add user to RDP" HorizontalAlignment="Left" Margin="420,273,0,0" VerticalAlignment="Top" Foreground="White" RenderTransformOrigin="0.988,0.689"/>
        <Label x:Name="lblMain_Copy" Content="Location:" Margin="40,194,0,0" Foreground="White" Height="30" FontSize="16" RenderTransformOrigin="0.5,0.5" TextOptions.TextHintingMode="Animated" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75">
            <Label.RenderTransform>
                <TransformGroup>
                    <ScaleTransform/>
                    <SkewTransform AngleX="1.652"/>
                    <RotateTransform/>
                    <TranslateTransform X="0.721"/>
                </TransformGroup>
            </Label.RenderTransform>
        </Label>
        <ComboBox x:Name="cmbLocation" HorizontalAlignment="Left" Height="30" Margin="122,195,0,0" VerticalAlignment="Top" Width="270" TabIndex="3" Padding="4"/>
        <Label x:Name="lblcName" Content="" Margin="250,15,36,0" Foreground="White" Height="36" FontSize="24" RenderTransformOrigin="0.5,0.5" TextOptions.TextHintingMode="Animated" VerticalAlignment="Top" HorizontalContentAlignment="Stretch">
            <Label.RenderTransform>
                <TransformGroup>
                    <ScaleTransform/>
                    <SkewTransform AngleX="1.652"/>
                    <RotateTransform/>
                    <TranslateTransform X="0.721"/>
                </TransformGroup>
            </Label.RenderTransform>
        </Label>
        <Label x:Name="lblFloor" Content="Floor\Bld:" Margin="36,228,0,0" Foreground="White" Height="30" FontSize="16" RenderTransformOrigin="0.5,0.5" TextOptions.TextHintingMode="Animated" HorizontalAlignment="Left" VerticalAlignment="Top" Width="84">
            <Label.RenderTransform>
                <TransformGroup>
                    <ScaleTransform/>
                    <SkewTransform AngleX="1.652"/>
                    <RotateTransform/>
                    <TranslateTransform X="0.721"/>
                </TransformGroup>
            </Label.RenderTransform>
        </Label>
        <Label x:Name="lblUser" Content="User:" Margin="69,263,0,0" Foreground="White" Height="30" FontSize="16" RenderTransformOrigin="0.5,0.5" TextOptions.TextHintingMode="Animated" HorizontalAlignment="Left" VerticalAlignment="Top" Width="84">
            <Label.RenderTransform>
                <TransformGroup>
                    <ScaleTransform/>
                    <SkewTransform AngleX="1.652"/>
                    <RotateTransform/>
                    <TranslateTransform X="0.721"/>
                </TransformGroup>
            </Label.RenderTransform>
        </Label>
        <ComboBox x:Name="cmbLocation2" HorizontalAlignment="Left" Height="34" Margin="122,229,0,0" VerticalAlignment="Top" Width="270" TabIndex="3" IsEnabled="False" Visibility="Hidden"/>
        <CheckBox x:Name="cbWorkGroup" Content="Workgroup" HorizontalAlignment="Left" Margin="43,350,0,0" VerticalAlignment="Top" Foreground="White" RenderTransformOrigin="0.088,0.644"/>
        <CheckBox x:Name="cbVIP" Content="VIP" HorizontalAlignment="Left" Margin="135,350,0,0" VerticalAlignment="Top" Foreground="White" RenderTransformOrigin="0.988,0.689"/>
        <CheckBox x:Name="cbNoAMP" Content="NoAMP" HorizontalAlignment="Left" Margin="190,350,0,0" VerticalAlignment="Top" Foreground="White" RenderTransformOrigin="0.988,0.689"/>
        <TextBox x:Name="tbLocation2" HorizontalAlignment="Left" Height="30" Margin="122,229,0,0" TextWrapping="Wrap" TabIndex="3" VerticalAlignment="Top" Width="270" Padding="4"/>
        <TextBox x:Name="tbUser" HorizontalAlignment="Left" Height="30" Margin="122,265,0,0" TextWrapping="Wrap" TabIndex="3" VerticalAlignment="Top" Width="270" Padding="4"/>
        <Label x:Name="lblMain_Copy1" Content="Software:" Margin="38,300,0,0" Foreground="White" Height="30" FontSize="16" RenderTransformOrigin="0.5,0.5" TextOptions.TextHintingMode="Animated" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75">
            <Label.RenderTransform>
                <TransformGroup>
                    <ScaleTransform/>
                    <SkewTransform AngleX="1.652"/>
                    <RotateTransform/>
                    <TranslateTransform X="0.721"/>
                </TransformGroup>
            </Label.RenderTransform>
        </Label>
        <ComboBox x:Name="cmbSPackage" HorizontalAlignment="Left" Height="30" Margin="122,300,0,0" VerticalAlignment="Top" Width="270" TabIndex="5" SelectedIndex="0" Padding="4">
            <ComboBoxItem Content="Standard"/>
        </ComboBox>
    </Grid>
</Window>
"@

$global:tsenv
$global:cname
$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
$sccmname = $tsenv.Value("_SMSTSMachineName")
$serial = (Get-WmiObject win32_BIOS).SerialNumber
$manu = (Get-WmiObject Win32_ComputerSystem).Manufacturer

if(($manu -like "Microsoft*") -or ($manu -like "Dell*")){
    $namEnd = $SERIAL.trim().substring(0,6)
}
else{
    $namEnd = $SERIAL.trim().substring($SERIAL.length - 6,6)
}

Add-Type -AssemblyName PresentationFramework
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )
$window.Topmost = $true

#Connect to Controls 
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object {
	New-Variable  -Name $_.Name -Value $Window.FindName($_.Name) -Force
} 

$domains = @(
    "Central",
    "Community"
    "Schools"
)

$dbDepts = SQL_CONNECT "Select * from DepartmentID"| Sort-Object Code |ForEach-Object{"$($_.Code.trim())  $($_.Department.trim())"}
if($dbDepts.count -lt 5){
    $depts = @(
    "BOS  Board of Supervisors",
    "CA  County Administrator ",
    "CD  Community Development & Neighborhood Conservation (CDNC)",
    "CED  Community Economic Development",
    "CL  Clerk of the Board",
    "CO  Constables",
    "CS  Community Services, Employment & Training (CSET)",
    "CM   Communications",
    "DE  Dept of Environmental Quality",
    "DSD  Developmental Services ",
    "ED  Attractions & Tourism",
    "EL  Elections",
    "FC  Flood Control",
    "FM  Facilities Management",
    "FN  Finance & Risk Management",
    "FS  Fleet",
    "FSC  Office of the Medical Examiner (Forensic Science Center)",
    "GGS  General Government Services Administration"
    "GMI  Grants Management & Innovation",
    "HD  Health",
    "HR  Human Resources",
    "ID  Indigent Defense",
    "IT  Information Technology",
    "JCA  Justice Court Ajo",
    #"JU  Justice Court", (No longer valid as of 9/18/2019 FNG)
    "JCG  Justice Court Green Valley",
    "KSC  Stadium District",
    "LIB  Library",
    "OEM  Office of Emergency Management and Homeland Security",
    "BH  Behavioral Health",
    "PAC  Pima Animal Care",
    "PDS  Public Defense Services",
    "PO  Procurement",
    "PR  Natural Resources, Parks, and Recreation",
    "PW  Project Management Office",
    #"PW  Capital Improvement Project", (No longer valid as of 9/18/2019 by FNG and replaced by "PW Project Management Office")
    #"PW  Public Works Administration", (No longer valid as of 9/18/2019 FNG and replaed by "PW Project Management Office")
    "RP  Real Property Services",
    "SOS  School Superintendent ",
    "SUS  Office of Sustainability and Conservation",
    "TR  Dept of Transportation",
    "WHS IT Warehouse",
    "WIN  Wireless Integrated Network",
    "WW  Regional Wastewater Reclamation Dept",
	"XX   Other, Please Rename after imaging"
    )
}
else{$depts = $dbDepts}

$dbLocs = SQL_CONNECT "Select * from LocationCodes"|Sort-Object Code |ForEach-Object{"$($_.Code.trim())  $($_.Location.trim())"}

if($dbLocs.count -lt 5){
    $locs = @(
    ""
    "33N  33 N Stone",
    "ABR  Abrams",
    "ADE  Administration East",
    "ADW  Administration West",
    "JAI  Adult Detention Center / Library Jail",
    "ACP  Agua Caliente Park	",
    "AYC  Angel Youth Center (2323 S Park Ave)",
    "AVV  Avra Valley	",
    "BOS  Board of Supervisors",
    "BFN  Brandi Fenton park",
    "CTL  Catalina Park	",
    "CLC  Central Lab Complex (CRAO)",
    "CPL  Central Plant",
    "CHR  Chicken Ranch (NRPR)",
    "CNR  Continental  Ranch",
    "CNV  Conveyance (Dodge)",
    "CDT  Corona de Tucson",
    "DOM  Documents/Microgfx (Benson Highway)",
    "DXL  Drexel Heights Community Center",
    "EPC  El Pueblo Center (175 W Irvington)",
    "ECC  Elections 6550 S. Country Club",
    "GVY  Green Valley",
    "HCA  Health Ajo Clinic	",
    "HCF  Health Clinic -Flowing Wells	",
    "HCT  Health Clinic -Teresa Lee  (1493 W Commerce Ct.)",
    "HCE  Health East Clinic",
    "HCG  Health Green Valley Clinic",
    "HCN  Health North Clinic",
    "I  Tres Rios (Ina Rd)",
    "JKE  Jackson Employment",
    "JDC  Juvenile Detention Center / Library JDC",
    "KSC  Kino Service Center",
    "KSD  Kino Stadium District",
    "KTC  Kino Teen Center",
    "LAS  Las Artes",
    "LSB  Legal Services Building",
    "LND  Lindsey Center",
    "LCC  Littletown Community Center",
    "M  Mission Rd",
    "MTL  Mt Lemmon",
    "PRM  NRPR Main Office (3500 W River Rd.)",
    "PRW  NRPR Warehouse",
    "OCH  Old Court House",
    "OEM  PECOC 3434 E 22nd St",
    "PAC  PACC 4000 N Silvervell Rd",
    "PCC  Picture Rocks Community Center",
    "PHC  Pima Housing Center (El Banco)",
    "PSC  Public Service Center Bldg.",
    "PWB  Public Works",
    "RNV  Rio Nuevo",
    "ROB  Robles Ranch Community Center",
    "SRF  Sub-Regional Fac.",
    "TBC  Tuberculosis Clinic",
    "VC  Veteran’s Center",
	"XX  Other",
    "PI  Pima Vocational High School - INA",
    "IR  Pima Vocational High School - IRVINGTON"
    )
}
Else{
    $locs = @("")
    $locs += $dbLocs | Where-Object{$_ -notlike "I?? *" -and $_ -notlike "*Library -*" }
}


$libLocs =  @(
    "AB  Library - Abbett",
    "AJ  Library - Ajo",
    "AR  Library - Arivaca",
    "BC  Library - Bear Canyon",
    "CA  Library - Catalina",
    "CO  Library - Columbus",
    "EP  Library - El Pueblo",
    "ER  Library - El Rio",
    "ES  Library - Esmond Station",
    "FW  Library - Flowing Wells",
    "GL  Library - Golf Links",
    "GV  Library - Green Valley",
    "HI  Library - Himmel",
    "JD  Library - Juvenile Detention",
    "MA  Library - Main",
    "MI  Library - Mission",
    "MT  Library - Midtown",
    "NA  Library - Nanini",
    "OV  Library - Oro Valley",
    "QD  Library - Quincie Douglas",
    "RR  Library - Readrunners (Bookmobile)",
    "RV  Library - Dusenberry-River",
    "SA  Library - Sahuarita",
    "SR  Library - Santa Rosa",
    "ST  Library - South Tucson",
    "SW  Library - Southwest",
    "VA  Library - Valencia",
    "WI  Library - Wilmot",
    "WO  Library - Woods"
)

$dbInaLocs = SQL_CONNECT "Select * from LocationCodes where Code like 'I__%'"|Sort-Object Code |ForEach-Object{"$($_.Code.trim())  $($_.Location.trim())"}
if($dbInaLocs.count -lt 5){
    $InaLocs = @(
        "I01  ADMINISTRATION",
        "I02  CENTRAL MAINTENANCE",
        "I03  DEWATERING STATION",
        "I04  PRIMARY CLARIFIERS WEST",
        "I06  STORAGE TANKS - OUT OF SERVICE",
        "I07  OPEN STORAGE TANK - OUT OF SERVICE",
        "I08  SLUDGE THICKENERS / CONTROL",
        "I09  SOLIDS THICKENING",
        "I10  DIEGESTER CONTROL EAST",
        "I11  DIGESTER CONTROL EAST",
        "I12  SAMPLING/ STORAGE",
        "I13  CHLORINE CONTACT BASINS WEST",
        "I14  ENERGY RECOVERY",
        "I15  TUNNELS",
        "I16  OPERATIONS CONTROL CENTER",
        "I17  SERVICE WATER",
        "I18  DOMESTIC WELL",
        "I19  SERVICE WATER ELECTRICAL",
        "I21  SERVICE WATER BOOSTER STATION / FILL STAND",
        "I22  SLUDGE STORAGE BASIN / LOADOUT",
        "I23  CENTRIFUGE",
        "I23A  DIGESTED SLUDGE SCREEN",
        "I23B  TTHM CENTRATE DOSING",
        "I25  WAREHOUSE K",
        "I26  PIG RECEIVING UNIT",
        "I27  WASTE GAS BURNER",
        "I28  O&M SHOP",
        "I29  DOC OFFICE",
        "I30  HEADWORKS",
        "I31  LAYDOWN YARD",
        "I32  INTERMEDIATE PUMP STATION EAST",
        "I33  PRIMARY CLARIFIERS EAST",
        "I34  BLOWERS EAST",
        "I35  BIOREACTOR BASINS",
        "I36  SEONDARY CLARIFIERS EAST",
        "I37  RAS / WAS PUMP STATION EAST",
        "I38  CHLORINE CONTACT BASINS EAST",
        "I40  TANK DRAIN PUMP STATION EAST",
        "I41  FINAL PARSHALL FLUME",
        "I43  EMERGENCY OVERFLOW BASIN",
        "I46  BLOWERS WEST",
        "I48  BIOREACTOR BASINS WEST",
        "I49  BIOREACTOR BASIN EAST",
        "I50  SECONDARY CLARIFIERS WEST",
        "I52A  CHLORINE CONTACT BASINS",
        "I52B  SODIUM BISULFITE",
        "I52C  EFFLUENT SAMPLING",
        "I54  SODIUM HYPOCHLORITE",
        "I58  WAS THICKENING",
        "I60  DIGESTERS COMPLEX WEST",
        "I63  DIGESTED SLUDGE THICKENING - OUT OF SERVICE",
        "I70  SLUDGE RECYCLE TANKS ANS PUMP STATION",
        "I76  PLANT / TANK DRAIN PUMP STATION WEST",
        "I80  RESTROOM",
        "I82  46 KV SUBSTATION",
        "I84  MAIN SWITCHGEAR",
        "I85  SUBSTATION",
        "I86  CENTRAL PLANT",
        "I88  WAREHOUSE/O & M"
    )
}
Else{
    $InaLocs = $dbInaLocs
}

$ConvLocs = @(
    "Bldg 1 – Administration",
    "Bldg 2 – Field Operations",
    "Bldg 3 – Warehouse/Shop",
    "Bldg 4 – Pumps/Odor Control (Richey Yard)"
)

$mainFloors = @(
    "1",
    "2",
    "3",
    "4"
)

$usages = @(
"C  Conference",
"G  Grant",
"K  Kiosk",
"L  Loaner",
"N  Normal",
"S  Shared",
"T  Test"
)

$usagesPatron = @(
    "C  Child",
    "T  Teen",
    "S  STA",
    "U  Sign-up",
    "A  ADA",
    "E  Express",
    "J  Job",
    "X  Self-Check",
    "K  Kiosk",
    "O  OPAC",
    "L  Lab Computer",
    "M  Cash Drawer"
)

$hwIdent = if((Get-WmiObject Win32_Battery)){if(((Get-WmiObject Win32_SystemEnclosure).ChassisTypes -eq 8) -or ((Get-WmiObject Win32_ComputerSystem).PCSystemTypeEx -eq "8")){"M"} Else{"L"}}Else{"D"}
Switch($hwIdent){
    D {$rbDesktop.IsChecked = $true}
    L {$rbLaptop.IsChecked = $true}
    M {$rbMobile.IsChecked = $true}
    T {$rbTablet.IsChecked = $true}
}

$domains| Sort-Object |ForEach-Object{$cmbDomain.AddChild($_)}
$depts| Sort-Object |ForEach-Object{$cmbDepartment.AddChild($_)}
$locs | Sort-Object |ForEach-Object{$cmbLocation.AddChild($_)}
$usages | Sort-Object | ForEach-Object{$cmbUsage.AddChild($_)}

$sccmD = $sccmname.Split("-")[0]
$sccmL = if($sccmname.Split("-")[1].count -ge 3){$locs |Where-Object {$_.split("  ")[0] -match $sccmname.Split("-")[1].substring(0,3)}} else{""}
$sccmF = if($sccmname.Split("-")[1].count -ge 3){if($usages | Where-Object {$_.split("  ")[0] -match $sccmname.Split("-")[2].substring(0,2)[1]}){$usages | Where-Object {$_.split("  ")[0] -match $sccmname.Split("-")[2].substring(0,2)[1]}} else{$usages | Where-Object {$_.split("  ")[0] -match "N"}}}Else{$usages | Where-Object {$_.split("  ")[0] -match $sccmname.Split("-")[1].substring(1,1)}}


if($null -ne $sccmname){
    $cmbDepartment.Text = $depts | Where-Object { if(($_.split("  ")[0] -match $sccmD).count -eq 1){$_.split("  ")[0] -match $sccmD} else{($_.split("  ")[0] -match $sccmD.substring(0,2))[0]}}
    $cmbLocation.Text = $sccmL
    $cmbUsage.Text = $sccmF
}

if($cmbDepartment.Text -eq "LIB  Library"){
    $cmbLocation.items.Clear()
    $cmbLocation.text = ""
    $libLocs| Sort-Object |ForEach-Object{$cmbLocation.AddChild($_)}
    $cmbUsage.items.Clear()
    $usages| Sort-Object |ForEach-Object{$cmbUsage.AddChild($_)}      
}

if($cmbDepartment.SelectedItem -eq "WW  Regional Wastewater Reclamation Dept"){
    $cmbLocation.items.Clear()
    $cmbLocation.text = ""
    $locs | Sort-Object |ForEach-Object{$cmbLocation.AddChild($_)}
    $cmbSPackage.AddChild("Neon Lab")
    $cmbUsage.items.Clear()
    $usages| Sort-Object |ForEach-Object{$cmbUsage.AddChild($_)}
}

$btnOK.Add_Click({
    if(($cmbDomain.SelectedItem -eq $null -or $cmbDepartment.SelectedItem -eq $null -or $cmbUsage.SelectedItem -eq $null) -and ($rbDesktop.IsChecked -or $rbLaptop.IsChecked -or $rbMobile.IsChecked)){
        [System.Windows.Forms.MessageBox]::Show("Verify that you have selected all required items.")
    }
    Else{
        $tsenv.Value("ComputerLocation") = $cmbLocation.SelectedItem + " - " + $cmbLocation2.SelectedItem + $tbLocation2.Text
        if($cmbSPackage.selecteditem -eq "Standard"){
            $tsenv.Value("Department") = $($cmbDepartment.SelectedValue.split("  ")[0].trim())
        }
        elseif($cmbSPackage.selecteditem -eq "Neon Lab"){
            $tsenv.Value("Department") = "WW - Neon Lab"
        }
        $tsenv.Value("OSDComputerName") = $lblcName.Content
        $tsenv.Value("Usage") = "$($cmbUsage.SelectedItem.Substring(0,1))"
        $tsenv.Value("User") = $tbUser.Text.Trim()
        if($cbVIP.IsChecked){
			$tsenv.Value("VIP") = "True"
		}
		if($cbNoAMP.IsChecked){
			$tsenv.Value("NoAMP") = "True"
		}
		if($cbWorkGroup.IsChecked){
			$tsenv.Value("SMSTSDomain") = "None"
        }
        if($cbAddToGroup.IsChecked){
            $tsenv.Value("AddToRDP") = "True"
        }
        if($cmbDomain.SelectedItem -eq "Community" -and $cmbDepartment.SelectedItem -eq "LIB  Library"){
            $tsenv.Value("Patron") = "True"
        }
        if($rbLaptop.IsChecked){
            $tsenv.Value("Laptop") = "True"
        }
        if($rbMobile.IsChecked){
            $tsenv.Value("Laptop") = "True"
        }
        try{
            $sqlID = SQL_CONNECT "Select * from RolloutDeviceID where OldComputerName = '$sccmname'"
            if($sqlID -eq $null){$sqlID = SQL_CONNECT "Select * from RolloutDeviceID where OldComputerName = '$sccmname'"}
            if($sqlID -eq $null){
                SQL_CONNECT "Insert into RolloutDeviceID values ('$($cmbDepartment.SelectedValue.split("  ")[0].trim())','$sccmname','$($lblcName.Content)','Image')"
                $sqlID = SQL_CONNECT "Select * from RolloutDeviceID where NewComputerName = '$newname'"
            }
            else{
                SQL_CONNECT "Update RolloutDeviceID set OldComputerName = '$sccmname', NewComputerName ='$($lblcName.Content)' where IDKey = '$($sqlID.IDKey)'"
            }
        }
        catch{}
        
        $Window.Close()
    }
})

FUNCTION namUpdate{
    $type = "$(if($rbDesktop.IsChecked){"D"}if($rbLaptop.IsChecked){"L"}if($rbMobile.IsChecked){"M"})"
    if((Get-WmiObject Win32_Computersystem).model -like "*Virtual*"){
        $type = "V"
    }
    $usage = "$($cmbUsage.SelectedItem.Substring(0,1))"
    if($cmbDomain.SelectedValue -eq "Community"){
        if($cmbLocation.SelectedItem -eq "I  Tres Rios (Ina Rd)"){
            $location = "$($cmbLocation2.SelectedItem.Substring(0,3))"
        }
        elseif($cmbLocation.SelectedItem -eq "M  Mission Rd") {
            $location = "$($cmbLocation.SelectedItem.Substring(0,1))"
        }
        elseif($cmbLocation.SelectedItem -like "MA*") {
            $location = "$($cmbLocation.SelectedItem.Substring(0,1))$($cmbLocation2.SelectedItem)"
        }
        else{
            $location = "$($cmbLocation.SelectedItem.Substring(0,2))"
        }
        $lblcName.Content = "$($cmbDepartment.SelectedValue.split("  ")[0].trim())-$($location)$($type)$($usage)-$($namEnd)"
    }
    else{
        $lblcName.Content = "$($cmbDepartment.SelectedValue.split("  ")[0].trim())-$($type)$($usage)-$($namEnd)"
    }
}

$cmbDomain.Add_SelectionChanged{
    if($cmbDomain.SelectedItem -eq "Central"){
        $tsenv.Value("SMSTSDomain") = "Central"
        $cmbUsage.items.Clear()
        $usages| Sort-Object |ForEach-Object{$cmbUsage.AddChild($_)}
    }
    if($cmbDomain.SelectedItem -eq "Schools"){
        $tsenv.Value("SMSTSDomain") = "Schools"
        $cmbUsage.items.Clear()
        $usages| Sort-Object |ForEach-Object{$cmbUsage.AddChild($_)}
    }
    elseif($cmbDomain.SelectedItem -eq "Community"){
        $tsenv.Value("SMSTSDomain") = "Community"
        if($cmbDepartment.SelectedValue -eq "LIB  Library"){
            $cmbUsage.items.Clear()
            $usagesPatron| Sort-Object |ForEach-Object{$cmbUsage.AddChild($_)}
        }
        else{
            $cmbUsage.items.Clear()
            $usages| Sort-Object |ForEach-Object{$cmbUsage.AddChild($_)}
        }
    }
    namUpdate
}

$cmbDepartment.Add_SelectionChanged{
    $cmbSPackage.items.Clear()
    $cmbSPackage.AddChild("Standard")
    $cmbSPackage.SelectedIndex = 0

    if($cmbDomain.SelectedValue -eq "Community" -and $cmbDepartment.SelectedValue -eq "LIB  Library"){
        $cmbUsage.items.Clear()
        $usagesPatron| Sort-Object |ForEach-Object{$cmbUsage.AddChild($_)}
        $cmbLocation.items.Clear()
        $cmbLocation.text = ""
        $libLocs| Sort-Object |ForEach-Object{$cmbLocation.AddChild($_)}
    }
    elseif($cmbDepartment.SelectedItem -eq "LIB  Library")
    {
        $cmbLocation.items.Clear()
        $cmbLocation.text = ""
        $libLocs| Sort-Object |ForEach-Object{$cmbLocation.AddChild($_)}
        $cmbUsage.items.Clear()
        $usages| Sort-Object |ForEach-Object{$cmbUsage.AddChild($_)}      
    }
    elseif($cmbDepartment.SelectedItem -eq "WW  Regional Wastewater Reclamation Dept")
    {
        $cmbLocation.items.Clear()
        $cmbLocation.text = ""
        $locs | Sort-Object |ForEach-Object{$cmbLocation.AddChild($_)}
        $cmbSPackage.AddChild("Neon Lab")
        $cmbUsage.items.Clear()
        $usages| Sort-Object |ForEach-Object{$cmbUsage.AddChild($_)}
    }
    else{
        $cmbLocation.items.Clear()
        $cmbLocation.text = ""
        $locs | Sort-Object |ForEach-Object{$cmbLocation.AddChild($_)}
        $cmbUsage.items.Clear()
        $usages| Sort-Object |ForEach-Object{$cmbUsage.AddChild($_)}
    }
    namUpdate
}

$cmbUsage.Add_SelectionChanged{
    namUpdate
}
$rbDesktop.Add_Click{
    namUpdate
}
$rbLaptop.Add_Click{
    namUpdate
}
$rbMobile.Add_Click{
    namUpdate
}

$cmbLocation.Add_SelectionChanged{
    if($cmbLocation.SelectedItem -eq "I  Tres Rios (Ina Rd)")
    {
        $cmbLocation2.items.Clear()
        $cmbLocation2.text = ""
        $InaLocs| Sort-Object | ForEach-Object{$cmbLocation2.AddChild($_)}
        $tbLocation2.IsEnabled = "False"
        $tbLocation2.Visibility = "Hidden"
        $cmbLocation2.IsEnabled = "True"
        $cmbLocation2.Visibility = "Visible"
        $tbLocation2.Text = ""
    }
    elseif($cmbLocation.SelectedItem -eq "CNV  Conveyance (Dodge)")
    {
        $cmbLocation2.items.Clear()
        $cmbLocation2.text = ""
        $ConvLocs | Sort-Object |ForEach-Object{$cmbLocation2.AddChild($_)}
        $tbLocation2.IsEnabled = "False"
        $tbLocation2.Visibility = "Hidden"
        $cmbLocation2.IsEnabled = "True"
        $cmbLocation2.Visibility = "Visible"
        $tbLocation2.Text = ""
    }
    elseif($cmbLocation.SelectedItem -like "MA*")
    {
        $cmbLocation2.items.Clear()
        $cmbLocation2.text = ""
        $mainFloors | Sort-Object |ForEach-Object{$cmbLocation2.AddChild($_)}
        $tbLocation2.IsEnabled = "False"
        $tbLocation2.Visibility = "Hidden"
        $cmbLocation2.IsEnabled = "True"
        $cmbLocation2.Visibility = "Visible"
        $tbLocation2.Text = ""
    }
    else
    {
        $cmbLocation2.items.Clear()
        $cmbLocation2.IsEnabled = "False"
        $cmbLocation2.Visibility = "Hidden"
        $tbLocation2.IsEnabled = "True"
        $tbLocation2.Visibility = "Visible"
    }
    namUpdate
}

$cmbLocation2.Add_SelectionChanged{
    if($cmbLocation.SelectedItem -eq "I  Tres Rios (Ina Rd)"){
        namUpdate
    }
    if($cmbLocation.SelectedItem -like "MA*"){
        namUpdate
    }
}

$cmbSPackage.SelectedIndex = '0'
$cmbDepartment.Focus()

namUpdate
hideConsole
$Null = $Window.ShowDialog()