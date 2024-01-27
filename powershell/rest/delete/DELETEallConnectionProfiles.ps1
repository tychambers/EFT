<#
Deletes all connection profiles from a site
Make sure to specify https in URL if using SSL setting in REST
Sepcify values below specific to your environment
#>
######################################################################################

$baseURL = "http://localhost:4450/admin"
$AdminUser = "Admin123"
$password = "Admin123!!!"
$site = "MySite1"

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

#gets a list of connection profiles
$connectionprofiles = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/connection-Profiles" -Method 'GET' -Headers $authHeader

#deletes all connection profiles
foreach($cp in $connectionprofiles.data){

$cpid = $cp.id

$single_cp = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/connection-Profiles/$cpid" -Method 'DELETE' -Headers $authHeader
}