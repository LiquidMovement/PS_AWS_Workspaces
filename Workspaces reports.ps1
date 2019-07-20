######
# For creating reports regarding AWS Workspaces.  
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


$workspaceinfo = aws workspaces describe-workspaces --no-verify-ssl| ConvertFrom-Json
#$workspacetime = aws workspaces describe-workspaces-connection-status | ConvertFrom-Json


$data = $workspaceinfo.Workspaces | select UserName, WorkspaceId, State, IpAddress, ComputerName | ft
#$data2 = $workspacetime.WorkspacesConnectionStatus | select WorkspaceId, @{Name="ConnectionStateCheckTimestamp"; Expression = {(Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($_.ConnectionStateCheckTimestamp))}}


$data | Out-File "$home\desktop\WorkspacesInfo.csv"