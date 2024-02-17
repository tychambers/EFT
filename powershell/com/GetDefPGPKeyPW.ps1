<#
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

$default_pgpkey_id = $site.DefaultPGPKeyID
$default_pgpkey_pw = $site.DefaultPGPKeyPassphrase
$pgp_keys = $site.PGPKeys
foreach ($key in $pgp_keys){
    if ($key.ID -eq $default_pgpkey_id){
        Write-Output "$($key.Name) password is $default_pgpkey_pw"}}
