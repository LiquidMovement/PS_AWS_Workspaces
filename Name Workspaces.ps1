#########
## For setting Active Directory Computer Description to make workspace identificatiopn easier
##
## Be sure to have ran "AWS Configure" before attempting this script
## Must run "Workspaces-Start-All.ps1 for this to be fully successful
##
##


$date = get-date -Format MMddyy-hhmmss
$workspaceinfo = aws workspaces describe-workspaces --no-verify-ssl | ConvertFrom-Json
$userlist = $workspaceinfo.Workspaces #| select -ExpandProperty UserName

Foreach ($user in $userlist) {
    $machine = $user | select -ExpandProperty ComputerName
    $username = $user | select -ExpandProperty UserName
    "$username - $machine" | Out-File .\workspace-user-comps$date.txt -Append
    $addesc = Get-ADComputer -Identity $machine -Properties description | select -ExpandProperty description
    If ($addesc -eq $username) {
        Write-Host "$machine description matches, doing nothing"
        "$machine description matches, doing nothing" | Out-File .\workspace-machines_named$date.txt -Append
    } #endif
    else {
    Set-ADComputer -Identity $machine -Description $username
    "$machine description was set to $username" | Out-File .\workspace-machines_named$date.txt -Append
    } #else
}# end foreach