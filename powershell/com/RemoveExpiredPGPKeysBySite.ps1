## REMOVES EXPIRED PGP KEYS FROM SITE
## Script by default logs in with windows currently logged on user
## can be changed line 12 to use EFT auth
## 
## specify site name line 11 and other credentials line 7-10 if using EFT login

$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'
$eftUser = 'Admin'
$eftPassword = 'alaska'
$eftServer = '127.0.0.1'
$eftPort = '1100'
$siteName = 'MySite'

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

$PGP_keys = $site.PGPKeys

$date = Get-Date
$PGP_ID_list = @()
$PGP_Name_list = @()
$PGP_exp_list = @()
foreach ($key in $PGP_keys){
[string]$key_exp = $key.NeverExpires
    if ($key_exp -eq 'False')
        {if ($key.ExpirationDate -lt $date){
            $key_id = $key.ID
            try{$site.RemovePGPKey($key_id)}
            catch{Write-Output "Exception : $($_.Exception.Message)"}
            Write-Output "Removed $($key.Name) expired $($key.ExpirationDate)."}}}


