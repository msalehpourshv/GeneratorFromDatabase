USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Reza NP
-- Create Date   : 1391/03/21
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE  Function [srv].[funNewRowAlarm]()
RETURNS INT
WITH ENCRYPTION
AS
BEGIN
	DECLARE @RowCount INT
	
	SELECT @RowCount  = COUNT(EventID) FROM 
	(SELECT EventID, 	   
		substring(EventDesc,10,1) as Internal,	
		substring(EventDesc,18,4) AS Ext,
		CASE WHEN (EventDesc like '%incom%') THEN 1 ELSE 0 END AS Incoming
	 FROM [TS].[pub].[tblPortEvents]
	 WHERE substring(EventDesc,3,1) = '/' 
	) a
	WHERE Incoming=1 and Internal=' ' and Ext=' ' AND 
		  EventID > (SELECT MAX(EventID) FROM pub.tblTelLog)
	RETURN @RowCount 	  
END


GO
