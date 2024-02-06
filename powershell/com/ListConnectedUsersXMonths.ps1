<#
Gets info users connected over 6 months
Uses currently logged on user to log into COM API
No need to specify EFT admin username or pw
Specify time period and output path for csv file below
#>
$number_of_months = 6
$path_for_csv = "C:\Users\tchambers\Desktop\Scripts\Powershell\test\ConnectedUsers.csv"

########################################################################
$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'
#for EFT auth
#$eftUser = 'Admin'
#$eftPassword = 'alaska'
$eftServer = '127.0.0.1'
$eftPort = '1100'

#connects using currently connected credentials change 1 to 0 to use EFT admin login
$EFT.ConnectEx($eftServer, $eftPort, 1, $eftUser, $eftPassword)

#gets sites and number of sites
$Sites = $EFT.Sites()
$num_of_sites = $Sites.Count()

#gets todays date and date from 6 months ago
$today = get-date
$desired_date = $today.AddMonths(-$number_of_months)

#creates an empty list loops through each site
$empty_list = @()
foreach ($site_number in 1..$num_of_sites){
        $site = $Sites.SiteByID($site_number)

        #gets a list of users from each site and loops through each user
        $users = $site.GetUsers()
        foreach ($user in $users){

        #pulls data on each user
        $user_settings = $site.GetUserSettings($user)
        [datetime] $last_login = $site.GetUserSettings($user).LastConnectionTime
        $max_inactive_period = $user_settings.MaxInactivePeriod
        $islocked = $user_settings.IsLocked
        $isconnected = $user_settings.IsConnected

            #if user logged in within the last 6 months, it populates the empty list with data
            if ($last_login -gt $desired_date){
                $empty_list += "$user,$last_login,$($site.Name),$max_inactive_period,$islocked,$isconnected"}}}

#loops through each entry on the previously empty list, extracts data
$exportData = foreach ($entry in $empty_list){
    $entry_parse = $entry -split ","
    [string] $username = $entry_parse[0]
    [string] $last_connection = $entry_parse[1]
    [string] $site_name = $entry_parse[2]
    [string] $maxinacperiod = $entry_parse[3]
    [string] $locked = $entry_parse[4]
    [string] $connected = $entry_parse[5]
    #Arranges data into a format to be exported to csv
    [PSCustomObject]@{
        Username = $username
        LastConnection = $last_connection
        Site = $site_name
        MaxInactivePeriod = "$maxinacperiod days"
        AccountLocked = $locked
        CurrentlyConnected = $connected}}

#exports data to a csv using the path specified at the top
$exportData | Export-Csv -Path $path_for_csv -NoTypeInformation