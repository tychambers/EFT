#disable event rule

######################################################################################

$baseURL = "http://localhost:4450/admin"
$AdminUser = "Admin123"
$password = "Admin123!!!"
$site = "MySite"
$event_rule = "rulename"

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

$eventrules = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/event-rules" -Method 'GET' -Headers $authHeader

#uses event rule name to get id
foreach ($event in $eventrules.data){
    if ($event_rule -eq $event.attributes.info.Name)
        {$id1 = $eventrules.data.IndexOf($event)}}

$eventruleid = $eventrules.data[$id1].id

#patch body to disable rule
$update =
'{
    "data": {
        "type": "eventRule",
        "attributes": {
            "info": {
                                    "Enabled":  false
            }
        }
    }
 }'
$update = $update | ConvertFrom-Json
$update = $update | ConvertTo-Json -Depth 10
$patch = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/event-rules/$eventruleid" -Method 'PATCH' -Headers $authHeader -Body $update