#Right click file, Run with Powershell
Write-Output " _______                             _                _______                ______  
(_______)                           | |              (_______)              (_____ \ 
 _______ ____  ____  _____ ____   __| |_____  ____    _   ___ _____ ____     _____) )
|  ___  |  _ \|  _ \| ___ |  _ \ / _  | ___ |/ ___)  | | (_  | ___ |  _ \   (_____ ( 
| |   | | |_| | |_| | ____| | | ( (_| | ____| |      | |___) | ____| | | |   _____) )
|_|   |_|  __/|  __/|_____)_| |_|\____|_____)_|       \_____/|_____)_| |_|  (______/ 
        |_|   |_|" 
 Write-Output "`n`n`n© Globalscape 2023`n`n"
$logger_name = Read-Host -Prompt "Logger name"
$appender_name = Read-Host -Prompt "Appender name"
$log_settings = Read-Host -Prompt "Logging.cfg entries(Events,Events.Clustered,HTTP) *Case Sensitive NO space after comma!*"
$logging_level = Read-Host -Prompt "Log Level (TRACE, INFO, etc)"


$an = $appender_name.ToLower()
$ll = $logging_level.ToUpper()
$pre_str = "log4cplus.appender.$an"

$L1 = "$pre_str=log4cplus::RollingFileAppender"
$L2 = "$pre_str.File=$`{AppDataPath}\EFT-$logger_name.log"
$L3 = "$pre_str.MaxFileSize=20MB"
$L4 = "$pre_str.MaxBackupIndex=5"
$L5 = "$pre_str.layout=log4cplus::TTCCLayout"
$L6 = "$pre_str.layout.DateFormat=%m-%d-%y %H:%M:%S,%q"
$L7 = ""
$L8 = ""

if ($log_settings.Contains(",")){
    $log_settings_list = $log_settings.split(",")
    foreach ($log in $log_settings_list)
        {$L7 += "log4cplus.additivity.$log=false`n"
        $L8 += "log4cplus.logger.$log=$ll, $an`n"}} else {
    $L7 = "log4cplus.additivity.$log_settings=false`n"
    $L8 = "log4cplus.logger.$log_settings=$ll, $an`n"}

$Appender = $L1, $L2, $L3, $L4, $L5, $L6, $L7, $L8

#Uncomment line below to write appender to a text file in the same directory as script
#$Appender | Out-File -FilePath appender.txt

Write-Output "`nCopy and Paste into logging.cfg:`n`n" $Appender

Read-Host
