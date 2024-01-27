﻿<#
Copy a connection profile from site to site
Make sure to specify https in URL if using SSL setting in REST
Sepcify values below specific to your environment
#>
######################################################################################

$baseURL = "http://localhost:4450/admin"
$AdminUser = "Admin123"
$password = "Admin123!!!"
$site = "MySite"
$site_2 = "MySite1"
$connection_profile_name = "test"

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

#Retrieves list of users from site1
$connection_profile_list = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/connection-Profiles" -Method 'GET' -Headers $authHeader

#resolves connection profile ID based on name
foreach ($connection_profile in $connection_profile_list.data){
    if ($connection_profile_name -eq $connection_profile.attributes.name)
        {$id1 = $connection_profile_list.data.IndexOf($connection_profile)}}

$cpID = $connection_profile_list.data[$id1].id

#gets connection profile
$get_connection_profile = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/connection-Profiles/$cpID" -Method 'GET' -Headers $authHeader

#formats update body and posts to site 2
$update = $get_connection_profile
$update = $update | ConvertTo-Json -Depth 10

$post_connection_profile = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID2/connection-Profiles" -Method 'POST' -Headers $authHeader -Body $update