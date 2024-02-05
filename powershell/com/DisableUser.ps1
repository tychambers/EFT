<#
Disables a user account
Uses currently logged on user to log into COM API
No need to specify EFT admin username or pw
Specify username below
#>
$username = 'bunnyfoofoo'

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

foreach ($site_number in 1..$num_of_sites){
        $site = $Sites.SiteByID($site_number)
        try{$site.EnableUsers($username, 0)
        Write-Host "$username has been disabled on $($site.Name)" -ForegroundColor Green}
        catch{Write-Host "Error: $($_.Exception.Message) on $($site.Name)" -ForegroundColor Red}}

Read-Host
