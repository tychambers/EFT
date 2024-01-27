<#
Copies all AWE tasks from site to site
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

#gets a list of all awe tasks from site1
$aweList = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/awe-tasks" -Method 'GET' -Headers $authHeader

#copies the awe tasks from site1 to site2
foreach($awe in $aweList.data){
$awe_id = $awe.id
$aweTask = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/awe-tasks/$awe_id" -Method 'GET' -Headers $authHeader
$update = $aweTask
$update = $update | ConvertTo-Json -Depth 10
try{$post_awe = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID2/awe-tasks" -Method 'POST' -Headers $authHeader -Body $update}
catch{Write-Output "Encountered Error: $($_.Exception.Message)"}}