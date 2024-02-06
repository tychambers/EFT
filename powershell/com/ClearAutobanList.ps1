<#
Removes permanently banned IP addresses from autoban list on all sites
Uses currently logged on user to log into COM API
#>

########################################################################
$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'
#for EFT auth uncommented line below and change line 15 from 1 to 0
#$eftUser = 'Admin'
#$eftPassword = 'alaska'
$eftServer = '127.0.0.1'
$eftPort = '1100'

#connect to server
$EFT.ConnectEx($eftServer, $eftPort, 1, $eftUser, $eftPassword)

#get list of sites and number of sites
$Sites = $EFT.Sites()
$num_of_sites = $Sites.Count()

#loops through sites
foreach ($site_number in 1..$num_of_sites){
        $site = $Sites.SiteByID($site_number)

        #gets a list of banned ips on the site
        $banned_ips = $site.GetIPAccessRules().BannedIPs

        #removes autoban list entries
        Write-Host "Removing Autoban Entries from $($site.Name).." -ForegroundColor Gray
        foreach ($banned_ip in $banned_ips){
            [string] $ip_address = $banned_ip.Address
            try{$site.UnbanIP($ip_address)
            Write-Host "Removed $ip_address" -ForegroundColor Green}
            catch{Write-Host "Error: $($_.Exception.Message) $ip_address was not removed" -ForegroundColor Red}}}

#keeps console up if running outside of powershell ISE
Read-Host



