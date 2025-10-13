<#
.SYNOPSIS
    Example PowerShell template for interacting with Globalscape EFT REST API.

.DESCRIPTION
    This script provides a reusable starting point for building PowerShell scripts
    that authenticate to an EFT server and perform API operations.
    It demonstrates:
      - How to authenticate using credentials
      - How to retrieve site information
      - How to use REST API endpoints with authentication headers

.PARAMETER baseURL
    The base URL of the EFT REST API endpoint.
    Example: https://localhost:4450/admin

.PARAMETER AdminUser
    The EFT administrative username used for authentication.

.PARAMETER password
    The EFT administrative password used for authentication.

.PARAMETER siteName
    The name of the site to retrieve details for.

.OUTPUTS
    JSON-formatted site information retrieved from the EFT REST API.

.EXAMPLE
    PS> .\Get-EFTSiteInfo.ps1 -baseURL "https://eftserver.domain.com:4450/admin" `
                              -AdminUser "Admin123" `
                              -password "P@ssword123!" `
                              -siteName "CorporateSite"
    
    Retrieves site information for the EFT site named "CorporateSite".

.NOTES
    File Name  : Get-EFTSiteInfo.ps1
    Author     : Tyler Chambers
    Created On : October 2025
    Version    : 1.0
    Purpose    : Template for future EFT API automation scripts
    Requires   : PowerShell 5.1 or later, REST API access to EFT server
#>

param(
    [string]$baseURL = "https://localhost:4450/admin",
    [string]$AdminUser = "Admin123",
    [string]$password = "Admin123!!!",
    [string]$siteName = "MySite"
)

# authentication
$authBody = "{""userName"": ""$AdminUser"", ""password"": ""$password"", ""authType"": ""EFT""}"
$auth = Invoke-RestMethod -Uri "$baseURL/v1/authentication" -Method 'POST' -Body $authBody

$authToken = $auth.authToken
$authHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$authHeader.Add("Authorization", "EFTAdminAuthToken $authToken")

# get sites
$siteList = Invoke-RestMethod -Uri "$baseURL/v2/sites" -Method 'GET' -Headers $authHeader

$siteId = ""
foreach ($site in $siteList.data) {
    if ($site.attributes.name -eq $siteName) {
        $siteId = $site.id
    }
}

$siteInfo = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteId" -Method 'GET' -Headers $authHeader

Write-Output $siteInfo.data | ConvertTo-Json


