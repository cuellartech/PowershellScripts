function RemoveUsers{
    $Computer = [ADSI]("WinNT://$env:computername,computer")
    $Group = $Computer.PSBase.Children.Find("Administrators")
    
    $admins = $group.psbase.invoke(“Members”)|%{$_.gettype().InvokeMember(“Adspath”,’GetProperty’,$null, $_, $null)}
    $admins = $admins.replace("WinNT://CENTRAL/$env:computername/","")
    $admins = $admins.replace("WinNT://CENTRAL/","")
    
    ForEach ($User in $admins)
    {   
        If($user -ne "LG_Workstations_All_Administrators" -and $user -ne "Domain Admins"-and $user -ne "Administrator"){
            $User
            $Group.Remove("WinNT://$User")
        }
    }
}
RemoveUsers