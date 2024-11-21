<# 
Globalscape 2024 - Only Use as Directed
This script exports all disabled rules and then deletes them
Specify the variables below including: Site Name, path for the rules to be exported to,
Admin user name, Admin password, server and port
#>

#######################################################################
$siteName = 'MySite'
$exportPath = 'C:/ExportedRules/'

# for Authentication
$eftUser = 'Admin'
$eftPassword = 'Password'
$eftServer = '127.0.0.1'
$eftPort = '1100'

########################################################################
$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'

#connects using currently connected credentials change 1 to 0 to use EFT admin login
$EFT.ConnectEx($eftServer, $eftPort, 0, $eftUser, $eftPassword)

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
    if ($eRules.Count() -gt 0) {
    For ($iRule = 0; $iRule -lt $eRules.Count(); ++$iRule){
        $objEvent = $eRules.Item($iRule)
        $params = $objEvent.GetParams()
        if ($params.Enabled){}
        else {
            Write-host "Exporting: $($params.Name) ..." -ForegroundColor Green
            $objEvent.Export($exportPath + $params.Name + ".json")
            Write-host "Deleting $($params.Name) ..." -ForegroundColor Green
            $eRules.Delete($iRule)
            
            }}
}}

