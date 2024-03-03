$drive_list = Get-PSDrive

$filtered_list = @()
foreach ($drive in $drive_list){
    if ($drive.Free -gt 0){
        $filtered_list += $drive}}

$exportData = foreach ($entry in $filtered_list){
    [PSCustomObject]@{
        Name = $entry.Name
        FreeSpaceGb = [math]::Round($($entry.Free) /1Gb, 2)
        UsedSpaceGb = [math]::Round($($entry.Used) /1Gb, 2)
        TotalSpaceGb = [math]::Round(($($entry.Free) + $($entry.Used)) /1Gb, 2)
        Root = $entry.Root
        Provider = $entry.Provider
        UsernameCred = $entry.Credential.UserName
        PasswordCred = $entry.Credential.Password
        CurrentLocation = $entry.CurrentLocation
        MaxSize = $entry.MaximumSize
        DisplayRoot = $entry.DisplayRoot
        }}

$exportData | Export-CSV -Path .\storage_stats.csv -NoTypeInformation