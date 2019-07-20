######
# For Starting a single or ALL AWS Workspaces.  
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
$workspaceuser = Read-host "`nWould you like to start a single workspace or all? (all|userid)"

$workspaceinfo = aws workspaces describe-workspaces --no-verify-ssl | ConvertFrom-Json
$data = $workspaceinfo.Workspaces | select UserName, WorkspaceId, State, IpAddress, ComputerName

If ($workspaceuser -eq "all") {
    $startall = Read-Host "`nAre you sure you want to start ALL AWS Workspaces? (y/n)"    
    if ($startall -eq "y") {    
        foreach ($space in $data.WorkspaceId) {
        aws workspaces start-workspaces --start-workspace-request WorkspaceId=$space --no-verify-ssl
        "$space,$date"
        } #end foreach
     } # end if
     else{
     "We did not start the workspaces...."
     }#end else
} #endIf
else{
    
    $userspace = $data | where {$_.Username -EQ $workspaceuser} | select -ExpandProperty WorkspaceId 
    $startone = Read-Host "`nAre you sure you want to start user $workspaceuser\$userspace's AWS Workspace? (y/n)"
    if ($startone -eq "y") {
    aws workspaces start-workspaces --start-workspace-request WorkspaceId=$userspace --no-verify-ssl
    } #endi if
    else{
    "`nWe did not start $userspace's Workspace...."
    } #end else
} #end else

#$data | Out-File "$home\desktop\WorkspacesInfo.csv"