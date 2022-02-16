############################################
#Create Always-ON VPN Variables
############################################
$ProfileName = 'PimaCty-IKE'
###############################
#Start Script
###############################
$ProfileNameEscaped = $ProfileName -replace ' ', '%20'

$ProfileXML = '<VPNProfile>
<NativeProfile>
    <Servers>aovpn.pima.gov</Servers>
    <NativeProtocolType>IKEv2</NativeProtocolType>
    <Authentication>
        <MachineMethod>Certificate</MachineMethod>
    </Authentication>
    <RoutingPolicyType>SplitTunnel</RoutingPolicyType>
    <DisableClassBasedDefaultRoute>true</DisableClassBasedDefaultRoute>
</NativeProfile>
<Route>
    <Address>10.0.0.0</Address>
    <PrefixSize>8</PrefixSize>
</Route>
<Route>
    <Address>159.233.0.0</Address>
    <PrefixSize>16</PrefixSize>
</Route>

<DomainNameInformation>
    <DnsServers>159.233.7.92,159.233.7.93</DnsServers>
</DomainNameInformation>

    <AlwaysOn>true</AlwaysOn>
    <RememberCredentials>true</RememberCredentials>
    <TrustedNetworkDetection>pima.gov</TrustedNetworkDetection>
    <DeviceTunnel>true</DeviceTunnel>
    <RegisterDNS>true</RegisterDNS>
    <DnsSuffix>central.pima.gov</DnsSuffix>
</VPNProfile>'

$ProfileXML = $ProfileXML -replace '<', '&lt;'
$ProfileXML = $ProfileXML -replace '>', '&gt;'
$ProfileXML = $ProfileXML -replace '"', '&quot;'

$nodeCSPURI = './Vendor/MSFT/VPNv2'
$namespaceName = 'root\cimv2\mdm\dmmap'
$className = 'MDM_VPNv2_01'

try
{
$username = Get-WmiObject -Class Win32_ComputerSystem | Select-Object username
$objuser = New-Object System.Security.Principal.NTAccount($username.username)
$sid = $objuser.Translate([System.Security.Principal.SecurityIdentifier])
$SidValue = $sid.Value
$Message = "User SID is $SidValue."
Write-Host "$Message"
}
catch [Exception]
{
$Message = "Unable to get user SID. User may be logged on over Remote Desktop: $_"
Write-Host "$Message"
[Environment]::Exit(5)
}

$session = New-CimSession
$options = New-Object Microsoft.Management.Infrastructure.Options.CimOperationOptions
$options.SetCustomOption('PolicyPlatformContext_PrincipalContext_Type', 'PolicyPlatform_UserContext', $false)
$options.SetCustomOption('PolicyPlatformContext_PrincipalContext_Id', "$SidValue", $false)

try
{
    $deleteInstances = $session.EnumerateInstances($namespaceName, $className, $options)
    foreach ($deleteInstance in $deleteInstances)
    {
        $InstanceId = $deleteInstance.InstanceID
        if ("$InstanceId" -eq "$ProfileNameEscaped")
        {
            $session.DeleteInstance($namespaceName, $deleteInstance, $options)
            $Message = "Removed $ProfileName profile $InstanceId"
            Write-Host "$Message"
        } else {
            $Message = "Ignoring existing VPN profile $InstanceId"
            Write-Host "$Message"
        }
    }
}
catch [Exception]
{
    $Message = "Unable to remove existing outdated instance(s) of $ProfileName profile: $_"
    Write-Host "$Message"
    exit
}

try
{
    $newInstance = New-Object Microsoft.Management.Infrastructure.CimInstance $className, $namespaceName
    $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("ParentID", "$nodeCSPURI", 'String', 'Key')
    $newInstance.CimInstanceProperties.Add($property)
    $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("InstanceID", "$ProfileNameEscaped", 'String', 'Key')
    $newInstance.CimInstanceProperties.Add($property)
    $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("ProfileXML", "$ProfileXML", 'String', 'Property')
    $newInstance.CimInstanceProperties.Add($property)
    $session.CreateInstance($namespaceName, $newInstance, $options)
    $Message = "Created $ProfileName profile."

    Write-Host "$Message"
}
catch [Exception]
{
    $Message = "Unable to create $ProfileName profile: $_"
    Write-Host "$Message"
    exit
}

$Message = "Script Complete"
Write-Host "$Message"

Set-VpnConnection PimaCty-IKE -EncryptionLevel Required
Set-NetIPInterface -InterfaceAlias "PimaCty-IKE" -InterfaceMetric 2

If (!(Get-ScheduledTask -TaskName 'AOVPN - Set Interface Metric' -ErrorAction SilentlyContinue)) {
       Register-ScheduledTask -Xml '.\AOVPN - Set Interface Metric.XML' -TaskName 'AOVPN - Set Interface Metric'
       }

If (Get-VPNConnection -Name 'PimaCty-IKE') { [Environment]::Exit(0) }
Else { [Environment]::Exit(0) }
