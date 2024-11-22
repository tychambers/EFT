SELECT 
   DATEADD(HOUR, DATEDIFF(HOUR, 0, Time_stamp), 0) AS RoundedTime,
   COUNT(*) AS Authentications
FROM 
   dbo.tbl_Authentications
WHERE 
   CAST(Time_stamp AS DATE) = '2024-05-16'
GROUP BY 
   DATEADD(HOUR, DATEDIFF(HOUR, 0, Time_stamp), 0)
ORDER BY 
   RoundedTime;