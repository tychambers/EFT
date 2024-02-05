<#
Disables all sweeps and subfolders for each folder monitor rule on a site
Uses currently logged on user to log into COM API
No need to specify EFT admin username or pw
Specify site name below
#>
$siteName = 'MySite'
$eftServer = '127.0.0.1'
$eftPort = '1100'

########################################################################
$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'

#for EFT auth specify following:
#$eftUser = 'Admin'
#$eftPassword = 'alaska'
#connects using currently connected credentials change 1 to 0 below to use EFT admin login
$EFT.ConnectEx($eftServer, $eftPort, 1, $eftUser, $eftPassword)

$Sites = $EFT.Sites()
$num_of_sites = $Sites.Count()

#resolves site id by using site name
$site_id = ""
foreach ($x in 1..$num_of_sites)
{$site_loop = $Sites.SiteByID($x)
    if ($site_loop.Name -eq $siteName){
        $site_id = $x}}

$site = $Sites.SiteByID($site_id)

$event_rule_types = $EFT.AvailableEvents()
$folder_monitor = $event_rule_types[4]
$FM_rules = $site.EventRules($folder_monitor.type)
For ($iRule = 0; $iRule -lt $FM_rules.Count(); $iRule++){
    $objEvent = $FM_rules.Item($iRule)
    $params = $objEvent.GetParams()
    $params.IncludeSubfolders = "false"
    $params.UsePeriodicDirectoryPoll = "false"
    try{$objEvent.SetParams($params)
    Write-Output "Sweeps and SubFolders have been disabled for $($params.Name) on $($site.Name)"}
    catch{Write-Output "Unable to disable sweeps and subfolders for $($params.Name)"}}

Read-Host


