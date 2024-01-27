<#
Copies an event rule from site to site_2
Make sure to specify https in URL if using SSL setting in REST
Sepcify values below specific to your environment
#>

######################################################################################

$baseURL = "http://localhost:4450/admin"
$AdminUser = "Admin123"
$password = "Admin123!!!"
$site = "MySite"
$site_2 = "MySite1"
$event_rule = "test3"

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

#resolves 2nd site ID by name

foreach ($x in $siteList.data){
    if ($site_2 -eq $x.attributes.name)
        {$id = $siteList.data.IndexOf($x)}}

$siteID2 = $siteList.data[$id].id

#gets list of event rules

$eventrules = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/event-rules" -Method 'GET' -Headers $authHeader

#resolves event rule ID by name
foreach ($event in $eventrules.data){
    if ($event_rule -eq $event.attributes.info.Name)
        {$id1 = $eventrules.data.IndexOf($event)}}

$eventruleid = $eventrules.data[$id1].id

#gets event rule update body from first site
$single_eventrule = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/event-rules/$eventruleid" -Method 'GET' -Headers $authHeader

$update = $single_eventrule

$update = $update
$update = $update | ConvertTo-Json -Depth 10

#posts event rule to second site
try{$post_eventrule = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID2/event-rules" -Method 'POST' -Headers $authHeader -Body $update}
catch{Write-Output "Encountered Error: $($_.Exception.Message)"}