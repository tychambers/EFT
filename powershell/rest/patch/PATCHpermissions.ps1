<#
PATCH request to change an existing permission on a user folder
specify values below to match your environment
#>

#﻿######################################################################################

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

# Below line is the endpoint to get permissions for an individual folder /usr/guest1

$permissions = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/filesystem/folders/%2Fusr%2Fguest1%2F/permissions" -Method 'GET' -Headers $authHeader

# Note there has to be permissions added beyond the default for this to show up
# Below will output all of the permissions as a list/array

# Write-Output $permissions.data | ConvertTo-Json

# below loops through the permissions and picks the permissions for the username specified at the top, it then stores the link for this permission
# we will use the link later in the PATCH request

foreach ($permission in $permissions.data) {
    if ($permission.relationships.trustee.data.meta.name -eq $username) {
         $link = $permission.links.self } }

# update body for PATCH request specified below, if you want to change the permissions value it can be done here

$update = '{
 "data": {
 "type": "folderPermissions",
 "attributes": {
 "canUploadFile": false,
 "canDownloadFile": false,
 "canDeleteFile": false,
 "canRenameFileOrSubfolder": true,
 "canAppendFile": true, 
 "canDeleteSubfolder": false,
 "canCreateSubfolder": true,
 "canSeeHiddenFileOrSubfolder": true,
 "canSeeReadOnlyFileOrSubfolder": true,
 "canSeeInParentList": true, "canList": true
 } } 
}'
$update = $update | ConvertFrom-Json
$update = $update | ConvertTo-Json -Depth 30

# Link parse to get the id for patch request
$list = $link -split "/"
$permission_id = $list[9]

# changes folder to put in right format for the request
$new_path = $folder -split "/"
$newest_path = ""
foreach ($item in $new_path) {
    $newest_path += "%2F" + $item }
$newest_path += "%2F"
$newest_path = $newest_path.Substring(3)

$particular_permission = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/filesystem/folders/$newest_path/permissions/$permission_id" -Method 'PATCH' -Body $update -Headers $authHeader


