<#
Disables an event rule by name
Uses currently logged on user to log into COM API
No need to specify EFT admin username or pw
Specify event rule and site name below
#>
$rule_name = 'test'
$siteName = 'MySite'

########################################################################
$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'
#for EFT auth
#$eftUser = 'Admin'
#$eftPassword = 'alaska'
$eftServer = '127.0.0.1'
$eftPort = '1100'

#connects using currently connected credentials change 1 to 0 to use EFT admin login
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
foreach($ertype in $event_rule_types){
    $eRules = $site.EventRules($ertype.type)
    For ($iRule = 0; $iRule -lt $eRules.Count(); $iRule++){
    $objEvent = $eRules.Item($iRule)
    $params = $objEvent.GetParams()
    #Write-Output $params
    [string] $name = $params.Name
        if ($name -eq $rule_name){
        $params.Enabled = "false"
        $objEvent.SetParams($params)}}}

