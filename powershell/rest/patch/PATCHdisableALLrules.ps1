#disables all rules


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

#Gets all event rules
$ERList = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/event-rules" -Method 'GET' -Headers $authHeader

#loops through all rules, gets id and then disables
foreach ($er in $ERList.data){
$erid = $er.id
$ername = $er.attributes.info.Name

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
#handles errors for already disabled rules
try {
$patch = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/event-rules/$erid" -Method 'PATCH' -Headers $authHeader -Body $update
}
catch{
Write-Output "`"$ername`" already disabled"}
}
Write-Output "All Rules Disabled"

Read-Host