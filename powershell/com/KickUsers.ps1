<#
kicks all users from all sites
Uses currently logged on user to log into COM API
No need to specify EFT admin username or pw
#>

########################################################################
$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'
#for EFT auth
#$eftUser = 'Admin'
#$eftPassword = 'alaska'
$eftServer = '127.0.0.1'
$eftPort = '1100'

#connects using currently connected credentials change 1 to 0 to use EFT admin login
$EFT.ConnectEx($eftServer, $eftPort, 1, $eftUser, $eftPassword)

#gets sites and number of sites
$Sites = $EFT.Sites()
$num_of_sites = $Sites.Count()

#loops through each site, kicks all users
foreach ($site_number in 1..$num_of_sites){
        $site = $Sites.SiteByID($site_number)

        #gets a list of connected users
        $connected_users = $site.ConnectedUsers

        #loops through list of connected users, gets there connection id number and uses this to kick them
        foreach ($connected_user in $connected_users){
            $connected_user_id = $connected_user.ID
            $site.KickUser($connected_user_id) >> Null
            Write-Host "Kicking $($connected_user.Login)" -ForegroundColor Red}

        Start-Sleep 10

        #checks to see if users are still connected
        $connected_users_check = $site.ConnectedUsers
        if ($connected_users_check.Count -eq 0){
            Write-Host "All Users have been kicked from $($site.Name)" -ForegroundColor Green}
        else {Write-Host "There are still $($connected_users_check.Count) users connected" -ForegroundColor Red}}



Read-Host