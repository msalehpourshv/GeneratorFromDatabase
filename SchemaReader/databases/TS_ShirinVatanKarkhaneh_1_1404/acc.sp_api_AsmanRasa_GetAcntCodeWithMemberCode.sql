USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        :Elaheh AlianPour
-- Create date   : 1400/11/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[sp_api_AsmanRasa_GetAcntCodeWithMemberCode]

@MemberCode As VARCHAR(20)

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)

BEGIN TRY
	
	IF(SELECT COUNT(*) FROM  acc.tblAcnt 
	WHERE MemberCode=@MemberCode)=0
		BEGIN
			select 0 as AcntCode
		END

	SELECT ISNULL(AcntCode,0) AS AcntCode FROM acc.tblAcnt 
	WHERE MemberCode=@MemberCode

		
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
