SELECT 
	Timestamp AS Timestamp,
	FunctionName as FunctionName,
	Action AS Action,
	AffectedName as Name,
	ChangeOriginator as CreatedBy
FROM tbl_AdminActions
WHERE Action = 'Created' and AffectedArea = 'User Account' and ChangeOriginator = 'SYSTEM';