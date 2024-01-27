<#
Copies all event rules from site to site_2
Seems to have issues copying event rules with certain triggers (on user disconnected, file uploaded, etc)
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

#get lists of event rules from first site
$eventrules = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/event-rules" -Method 'GET' -Headers $authHeader

#copies event rules to 2nd site
foreach ($event in $eventrules.data){
    $id = $event.id
    $single_eventrule = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/event-rules/$id" -Method 'GET' -Headers $authHeader
    $update = $single_eventrule

    $update = $update
    $update = $update | ConvertTo-Json -Depth 10

    try{$post_eventrule = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID2/event-rules" -Method 'POST' -Headers $authHeader -Body $update}
    catch{Write-Output "Encountered Error: $($_.Exception.Message)"}
    }
