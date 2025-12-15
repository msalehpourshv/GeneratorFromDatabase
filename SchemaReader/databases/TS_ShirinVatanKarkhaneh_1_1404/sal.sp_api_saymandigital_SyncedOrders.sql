USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

create PROCEDURE [sal].[sp_api_saymandigital_SyncedOrders]
	@DocDate NVarChar(20)

WITH ENCRYPTION
AS
BEGIN

	select 
		SerialNo as 'AccountingNumber',
		ProcessNo as 'Tax',
		TransferSerialNo as 'OrderId' from sal.tblSaleOrderHdr
	where DocDate=@DocDate

END
GO
