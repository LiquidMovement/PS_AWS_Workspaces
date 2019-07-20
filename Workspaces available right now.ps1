######
# For counting how many active workspaces right now.  
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
$Availablecount = 0
$pendingcount = 0
$totalcount = 0

$workspaceinfo = aws workspaces describe-workspaces --no-verify-ssl| ConvertFrom-Json

$data = $workspaceinfo.Workspaces | select UserName, WorkspaceId, State, IpAddress, ComputerName #| ft


Foreach ($space in $data) {
    $totalcount = $totalcount + 1
    if ( $space.State -eq "AVAILABLE" ) {
        $Availablecount = $Availablecount + 1
    }#end IF
    elseif ( $space.State -eq "PENDING" ) {
        $pendingcount = $pendingcount + 1
    }#end elseif
}#End foreach

Write-Host "`nTotal: $totalcount"
Write-Host "`nAvailable: $Availablecount"
Write-Host "`nPending: $pendingcount"
"`n"
Pause