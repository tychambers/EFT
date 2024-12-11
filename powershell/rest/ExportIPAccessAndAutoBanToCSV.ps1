<#
GLOBALSCAPE SUPPORT 2024
Use only as directed
Edit the fields below to match you environment including: url, admin username, password, site, path to file
This script exports the IPAccess List and Autoban List to 2 seperate CSVs in the same directory
*This is a REST script if using SSL specify HTTPS in the connection string
#>
######################################################################################

$baseURL = "http://localhost:4450/admin"
$AdminUser = "Admin"
$password = "Password"
$site = "MySite"
$filePath = "C:/path/to/file/"

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

#get autoban list from site
$autobanList = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/ipAutoBanList" -Method 'GET' -Headers $authHeader

#Create a CSV of Banned IP Addresses
$number = 0
$exportAutoBanData = foreach ($entry in $autobanList.data){
    $number += 1
    [PSCustomObject]@{
        EntryNumber = $number
        IPAddress = $entry.id}}

$exportAutoBanData | Export-CSV "$filePath/AutoBanList.csv" -NoTypeInformation

$ipAccessList = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/ipAccessList" -Method 'GET' -Headers $authHeader

$exportAccessListData = foreach ($entry in $ipAccessList.data) {
    [PSCustomObject]@{
        IPAddress = $entry.id
        AllowDeny = $entry.attributes.accessType
        Reason = $entry.attributes.reason
        DateOfBan = $entry.attributes.date}}

$exportAccessListData | Export-CSV "$filePath/AccessList.csv" -NoTypeInformation