<#
PROPERTY OF GLOBALSCAPE 2024
USE ONLY AS DIRECTED
CHANGES PASSWORD OF ADMIN USER SPECIFIED
INPUT YOUR CONNECTION SETTINGS BELOW INCLUDING ADMIN USERNAME, PASSWORD, EFT SERVER IP ADDRESS AND PORT
BELOW THAT INPUT THE SPECIFIED ADMIN USERNAME AND DESIRED PASSWORD #>

$eftUser = 'Admin123'
$eftPassword = 'Admin123!!!'
$eftServer = '127.0.0.1'
$eftPort = '1100'

#below is the name of the admin user whos password you want to change and the new password
$admin_user = 'test'
$new_pw = 'thisisthenewpassword'

########################################################################
$EFT = New-Object -ComObject 'SFTPComInterface.CIServer'

#connects using currently connected credentials change 1 to 0 to use EFT admin login
$EFT.ConnectEx($eftServer, $eftPort, 1, $eftUser, $eftPassword)

#changes admin password
$EFT.ChangeAdminPassword($admin_user, $new_pw)

Write-host "$admin_user's password has been changed" -ForegroundColor Green