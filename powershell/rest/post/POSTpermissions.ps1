<#
This script adds permissions for a user to a folder
put in the variables below to match your environment
#>

$baseURL = "http://localhost:4450/admin"
$AdminUser = "Admin123"
$password = "Admin123!!!"
$site = "MySite"
$username = "test4"
$folder = "/usr/test1"

#######################################################################################

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

# Get a list of users

$userList = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/users" -Method 'GET' -Headers $authHeader

# Loops through users if username matches the one provided it saves the user id in $user_id, this is going to be used later for the POST request
foreach ($user in $userList.data) {
    if ($user.attributes.loginName -eq $username) {
        $user_id = $user.id } }

# Below is the POST body to add permissions for the user


$update = 
"{ 
 'data': 
 { 
 'type': 'folderPermissions', 
 'attributes': {
 'canAppendFile': true, 
 'canCreateSubfolder': true, 
 'canDeleteFile': true, 
 'canDeleteSubfolder': true, 
 'canDownloadFile': true, 
 'canList': true, 
 'canRenameFileOrSubfolder': true, 
 'canSeeHiddenFileOrSubfolder': true, 
 'canSeeInParentList': true, 
 'canSeeReadOnlyFileOrSubfolder': true, 
 'canUploadFile': false
 },
 'relationships': {
 'trustee': {
 'data': {
 'type': 'user', 
 'id': '$user_id', 
 'meta': {
 'name': '$username'
 } 
 } 
 } 
 } 
 } 
 }"
$update = $update | ConvertFrom-Json
$update = $update | ConvertTo-Json -Depth 30

# changes folder variable at the top into the right format for the request


$new_path = $folder -split "/"
$newest_path = ""
foreach ($item in $new_path) {
    $newest_path += "%2F" + $item }
$newest_path += "%2F"
$newest_path = $newest_path.Substring(3)

# Adds permissions to /usr/test1

$particular_permission = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/filesystem/folders/$newest_path/permissions" -Method 'POST' -Body $update -Headers $authHeader