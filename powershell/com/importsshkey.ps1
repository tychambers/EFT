﻿<#
GLOBALSCAPE SUPPORT 2024
PURPOSE: PROVIDES AN EXAMPLE FOR HOW TO IMPORT AN SSH KEY
DIRECTIONS: ENTER SITE NAME AND KEY PATH BELOW, ENTER ADMIN USERNAME AND PASSWORD ALONG WITH CONNECTION INFO FOR AUTHENTICATION LINE 14-17

DISCLAIMER: PROVIDED AS-IS ANY TESTING WITH SCRIPT SHOULD BE DONE IN A DEV ENVIRONMENT
#>
$siteName = 'MySite'
$KeyFilePath = "mysitekey2.pub"

########################################################################
$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'
#for EFT auth
$eftUser = 'Admin123'
$eftPassword = 'Admin123!!!'
$eftServer = '127.0.0.1'
$eftPort = '1100'

#connects using currently connected credentials change 1 to 0 to use EFT admin login
$EFT.ConnectEx($eftServer, $eftPort, 0, $eftUser, $eftPassword)

$Sites = $EFT.Sites()
$num_of_sites = $Sites.Count()

#resolves site id by using site name
$site_id = ""
foreach ($x in 1..$num_of_sites)
{$site_loop = $Sites.SiteByID($x)
    if ($site_loop.Name -eq $siteName){
        $site_id = $x}}

$site = $Sites.SiteByID($site_id)

#import ssh key
$KeyName = [System.IO.Path]::GetFileName($KeyFilePath)
$KeyBlob = Get-Content $KeyName -Encoding Byte -Raw
$site.ImportSSHPublicKey($KeyName, $KeyBlob)
