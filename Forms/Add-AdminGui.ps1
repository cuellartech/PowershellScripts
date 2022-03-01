Add-Type -AssemblyName PresentationCore,PresentationFramework
Add-Type –AssemblyName System.Windows.Forms

#Error check if user has proper credentials
$current = [Security.Principal.WindowsIdentity]::GetCurrent()
$user = $current.Name
$user = $user.ToUpper()

if($user -notlike "CENTRAL\A*"){
    $message = "Please do not run this program with a normal account."
    [System.Windows.Forms.MessageBox]::Show($message)
    exit 1
}
    

#Error check for LAPS powershell Module
if(-not(get-module -listavailable -name "AdmPwd.PS")){
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    Install-Module -Name "AdmPwd.PS"

    if (-not($?)) {
        $message = "LAPS Powershell module not installed. This module is required for the script to function. Please install the module before running."
        [System.Windows.Forms.MessageBox]::Show($message)
        exit 1
    }
}

$DN = '.central.pima.gov'
$Username = '.\administrator'
$Domain = 'Central'
$CompList = @()
#Your XAML goes here :)

$inputXML = @"
<Window x:Name="TextBox2" 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApp1"
        mc:Ignorable="d" Height="470" Width="400" Title="Add-Admin" Background="#FFF1F1F1" WindowStyle="ThreeDBorderWindow" ResizeMode="NoResize">
    <Grid Margin="10">
        <TextBox x:Name="AdminAcct" HorizontalAlignment="Left" Height="22" Margin="135,37,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="174"/>
        <TextBox x:Name="ComputerListEntry" AcceptsReturn="True" HorizontalAlignment="Left" Height="255" Margin="135,98,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="174"/>
        <TextBlock x:Name="textAdmin" HorizontalAlignment="Left" Height="39" Margin="0,37,0,0" TextWrapping="Wrap" Text="Workstation Admin Account" VerticalAlignment="Top" Width="130"/>
        <TextBlock x:Name="textComputer" HorizontalAlignment="Left" Height="34" Margin="0,98,0,0" TextWrapping="Wrap" Text="Computer List" VerticalAlignment="Top" Width="130"/>
        <Button x:Name="buttonAdmin" Content="Add Admin" HorizontalAlignment="Right" Height="35" Margin="0,0,75,20" VerticalAlignment="Bottom" Width="154" Background="#FFF1B257" RenderTransformOrigin="0.649,1.043"/>

    </Grid>
</Window>
"@ 

 

$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'

[xml]$XAML = $inputXML

#Read XAML

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $window = [Windows.Markup.XamlReader]::Load( $reader )
} catch {
    Write-Warning $_.Exception
    throw
}

# Create variables based on form control names.
# Variable will be named as 'var_<control name>'

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)"
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    } catch {
        throw
    }
}

function Add-Admin{

    [System.Collections.ArrayList]$Results = @()
    [System.Collections.ArrayList]$FailedNotExist = @()
    [System.Collections.ArrayList]$FailedOffline = @()
    [System.Collections.ArrayList]$FailedDenied = @()

    foreach ($computer in $complist) {

        $RemoteComputerFQDN = $Computer + $DN

        #error checking for offline or if not in AD
        if(-not(Test-Connection -BufferSize 32 -Count 1 -ComputerName $computer -Quiet)) {
            
            try{Get-ADComputer $computer}
            catch{
                $Failed1 = New-Object -TypeName PSCustomObject -Property @{Host=$computer; ExitCode=1}
                $FailedNotExist.Add($Failed1)
                continue
            }

            $Failed2 = New-Object -TypeName PSCustomObject -Property @{Host=$computer; ExitCode=1}
            $FailedOffline.Add($Failed2)
            continue
        }
        
        $lapspass = ConvertTo-SecureString -AsPlainText ((get-admpwdpassword -ComputerName $computer).password) -Force
        $creds = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $lapspass
        
        $Result = Invoke-AddLocalGroupMember
        
        $Results.Add($Result)

        Reset-AdmPwdPassword -ComputerName $Computer -WhenEffective (Get-Date).AddHours(1)
    }

    #Show relevant messages
    if($Results.Count -ne 0){
        $message += "Admin added to: " 
        $message += $Results | Where-Object {$_.ExitCode -ne 1}
        $message += "`r`n"
        if($message -match "Admin added to: `r`n"){$message = "No admin permissions added. `r`n"}
    }
    if($FailedDenied.Count -ne 0){
        $message += "Failed on $($FailedDenied.host) with access denied. `r`n"
    }
    if($FailedNotExist.Count -ne 0 ){
        $message += "Failed on $($FailedNotExist.host) as they do not exist. `r`n"
    }
    if($FailedOffline.Count -ne 0){
        $message += "Failed on $($FailedOffline.host) as they are offline. `r`n"
    }
    if($FailedNotExist.Count -eq 0 -and $FailedOffline.Count -eq 0 -and $Results.Count -eq 0){
        $message = "No valid computers"
    }

    [System.Windows.Forms.MessageBox]::Show($message)

    #Empty Computer list and repopulate with failed computers
    $var_ComputerListEntry.text = ""
    $FailedDenied | foreach-object {$var_ComputerListEntry.text += "$($_.host) `r`n"}
    $FailedOffline | foreach-object {$var_ComputerListEntry.text += "$($_.host) `r`n"}
    $FailedNotExist | foreach-object {$var_ComputerListEntry.text += "$($_.host) `r`n"} 
}

function Invoke-AddLocalGroupMember
{ 
    $script1 = {
        Add-LocalGroupMember -Group 'Administrators' -Member $($Using:WkStAcct)
    } 
    
    Invoke-Command -ComputerName $RemoteComputerFQDN -Credential $creds -ScriptBlock $script1 

    if(-not($?)){
        
        Invoke-Command -ComputerName $RemoteComputerFQDN -Credential $creds -ScriptBlock {Get-LocalGroupMember -Group 'Administrators' -Member $($Using:WkStAcct)}
        if(-not($?)){
            $failed3 = New-Object -TypeName PSCustomObject -Property @{Host=$computer; Account=$WkStAcct; ExitCode=1}
            $FailedDenied.Add($failed3)
            return $failed3
        }
        else{
        $alreadyAdded = New-Object -TypeName PSCustomObject -Property @{Host=$computer; Account=$WkStAcct; ExitCode=1}
        $alreadyAddedMessage = "Computer $($computer) already has $($WkStAcct) as an administrator"
        [System.Windows.Forms.MessageBox]::Show($alreadyAddedMessage)
        return $alreadyAdded
        }
    }
    
    $functionResult = Invoke-Command -ComputerName $RemoteComputerFQDN -Credential $creds -ScriptBlock {Get-LocalGroupMember -Group 'Administrators' -Member $($Using:WkStAcct) -ErrorAction SilentlyContinue
        New-Object -TypeName PSCustomObject -Property @{Host=$($Using:computer); Account=$functionResult; ExitCode=$exitCode} }
    return $functionResult
}

$var_buttonAdmin.Add_Click( {

    if($var_AdminAcct.text -notlike "a*" -and $var_AdminAcct.text -notlike "A*"){
        $message = "Enter a valid username"
        [System.Windows.Forms.MessageBox]::Show($message)
    }
    else{
        $WkStAcct = 'Central\' + $var_AdminAcct.text

        $CompList = $var_ComputerListEntry.text.Split() | Where-Object { $_ -and $_.Trim() }
        $CompList = $CompList|Select-Object -Unique
    
        Add-Admin
    }
})

$Null = $window.ShowDialog()