<#COPYRIGHT GLOBALSCAPE 2024
PROVIDED AS AN EXAMPLE OF REST API FUNCTIONALITY
PURPOSE: To remove admin user and create the same user with a different password
INSTRUCTIONS: Specify information in lines below including baseurl, admin username for login and password
specify the desired name of the admin user to delete in admin_name and the new password in admin_pw
if your rest api is using SSL change http to https #>

######################################################################################

$baseURL = "http://localhost:4450/admin"
$AdminUser = "Admin123"
$password = "Admin123!!!"
$admin_name = "Test"
$admin_pw = "Test123!!!"

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

#Does a get reuqest to find the users ID
$admin_users = Invoke-RestMethod -Uri "$baseURL/v2/admin-users" -Method 'GET' -Headers $authHeader

#Find the user id of the specified username at the top
foreach ($admin_user in $admin_users.data){
    [string ] $admin_user_name = $admin_user.attributes.name
    If ($admin_user_name -eq $admin_name){
        $id = $admin_user.id}}

#deletes the admin user
$admin = Invoke-RestMethod -Uri "$baseURL/v2/admin-users/$id" -Method 'DELETE' -Headers $authHeader

#creates the admin user with a new username
$update = 
"{
 'data': {
     'id': '$id',
     'attributes': {
        'name': '$admin_name',
        'password': '$admin_pw',
     'adminConsolePermissions': {
     'accountPolicy': 'server',
     'enableCom': true,
     'enableEditingAndReporting': true,
     'enablePersonalDataAccess': true
     },
     'restPermissions': {
     'enabled': true,
     'restAdminRole': true
 } 
 } 
 } 
}"

$update = $update | ConvertFrom-Json
$update = $update | ConvertTo-Json -Depth 10

$siteList2 = Invoke-RestMethod -Uri "$baseURL/v2/admin-users" -Method 'POST' -Headers $authHeader -Body $update