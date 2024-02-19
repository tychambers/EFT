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


$update = 
'{
 "data": {
 "id": "68fbe377-626e-4cde-88a1-b162f1ded18f",
 "attributes": {
 "name": "Test_admin",
 "password": "test",
 "adminConsolePermissions": {
 "accountPolicy": "server",
 "enableCom": true,
 "enableEditingAndReporting": true,
 "enablePersonalDataAccess": true
 },
 "restPermissions": {
 "enabled": true,
 "restAdminRole": true
 } 
 } 
 } 
}'

$update = $update | ConvertFrom-Json
$update = $update | ConvertTo-Json -Depth 10

$siteList2 = Invoke-RestMethod -Uri "$baseURL/v2/admin-users" -Method 'POST' -Headers $authHeader -Body $update