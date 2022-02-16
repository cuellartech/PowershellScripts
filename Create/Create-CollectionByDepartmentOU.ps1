####SCCM Module###############################################################################
Import-Module 'C:\Program Files (x86)\ConfigMgrConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
##############################################################################################
$depts = $null
$ouPaths = (Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase 'OU=Central Departments,DC=CENTRAL,DC=PIMA,DC=GOV'| Where{($_.DistinguishedName -like 'OU=_Computers*')}).DistinguishedName | Sort-Object
foreach($ouPath in $ouPaths){
    $dept = New-Object -TypeName PSObject
    $dName = (ConvertFrom-StringData -StringData ($ouPath -split ",")[1]).ou
    $dept | Add-Member -NotePropertyName "Department" -NotePropertyValue "$dName"
    $dept | Add-Member -NotePropertyName "OU" -NotePropertyValue "$ouPath"
    $depts +=, $dept
}
foreach($d in $depts){
    Set-Location PIM:
    $dept = $d.Department
    $ouDs = (Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase "$($d.ou)"| Select Name, DistinguishedName |Sort-Object)
    foreach($ouD in $ouDs){
        if(!(test-path "PIM:\DeviceCollection\Departments\By Device OU\$dept")){New-item -Name "$dept" -Path "PIM:\DeviceCollection\Departments\By Device OU\"}
        
        if(!(Get-CMDeviceCollection -Name "All Systems in $dept $($ouD.name) OU")){
        New-CMDeviceCollection -Name "All Systems in $dept $($ouD.name) OU" -LimitingCollectionName 'All Systems - Pima County'
        Get-CMDeviceCollection -Name "All Systems in $dept $($ouD.name) OU" | Move-CMObject -FolderPath "PIM:\DeviceCollection\Departments\By Device OU\$dept"
        Add-CMDeviceCollectionQueryMembershipRule -CollectionName "All Systems in $dept $($ouD.name) OU" -RuleName "$dept $($ouD.name) OU Query" -QueryExpression "select *  from  SMS_R_System where SMS_R_System.DistinguishedName like `"%$($ouD.DistinguishedName)`""
        }
    }
}