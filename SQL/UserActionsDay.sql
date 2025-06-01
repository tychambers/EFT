/*
Queries the Protocol Commands table from EFT DB
Shows the sum of the number of actions performed by a user. Including:
Uploads, downloads, deletes, quit/kicks etc.
Can filter by day and also by hour. Shows total bytes transferred for the time period.
*/
SELECT
  DATEADD(DAY, DATEDIFF(DAY, 0, Time_stamp), 0) AS DateDay,
  Actor AS UserName,
  COUNT(*) AS ClientActions,
  SUM(BytesTransferred) AS BytesTransferred
FROM
	dbo.tbl_ProtocolCommands
WHERE 
   CAST(Time_stamp AS DATE) = '2025-06-01'
   -- uncomment below line to filter by hourAdd commentMore actions
   -- and Cast (Time_stamp as time) between '14:00:00' and '15:00:00'
GROUP BY
  DATEADD(DAY, DATEDIFF(DAY, 0, Time_stamp), 0),
  Actor
ORDER BY
  ClientActions DESC,
  DateDay