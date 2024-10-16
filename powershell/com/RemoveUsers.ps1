# Remove users from a site if the name does not contain X
# Change X below

$siteName = 'ft.visionsfcu.org'
$x = "@"

########################################################################
$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'
#for EFT auth
#$eftUser = 'Admin'
#$eftPassword = 'alaska'
$eftServer = '127.0.0.1'
$eftPort = '1100'

$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'

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

$user_list = $site.GetUsers()

foreach ($user in $user_list) {
    if ($user.contains($x)) {
        Write-Output("Saving this user: $user") }
    else {
        $site.RemoveUser($user)}}
