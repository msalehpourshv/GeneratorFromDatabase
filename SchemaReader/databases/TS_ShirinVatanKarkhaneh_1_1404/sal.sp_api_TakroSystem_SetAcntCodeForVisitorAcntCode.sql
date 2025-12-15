USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/11/18
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[sp_api_TakroSystem_SetAcntCodeForVisitorAcntCode]

@VisitorAcntCode as Nvarchar(50)

WITH ENCRYPTION
 AS
BEGIN

DECLARE @MoinAcntCode AS NVARCHAR(50)
DECLARE @StrErrorMessage AS NVARCHAR(MAX)

BEGIN TRY

	if (SELECT isnull(SettingValue,1)as SettingValue  
        FROM pub.tblSettings  
        WHERE SettingKey='SetAcntCodeForVisitorAcntCode') =1
	
	begin 
		SELECT @MoinAcntCode= isnull(rtrim(ltrim(SettingValue)),'') 
		FROM pub.tblSettings 
		WHERE SettingKey='salConstantAcntCodeForVisitor'

		SET @VisitorAcntCode=@MoinAcntCode+' '+@VisitorAcntCode

		SELECT @VisitorAcntCode
	end
	
	ELSE
		SELECT @VisitorAcntCode

END TRY

BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
