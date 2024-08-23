# Generate a report example

########################################################################
$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'
#for EFT auth
#$eftUser = 'Admin'
#$eftPassword = 'alaska'
$eftServer = '127.0.0.1'
$eftPort = '1100'

#connects using currently connected credentials change 1 to 0 to use EFT admin login
$EFT.ConnectEx($eftServer, $eftPort, 1, $eftUser, $eftPassword)

$reportactionparams = New-Object -ComObject 'SFTPComInterface.CIReportActionParams'
#14 is for today more info can be found on the kb https://hstechdocs.helpsystems.com/manuals/globalscape/gs_com_api/enum_reference.htm#PredefinedReportPeriod
$reportactionparams.CustomDate = 14
#PDF is 1 for report file format
$reportactionparams.ReportFileFormat = 1
#go through the available reports to find the one you are looking for and use that on line 33
$available_reports = $EFT.AvailableReports
$reportactionparams.Report = $available_reports[1]
#specificy the report params and the path you want the report below
$EFT.GenerateReport($reportactionparams, "C:\Users\tchambers\Desktop\aws test\report.pdf")
