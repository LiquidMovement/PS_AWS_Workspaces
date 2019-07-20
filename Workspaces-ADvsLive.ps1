######
# For removing dead workspaces from AD.  
# Be sure to have ran "AWS Configure" before attempting this script
#
# Available Items:
#
# WorkspaceId
# DirectoryId
# UserName
# IpAddress**
# State
# BundleId**
# SubnetId**
# ComputerName**
# BundleId
# VolumeEncryptionKey
# UserVolumeEncryptionEnabled
# RootVolumeEncryptionEnabled
# WorkspaceProperties
# ModificationStates
#
#   **only present when workspace state is "Available"
####

$date = Get-Date
$datef = Get-Date -Format MMddyyyy
$workspaceinfo = aws workspaces describe-workspaces --no-verify-ssl | ConvertFrom-Json
$data = $workspaceinfo.Workspaces | select UserName, WorkspaceId, State, IpAddress, ComputerName
$nonadmachines = New-Object System.Collections.ArrayList
$adcomps = Get-ADComputer -SearchBase "OU=AWS-RemoteAccess,OU=XXXX,DC=XXXX,DC=XXXX,DC=XXXX" -Filter "*"

function removefromworkspaces {
    foreach ($nonadmachine in $nonadmachines) {
        if ($nonadmachine -like $adcomps) {
            "Full STOP, there is an issue.  $nonadmachine should not exist"
        }#end if
        else{
        $remove = Read-Host "Are you sure you want to remove $nonadmachine from Workspaces? (y/n)"
        } #end else
    }#end foreach
} #end removefromworkspaces

Function remove-from-AD {
    $removeorreport = Read-Host "`nWould you like to create a report, or remove all found machines from Active Directory?  Please enter 'Remove' or 'Report'"
        foreach ($comp in $adcomps) {
            if (!($data.ComputerName.Contains($comp.Name))) {
                $compname = $comp.Name
                "$compname is in AD, but not workspaces, should remove"
                if ($removeorreport -eq 'Remove') {
                    $areyousure = Read-Host "Would you like to remove $compname from AD? (y/n)"
                    if ($areyousure -eq "y") {
                        $reallysure = Read-Host "no, seriously, this can't be undone!! Are you really sure? (y/n)"
                        if ($reallysure -eq "y") {
                            Remove-ADComputer -Identity $compname
                            "$compname removed" | Out-File "c:\temp\workspaces-Remove_From-AD_$datef.txt" -Append
                            "$compname removed"
                        } #end if
                    } #endif
                }#endif
                elseif ($removeorreport -eq 'Report') {
                    $compname | Out-File "c:\temp\workspaces-in-AD_$datef.txt" -Append
                    
                }#end elseif
            }#endif
        }#endforeach
        if ($removeorreport -eq 'Report') {
        "`nPlease find you report at c:\temp\workspaces-in-AD_$datef.txt" 
        pause
        }#endif
} #end removefromad 


##start the script!!

foreach ($space in $data) {
    $workspaceid = $space.WorkspaceId
    $machinename = $space | select -ExpandProperty ComputerName
    try {
        If (Test-Connection -ComputerName $machinename -Count 1 -Quiet ) {
            if (Get-ADComputer -Identity $machinename) {
                "$machinename is a member of the Domain!"
            }#endif
            else{
                "$machine is not in the domain, but is live on AWS"
            }#end else
        
        }#endif
        else {
            $nonadmachines.Add($machinename)
            "$workspaceid is not available to compare"
        } #end else
    }#end try
    catch 
        {
        "$workspaceid did *NOT* test connection successfully. Is it Available?"
        }#end catch
}#end foreach


remove-from-AD