/*
Queries the EFT DB
Counts the transaction types and frequency for a day
Change date under WHERE line
*/
SELECT
  DATEADD(DAY, DATEDIFF(DAY, 0, Time_stamp), 0) AS DateDay,
  TransactionObject As TransactionObject,
  COUNT(*) AS TransactionCount
FROM
  dbo.tbl_Transactions
WHERE 
   CAST(Time_stamp AS DATE) = '2025-04-23'
   -- uncomment below line to add hour
   -- and Cast (Time_stamp as time) between '19:00:00' and '20:00:00'
GROUP BY
  DATEADD(DAY, DATEDIFF(DAY, 0, Time_stamp), 0),
  TransactionObject
ORDER BY
  TransactionCount DESC,
  DateDay
