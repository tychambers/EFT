<#
Copy all connection profiles from site to site
Note: may send a bad request if keys are only available on the other site
Make sure to specify https in URL if using SSL setting in REST
Sepcify values below specific to your environment
#>
######################################################################################

$baseURL = "http://localhost:4450/admin"
$AdminUser = "Admin123"
$password = "Admin123!!!"
$site = "MySite"
$site_2 = "MySite1"

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

#resolves 2nd SiteID by Site Name
foreach ($x in $siteList.data){
    if ($site_2 -eq $x.attributes.name)
        {$id = $siteList.data.IndexOf($x)}}

$siteID2 = $siteList.data[$id].id

#Retrieves list of users from site1
$connection_profile_list = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/connection-Profiles" -Method 'GET' -Headers $authHeader

#Posts connection profiles from site1 to site2
foreach ($cp in $connection_profile_list.data){
    $id = $cp.id
    $get_connection_profile = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/connection-Profiles/$id" -Method 'GET' -Headers $authHeader
    $update = $get_connection_profile
    $update = $update | ConvertTo-Json -Depth 10

    try{$post_cp = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID2/connection-Profiles" -Method 'POST' -Headers $authHeader -Body $update}
    catch{Write-Output "Encountered Error: $($_.Exception.Message)"}
    }