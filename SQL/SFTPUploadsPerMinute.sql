SELECT 
   DATEADD(MINUTE, DATEDIFF(MINUTE, 0, Time_stamp), 0) AS RoundedTime,
   COUNT(*) AS SFTPUpload
FROM 
   dbo.tbl_ProtocolCommands
WHERE 
   CAST(Time_stamp AS DATE) = '2024-10-07'
   AND Protocol = 'SFTP'
   AND Command = 'stor'
GROUP BY 
   DATEADD(MINUTE, DATEDIFF(MINUTE, 0, Time_stamp), 0)
ORDER BY 
   RoundedTime;