#Get User

######################################################################################

$baseURL = "http://localhost:4450/admin"
$AdminUser = "Admin123"
$password = "Admin123!!!"
$site = "testsite"
$username = "user1"

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

$userList = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/users" -Method 'GET' -Headers $authHeader

#Write-Output $userList.data | ConvertTo-Json
Write-Output $userList.data[0].attributes.loginName | ConvertTo-Json

foreach ($user in $userList.data){
    if ($username -eq $user.attributes.loginName)
        {$id1 = $userList.data.IndexOf($user)}}

$userID = $userList.data[$id1].id

$userget = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/users/$userID" -Method 'GET' -Headers $authHeader

Write-Output $userget.data | ConvertTo-Json
