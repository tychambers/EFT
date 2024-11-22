SELECT
  DATEADD(DAY, DATEDIFF(DAY, 0, Time_stamp), 0) AS DateDay,
  UserName As Username,
  COUNT(*) AS logins,
  Protocol AS Protocol
FROM
  dbo.tbl_Authentications
WHERE 
   CAST(Time_stamp AS DATE) = '2024-09-18'
GROUP BY
  DATEADD(DAY, DATEDIFF(DAY, 0, Time_stamp), 0),
  UserName,
  Protocol
ORDER BY
  logins DESC,
  DateDay,
  Username