#run this command prior to install the PSSQLite module
#Install-Module PSSQLite -Verbose # requires you run as admin
Import-Module PSSQLite -Verbose

#input location of db file
$database = "C:\Users\tchambers\Desktop\fspath1\SiteConfig.402cba8a-841a-4343-adfa-7d385bdaa8db.db"

#input query
$Query = "UPDATE Client SET Name = '3' WHERE Name = '1'"

$conn = New-SQLiteConnection -DataSource $database
$conn
Invoke-SqliteQuery -Query $Query -DataSource $database

$conn.close()

#displays output of the table
#Invoke-SqliteQuery -Query "SELECT * FROM CLIENT" -DataSource $database
