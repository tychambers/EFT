<# 
Globalscape Support 2024
Use only as directed
The following script exports a csv with the name of each enabled event rule on the site.
The csv has both a Event Rule Name column and a site name column.
Make changes to the box below to match your environment, including:
path, Admin Username, password, port, IP, etc.
This script uses COM API and is intended to be run locally on the server where EFT is installed.
#>


#######################################################################
# enter path where you would like the csv export below
$pathForCsv = 'C:\path\to\folder\EnabledEventRules.csv'

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

# finds the enabled event rules on each site
$enabled_rules = @()
foreach ($site_number in 1..$num_of_sites) {
    $site = $Sites.SiteByID($site_number)
    $event_rule_types = $EFT.AvailableEvents()
    foreach($ertype in $event_rule_types){
        $eRules = $site.EventRules($ertype.type)
        if ($eRules.Count() -gt 0) {
        For ($iRule = 0; $iRule -lt $eRules.Count(); ++$iRule){
            $objEvent = $eRules.Item($iRule)
            $params = $objEvent.GetParams()
            if ($params.Enabled){
                $enabled_rules += @{EventRuleName = $params.Name; SiteName = $Site.Name}}}
    }}}

# exports the enabled event rules name and the site name to a csv
$exportData = foreach ($rule in $enabled_rules){
    [PSCustomObject]@{
        RuleName = $rule.EventRuleName
        SiteName = $rule.SiteName
         }}

$exportData | Export-CSV -Path $pathForCsv -NoTypeInformation

