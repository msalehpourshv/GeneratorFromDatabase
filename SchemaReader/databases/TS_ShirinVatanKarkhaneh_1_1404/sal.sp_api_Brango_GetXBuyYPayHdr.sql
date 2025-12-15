USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1401/04/20
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE sal.sp_api_Brango_GetXBuyYPayHdr
	--@DiscountType as nvarchar(100)
WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery NVARCHAR(Max)
	
BEGIN TRY


	select distinct BH.SerialNo,BH.FromDate,BH.ToDate,BH.XBuy,BH.YPay
	from sal.tbl3buy2PayHdr BH INNER JOIN  
	sal.tbl3buy2PayDtl6 BD
	ON BH.SerialNo=BD.SerialNo
	inner join inv.tblGoods G
	on BD.GoodsID=Left(G.GoodsID,LenGoodsID)

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
