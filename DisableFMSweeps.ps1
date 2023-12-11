#Generates a list of users on the site

######################################################################################
#Directions:

#1. Input the following values (if site has REST SSL enabled change $baseurl to https):
$baseURL = "http://localhost:4450/admin"
$AdminUser = "Admin123"
$password = "Admin123!!!"
$site = "MySite"
#2. Copy/Paste this file to desktop
#3. Right click run with powershell
#4. Will export text file to the desktop

#######################################################################################

#exports CSV to this location
$file_name = $site + "_ListUserInfo.csv"

# Only to ignore certificates errors
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;

        public class IDontCarePolicy : ICertificatePolicy {
        public IDontCarePolicy() {}
        public bool CheckValidationResult(
            ServicePoint sPoint, X509Certificate cert,
            WebRequest wRequest, int certProb) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = new-object IDontCarePolicy 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


# authentication
$authBody = "{""userName"": ""$AdminUser"", ""password"": ""$password"", ""authType"": ""EFT""}"
$auth = Invoke-RestMethod -Uri "$baseURL/v1/authentication" -Method 'POST' -Body $authBody

$authToken = $auth.authToken
$authHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$authHeader.Add("Authorization", "EFTAdminAuthToken $authToken")

#get site info
$siteList = Invoke-RestMethod -Uri "$baseURL/v2/sites" -Method 'GET' -Headers $authHeader

#resolves SiteID by Site Name
foreach ($x in $siteList.data){
    if ($site -eq $x.attributes.name)
        {$id = $siteList.data.IndexOf($x)}}

$siteID = $siteList.data[$id].id

#Gets user info
$ERList = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/event-rules" -Method 'GET' -Headers $authHeader
#Write-Output $ERList | ConvertTo-Json

$id_list = @()
foreach ($ER in $ERList.data){
    if ($ER.attributes.info.Type -eq "FolderMonitor")
        {$id_list += $ER.id}}
#Write-Output $ERList.data[1] | ConvertTo-Json

#Write-Output $id_list | ConvertTo-Json

#$ider = $id_list[0] | ConvertTo-Json
#Write-Output $ider

foreach ($id in $id_list)
{
$ER = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/event-rules/$id" -Method 'GET' -Headers $authHeader

$path = $ER.data.attributes.trigger.FolderMonitorParams.Path
$path2slash = $sStringToConvert = $path -replace '\\', '\\'
$update =
"{
    'data': {
        'type': 'eventRule',
        'attributes': {
            'trigger': {
                'FolderMonitorParams': {'Path': '$path2slash', 'SweepInterval': 21, 'UseFolderSweep': true}
            }
        }
    }
 }"

$update = $update | ConvertFrom-Json
$update = $update | ConvertTo-Json -Depth 10
$patchReturn = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/event-rules/$id" -Method 'PATCH' -Headers $authHeader -Body $update}