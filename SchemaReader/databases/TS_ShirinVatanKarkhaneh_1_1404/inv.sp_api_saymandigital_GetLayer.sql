USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : E.Alian
-- Create date   : 1401/06/20
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE inv.sp_api_saymandigital_GetLayer 
WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)

BEGIN TRY

	SELECT Layer1,Layer2,Layer3,Layer4,Layer5,Layer6,Layer7  
	FROM pub.tblCodeLayer 
	WHERE TableName='inv.tblGoods' AND PartNumber=1

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
