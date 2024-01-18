## Script by default logs in with windows currently logged on user
## can be changed line 12 to use EFT auth
## tells you if pgp keys on a site are expired

$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'
$eftUser = 'Admin'
$eftPassword = 'alaska'
$eftServer = '127.0.0.1'
$eftPort = '1100'

#connects using currently connected credentials change 1 to 0 to use EFT admin login
$EFT.ConnectEx($eftServer, $eftPort, 1, $eftUser, $eftPassword)

$Sites = $EFT.Sites()
#Write-Output $Sites
$site = $Sites.SiteByID(1)
#Write-Output $site


#pulls expiration date for each key on site compares to todays date
$date = Get-Date
$PGP_keys = $site.PGPKeys
Write-Output = $PGP_keys
Write-Output "KEYS PAST EXPIRATION:"
foreach ($key in $PGP_keys){
    $expiration_date = $key.ExpirationDate
    if ($date -gt $expiration_date){Write-Output "`"$($key.Name)`" expired $expiration_date."}}

Write-Output "`nKEYS THAT DON'T EXPIRE:"
foreach ($key in $PGP_keys){
    $never_expire = $key.NeverExpires
    if ($never_expire -eq "True"){Write-Output "`"$($key.Name)`""}}

Read-Host

