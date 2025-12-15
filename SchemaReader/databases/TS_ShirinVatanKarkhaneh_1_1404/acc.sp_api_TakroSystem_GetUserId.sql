USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
	-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1401-05-25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[sp_api_TakroSystem_GetUserId]
@AcntCode AS VARCHAR(100)
WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage AS NVARCHAR(MAX)	
	DECLARE @AcntPart AS TINYINT 
BEGIN TRY
	
	SELECT ISNULL(UserID,0) AS UserId FROM [usr].[tblUsers]
	WHERE UserAcntCode=@AcntCode
	
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
