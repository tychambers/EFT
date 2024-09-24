######################################################################################

$baseURL = "http://10.0.1.11:4450/admin"
$AdminUser = "Admin123"
$password = "Admin123!!!"
$site = "MySite"
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

$siteID = $siteList.data[$id].id

#Write-Output $siteID

$userList = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/users" -Method 'GET' -Headers $authHeader


$new_ssh_keys = $userList.data[0].relationships.sshKeys.data
$userList.data[1].relationships.sshKeys.data = $new_ssh_keys

Write-Output $userList.data[1].attributes.loginName

$update = '{
  "data": {
    "type": "user",
    "relationships": {
      "sshKeys": {
        "data": [
                 {
                     "id":  "522b13fa-9a6e-4597-bfb4-9e92308b5f68",
                     "type":  "SSHKey"
                 }
             ]
      }
  }
}
}'


$user_id = $userList.data[2].id

$update = $update | ConvertFrom-Json
$update = $update | ConvertTo-Json -Depth 10

$patch = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/users/$user_id" -Method 'PATCH' -Body $update -Headers $authHeader

Write-Output $patch