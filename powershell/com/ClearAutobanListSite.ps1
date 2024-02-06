<#
Removes autoban entries from site
Uses currently logged on user to log into COM API
No need to specify EFT admin username or pw
Specify sitename below
#>
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

$banned_ips = $site.GetIPAccessRules().BannedIPs

Write-Host "Removing Autoban Entries from $($site.Name).." -ForegroundColor Gray
foreach ($banned_ip in $banned_ips){
    [string] $ip_address = $banned_ip.Address
    try{$site.UnbanIP($ip_address)
    Write-Host "Removed $ip_address" -ForegroundColor Green}
    catch{Write-Host "Error: $($_.Exception.Message) $ip_address was not removed" -ForegroundColor Red}}

Read-Host



