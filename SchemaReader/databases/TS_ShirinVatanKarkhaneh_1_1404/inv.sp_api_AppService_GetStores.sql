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
cREATE PROCEDURE inv.sp_api_AppService_GetStores


WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	
BEGIN TRY

	select s.StoreID,sd.StoreName,sd.Address from inv.tblStores s
	left join inv.tblStoresDtl sd on sd.StoreID=s.StoreID
	ORDER BY s.StoreID


END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
