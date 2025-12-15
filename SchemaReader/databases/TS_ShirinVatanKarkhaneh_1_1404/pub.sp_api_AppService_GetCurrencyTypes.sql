USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/11/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE pub.sp_api_AppService_GetCurrencyTypes


WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	
BEGIN TRY

	select s.CurrencyTypeID,CurrencyTypeName,s.ISOCode from pub.tblCurrencyTypes s
	left join pub.tblCurrencyTypesDtl sd on sd.CurrencyTypeID=s.CurrencyTypeID
	ORDER BY CurrencyTypeName


END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
