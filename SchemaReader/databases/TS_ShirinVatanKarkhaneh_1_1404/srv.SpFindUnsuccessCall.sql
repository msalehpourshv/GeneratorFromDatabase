USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Reza NP
-- Create date   : 1391/03/23
-- Viewed By	 : 

-- Last Modifier : TakroSystem\
-- Description   : 
-- =============================================
CREATE PROCEDURE [srv].[SpFindUnsuccessCall]
	@Date		char(10)
	--@DialNumber	VarChar(50)
	WITH ENCRYPTION
	AS
BEGIN
      
   	BEGIN TRY
		DROP TABLE ##tempUnsucsess
	END TRY
	BEGIN CATCH
	END CATCH
	
	SELECT  EventID INTO ##tempUnsucsess 
	FROM pub.tblTelLog
	WHERE DocDate>= @Date and Unsuccess = 'True' and DialNumber <> '' AND [TS].[pub].[funGetNextCallEventID](EventID,DialNumber)< 2147483647
	
	
	UPDATE 	pub.tblTelLog 
	SET Unsuccess = 'False'
		WHERE EventID IN (SELECT EventID  FROM ##tempUnsucsess)		
  
  SELECT EventID FROM ##tempUnsucsess
  
  
END
GO
