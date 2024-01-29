#run this command prior to install the PSSQLite module
#Install-Module PSSQLite -Verbose # requires you run as admin
Import-Module PSSQLite -Verbose

#input location of db file
$database = "C:\Users\tchambers\Desktop\fspath1\test\SiteConfig.14588b57-c646-4c02-91fa-8bee8074a4e8.db"
$database2 = "C:\Users\tchambers\Desktop\fspath1\test\SiteConfig.025cfafe-50a5-4736-9c1c-04a23c6b41a4.db"


$conn = New-SQLiteConnection -DataSource $database
$conn
$conn2 = New-SQLiteConnection -DataSource $database2

$client_table = Invoke-SqliteQuery -Query "SELECT * FROM SITE" -DataSource $database | Out-DataTable
Invoke-SQLiteBulkCopy -DataTable $client_table -SQLiteConnection $conn2 -Table Site

$conn.Close()
$conn2.Close()
