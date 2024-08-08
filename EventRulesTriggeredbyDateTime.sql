SELECT [EventID]
      ,[Time_stamp]
      ,[SiteName]
      ,[EventName]
      ,[EventType]
      ,[ConditionValues]
      ,[TransactionID]
      ,[EventGUID]
  FROM [EFTDB].[dbo].[tbl_EventRules]
  WHERE
  --edit values below for date and time range
	CAST (Time_stamp as date) between '2024-05-17' and '2024-06-19' 
	and Cast (Time_stamp as time) between '00:00:01' and '09:00:00'
	
