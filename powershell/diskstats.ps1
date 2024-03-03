$disk_list = Get-Disk

$exportData = foreach ($disk in $disk_list){
    [PSCustomObject]@{
        FriendlyName = $disk.FriendlyName
        ServerName = $disk.CimSystemProperties.ServerName
        SizeGb = [math]::Round($($disk.Size) /1Gb, 2)
        OperationalStatus = $disk.OperationalStatus
        OfflineReason = $disk.OfflineReason
        HealthStatus = $disk.HealthStatus
        Manufacturer = $disk.Manufacturer
        Model = $disk.Model
        SerialNumber = $disk.SerialNumber
        BusType = $disk.BusType
        Path = $disk.Path
        CimClass = $disk.CimClass
        Signature = $disk.Signature
        }}

$exportData | Export-CSV -Path .\disk_stats.csv -NoTypeInformation