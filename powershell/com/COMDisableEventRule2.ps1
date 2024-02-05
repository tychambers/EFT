<#
Disables an event rule by name
Checks all sites
Uses currently logged on user to log into COM API
No need to specify EFT admin username or pw
#>
$rule_name = 'test'
$eftServer = '127.0.0.1'
$eftPort = '1100'

########################################################################
$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'
#for EFT auth
#$eftUser = 'Admin'
#$eftPassword = 'alaska'


#connects using currently connected credentials change 1 to 0 to use EFT admin login
$EFT.ConnectEx($eftServer, $eftPort, 1, $eftUser, $eftPassword)

$Sites = $EFT.Sites()
$num_of_sites = $Sites.Count()
$event_rule_types = $EFT.AvailableEvents()


foreach ($event_rule_type in $event_rule_types){
    foreach ($site_number in 1..$num_of_sites){
        $Site = $Sites.SiteByID($site_number)
        $eRules = $site.EventRules($event_rule_type.type)
            For ($iRule = 0; $iRule -lt $eRules.Count(); $iRule++){
            $objEvent = $eRules.Item($iRule)
            $params = $objEvent.GetParams()
            #Write-Output $params
            [string] $name = $params.Name
                if ($name -eq $rule_name){
                $params.Enabled = "false"
                Write-Output $params
                $objEvent.SetParams($params)}}}}