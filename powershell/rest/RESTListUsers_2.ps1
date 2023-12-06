#Generates a list of users on the site, provides more info than RESTListUsers.ps1

######################################################################################
#Directions:

#1. Input the following values (if site has REST SSL enabled change $baseurl to https):
$baseURL = "http://localhost:4450/admin"
$AdminUser = "Admin123"
$password = "Admin123!!!"
$site = "MySite"
#2. Copy/Paste this file to desktop
#3. Right click run with powershell
#4. Will export file to the desktop

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

foreach ($x in $siteList.data){
    if ($site -eq $x.attributes.name)
        {$id = $siteList.data.IndexOf($x)}}

$SiteID = $siteList.data[$id].id

$userList = Invoke-RestMethod -Uri "$baseURL/v2/sites/$SiteID/users" -Method 'GET' -Headers $authHeader


$exportData = foreach ($user in $userList.data){
    $user_id = $user.id
    $userCounter = Invoke-RestMethod -Uri "$baseURL/v2/sites/$SiteID/users/$user_id/counters" -Method 'GET' -Headers $authHeader
    [PSCustomObject]@{

        Username = $user.attributes.loginName
        Name = $user.attributes.personal.name
        Email = $user.attributes.personal.email
        AccountCreated = $userCounter.data.attributes.timeCreated
        Phone = $user.attributes.personal.phone
        HomeFolder = $user.attributes.homeFolder.value.path
        SettingsTemplate = $user.relationships.userTemplate.data.meta.name
        LastConnectionTime = $userCounter.data.attributes.timeLastConnected
        AccountLocked = $userCounter.data.attributes.isLocked
        TimePasswordChanged = $userCounter.data.attributes.timePasswordChanged}}

$exportData| Export-CSV $file_name -NoTypeInformation


