/*
Queries the EFT DB
Shows the number of files uploaded or downloaded by an event rule in a day
The list is in descending order so it shows the highest volume event rules first
You can also filter by hour
*/
SELECT
  DATEADD(DAY, DATEDIFF(DAY, 0, tbl_ClientOperations.Time_stamp), 0) AS DateDay,
  dbo.tbl_EventRules.EventName as EventName,
  COUNT(*) AS Transfers,
  SUM(dbo.tbl_ClientOperations.BytesTransferred) AS BytesTransferred
FROM
	dbo.tbl_ClientOperations
INNER JOIN 
	dbo.tbl_EventRules ON dbo.tbl_ClientOperations.TransactionID=dbo.tbl_EventRules.TransactionID
WHERE 
   CAST(dbo.tbl_ClientOperations.Time_stamp AS DATE) = '2025-06-01'
   -- uncomment below line to filter by hour
   -- and Cast (Time_stamp as time) between '19:00:00' and '20:00:00'
GROUP BY
  DATEADD(DAY, DATEDIFF(DAY, 0, dbo.tbl_ClientOperations.Time_stamp), 0),
  EventName
ORDER BY
  Transfers DESC,
  DateDay,
  EventName,
  BytesTransferred