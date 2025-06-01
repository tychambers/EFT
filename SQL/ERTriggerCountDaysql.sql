/*
Queries the EFT DB
Shows the Event Rules that triggered the most frequently during a day
Change date under WHERE line
*/
SELECT
  DATEADD(DAY, DATEDIFF(DAY, 0, Time_stamp), 0) AS DateDay,
  EventName As EventName,
  COUNT(*) AS TriggerCount
FROM
  dbo.tbl_EventRules
WHERE 
   CAST(Time_stamp AS DATE) = '2025-04-17'
GROUP BY
  DATEADD(DAY, DATEDIFF(DAY, 0, Time_stamp), 0),
  EventName
ORDER BY
  TriggerCount DESC,
  DateDay