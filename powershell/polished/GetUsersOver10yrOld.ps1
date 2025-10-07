<#
.SYNOPSIS
    Checks if user account was created over 10 years ago, and exports the list of users to a csv

.DESCRIPTION
    This script goes through all of the user accounts on an EFT site and checks if the users were created over 10 years ago. If so,
    it will export the list of users or you can uncomment a line to delete the users. This is used to fix the error loading users issue with the Web Admin Portal
    Script exports CSV to same directory that the script is stored

.PARAMETER siteName
    Input the name of the EFT site, so that the script knows which site to find the users on.

.EXAMPLE
    PS> .\GetUsersOver10yrOld.ps1 -siteName "MySite"

.EXAMPLE EFTAuth
    PS> .\GetUsersOver10yrOld.ps1 -siteName "MySite" -EFTAuth 0 -eftUser "Admin" -eftPassword "password"

.NOTES
    Author: Tyler Chambers
    Date: October 2025
    Version: 1.0
    Tested on: Windows Server 2019, PowerShell 5.1
#>

param (
    [string]$siteName = "MySite",  # Default date
    [int]$EFTAUth = 1, # 1 for currently logged user in 0 for EFT Auth
    [string]$eftUser,
    [string]$eftPassword,
    [string]$eftServer = '127.0.0.1',
    [string]$eftPort = '1100'
)

$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'

#connects using currently connected credentials change 1 to 0 to use EFT admin login

try {
$EFT.ConnectEx($eftServer, $eftPort, $EFTAuth, $eftUser, $eftPassword)
} catch {
Write-Output "Failed to Connect to EFT Server"
}

$Sites = $EFT.Sites()
$num_of_sites = $Sites.Count()

#resolves site id by using site name
$site_id = ""
foreach ($x in 1..$num_of_sites)
{$site_loop = $Sites.SiteByID($x)
    if ($site_loop.Name -eq $siteName){
        $site_id = $x}}

$site = $Sites.SiteByID($site_id)

#gets users
$users = $site.GetUsers()

#Init empty results list
$Results = @()

#loops through users and exports a list of user accounts that were created over 10 years ago
foreach ($user in $users) {
    $userSettings = $site.GetUserSettings($user)
    $creationTime = $userSettings.AccountCreationTime

    # Convert to DateTime
    $date = [datetime]$creationTime

    # Get the date 10 years ago from today
    $tenYearsAgo = (Get-Date).AddYears(-10)

    # Compare
    if ($date -lt $tenYearsAgo) {
         $Results += [PSCustomObject]@{
            UserName  = $user
            CreationDate = $creationTime
            Enabled = $userSettings.GetEnableAccount()
        }
    }
}

$Path = Join-Path $PSScriptRoot "UserList.csv"

$Results | Export-Csv -Path $Path -NoTypeInformation
