<#
GLOBALSCAPE 2024
USE ONLY AS DIRECTED
THIS SCRIPT DELETES AN EVENT RULE
MAKE CHANGES TO THE PARAMETERS BELOW INCLUDING: SITENAME, EVENTRULENAME, ETC
#>

#######################################################################
$siteName = 'MySite'
$eventRuleName = 'bugtest'

# for Authentication
$eftUser = 'Admin'
$eftPassword = 'Password'
$eftServer = '127.0.0.1'
$eftPort = '1100'

########################################################################
$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'

#connects using currently connected credentials change 1 to 0 to use EFT admin login
$EFT.ConnectEx($eftServer, $eftPort, 0, $eftUser, $eftPassword)

# retrieves Site Objects from EFT
$sites = $EFT.Sites()

# counts the number of sites
$numOfSites = $Sites.Count()

# loops through each site, checks if the name matches $siteName, if so it stores the ID value in $siteID
$siteID = ""
foreach ($siteNum in 1..$numOfSites) {
    $currentSite = $sites.SiteByID($siteNum)
    if ($currentSite.Name -eq $siteName)
        {$siteID = $currentSite.ID}
}

# sets the current site to match $siteName
$site = $Sites.SiteByID($siteID)

# gets each Available event rule type: FM, scheduled timer, etc
$eventRuleTypes = $EFT.AvailableEvents()

# begin loop through each event rule type
foreach($erType in $eventRuleTypes){

    # creates a list of all the event rules of the particular type: FM, scheduled timer, etc
    $eRules = $site.EventRules($erType.type)

    # if the event rule list is not empty, then continue
    if ($eRules.Count() -gt 0) {

    # begin loop through each event rule
    For ($iRule = 0; $iRule -lt $eRules.Count(); ++$iRule){

        # pulls individual event rule on list
        $objEvent = $eRules.Item($iRule)

        # gets individual event rule's parameters
        $params = $objEvent.GetParams()

        # if the name of the current event rule matches the $eventRuleName, then delete the event rule
        if ($params.Name -eq $eventRuleName)
            {$eRules.Delete($iRule)}
}}}

