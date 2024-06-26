<#
PROPERTY OF GLOBALSCAPE SUPPORT 2024
ONLY USE UNDER DIRECT SUPERVISION OF SUPPORT
THIS SHOULD BE TESTED IN DEV ENVIRONMENT BEFORE PROD

Purpose:
This Script exports all event rules into an xml file for finding particular strings text in a text editor like notepad++
Can be used for finding event rules assigned to particular nodes, etc

Directions:
Edit the below lines to reflect your environment including site name, destination path for file, admin user name and password
#>

$siteName = 'MySite'
$destination_path_for_file = 'C:\Users\tchambers\Desktop\test\rules.xml'
$eftUser = 'Admin123'
$eftPassword = 'Admin123!!!'

########################################################################

$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'
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

#exports event rules
$site.ExportEventRules($destination_path_for_file)
