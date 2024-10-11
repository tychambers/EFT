######################################################################################

$baseURL = "http://localhost:4450/admin"
$AdminUser = "Admin123"
$password = "Admin123!!!"
$site = "MySite"

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

Write-Output $permissions.data | ConvertTo-Json

# Below is the link to the endpoint that will be used in the next request

Write-Output $permissions.data[0].links.self

# PATCH request to change the permissions for this particular user

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

$particular_permission = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/filesystem/folders/%2Fusr%2Fguest1%2F/permissions/user-4fbbd173-7db0-4a79-8095-716c2356391c" -Method 'PATCH' -Body $update -Headers $authHeader