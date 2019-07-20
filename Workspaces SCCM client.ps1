# This script will pull any "Available" workspace machine name and output if they are an 
# SCCM client. 
# Hopefully, you will then have the option to push the client to those machines.
#
# Be sure to have ran "AWS Configure" before attempting this script **AS DA!!!
#
#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# MUST RUN AS DA!!!! MUST RUN AS DA!!!!  MUST RUN AS DA!!!!


# Site configuration
$SiteCode = "XXXX" # Site code 
$ProviderMachineName = "XXXX.XXXX.XXXX.XXXX" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change anything below this line

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

##Done with SCCM Site info, now lets get to the script!
Write-host "`n`nThis script must be run as DA!!`n"
pause


$date = get-date -Format MMddyy-hhmmss 
$loglocation = "d:\temp\Workspaces_SCCM Clients_$date.csv"
$workspaceinfo = aws workspaces describe-workspaces --no-verify-ssl | ConvertFrom-Json
$machinelist = $workspaceinfo.Workspaces | select -ExpandProperty ComputerName 
$clientpush = New-Object System.Collections.ArrayList 

foreach ($machine in $machinelist) {
    $query = "SELECT * FROM SMS_CM_RES_COLL_SMS00001 WHERE Name = '$machine'"
    $client = Get-WMIObject -ComputerName $ProviderMachineName -Namespace root\SMS\Site_$SiteCode -Query "$query"
   
        if ( $client.IsClient -eq "TRUE" ) {
            "$machine is a client" | Out-File $loglocation -Append
            }
            else{
            "$machine is NOT a client" | Out-File $loglocation -Append
            $clientpush.add($machine)
            }
} #end foreach

"Would like to push the SCCM client to these workspaces:
$clientpush"
$push = Read-Host "Enter (y/n)"
    If ($push -eq "y") {
    "`nBEGINNING PUSH ATTEMPTS!!`n" | Out-File $loglocation -Append
    Foreach ($wsclient in $clientpush) {
        Install-CMClient -DeviceName $wsclient -SiteCode $SiteCode -AlwaysInstallClient $true -ForceReinstall $true -IncludeDomainController $false -Verbose
        "I tried to install on $wsclient" | Out-File $loglocation -Append
        }#end push foreach
    } #end if
else {
    "`nI didn't try to push nothin!" | Out-File $loglocation -Append
    } # end else